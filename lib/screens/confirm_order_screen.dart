import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/create_order_model.dart';
import '../services/api_service.dart';
import 'order_detail_screen.dart';
import '../l10n/app_localizations.dart';

class ConfirmOrderScreen extends StatefulWidget {
  final CreateOrderModel orderModel;
  final String accessToken;
  final int userId;
  final String countryCode;

  const ConfirmOrderScreen({
    Key? key,
    required this.accessToken,
    required this.userId,
    required this.orderModel,
    required this.countryCode,
  }) : super(key: key);

  @override
  State<ConfirmOrderScreen> createState() => _ConfirmOrderScreenState();
}

class _ConfirmOrderScreenState extends State<ConfirmOrderScreen> {
  bool _isLoading = false;
  double _walletBalance = 0;

  @override
  void initState() {
    super.initState();
    // Đợi widget mount xong rồi mới gọi API
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _fetchWalletBalance();
    });
  }

  Future<void> _fetchWalletBalance() async {
    try {
      final res = await ApiService.getWalletBalance(accessToken: widget.accessToken);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["success"] == true) {
          if (mounted) {
            setState(() => _walletBalance = (data["wallet"] as num).toDouble());
          }
        } else {
          _showDialog(
            AppLocalizations.of(context)!.confirmOrderDialogFetchError,
            title: AppLocalizations.of(context)!.confirmOrderDialogTitle,
          );
        }
      } else {
        _showDialog(
          AppLocalizations.of(context)!
              .changePasswordConnectionError("${res.statusCode}"),
          title: AppLocalizations.of(context)!.confirmOrderDialogTitle,
        );
      }
    } catch (e) {
      _showDialog(
        AppLocalizations.of(context)!
            .changePasswordConnectionError("$e"),
        title: AppLocalizations.of(context)!.confirmOrderDialogTitle,
      );
    }
  }

  Future<void> _confirmOrder() async {
    final loc = AppLocalizations.of(context)!;
    if (_walletBalance < 500000) {
      _showDialog(
        loc.confirmOrderDialogInsufficientWallet,
        title: loc.confirmOrderDialogTitle,
      );
      return;
    }

    setState(() => _isLoading = true);
    try {
      final res = await ApiService.createOrderWithWallet(
        accessToken: widget.accessToken,
        senderName: widget.orderModel.senderName,
        receiverName: widget.orderModel.receiverName,
        senderPhone: widget.orderModel.senderPhone,
        receiverPhone: widget.orderModel.receiverPhone,
        senderAddress: widget.orderModel.senderAddress,
        receiverAddress: widget.orderModel.receiverAddress,
        countryId: widget.orderModel.countryId,
        downPayment: 500000,
        orderItems: widget.orderModel.orderItems.map((e) => e.toJson()).toList(),
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["success"] == true) {
          _showDialog(
            loc.confirmOrderDialogCreateSuccess(data["orderCode"] ?? ""),
            title: loc.confirmOrderDialogTitle,
            onConfirm: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailScreen(orderId: data["orderId"]),
                ),
              );
            },
          );
        } else {
          _showDialog(
            data["message"] ?? loc.confirmOrderDialogCreateFailed,
            title: loc.confirmOrderDialogTitle,
          );
        }
      } else if (res.statusCode == 111) {
        _showDialog(
          loc.confirmOrderDialogInsufficientWallet,
          title: loc.confirmOrderDialogTitle,
        );
      } else if (res.statusCode == 401) {
        _showDialog(
          loc.confirmOrderDialogSessionExpired,
          title: loc.confirmOrderDialogTitle,
        );
      } else {
        _showDialog(
          loc.confirmOrderDialogUnknownError("${res.statusCode}"),
          title: loc.confirmOrderDialogTitle,
        );
      }
    } catch (e) {
      _showDialog(loc.changePasswordConnectionError("$e"),
          title: loc.confirmOrderDialogTitle);
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDialog(String message, {VoidCallback? onConfirm, String? title}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title ?? "Order"),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              if (onConfirm != null) onConfirm();
            },
            child: const Text("OK"),
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.orderModel;
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.confirmOrderTitle),
        backgroundColor: Colors.blueAccent,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(loc.confirmOrderSenderSection,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("${loc.createOrderSenderName}: ${order.senderName}"),
                Text("${loc.createOrderSenderPhone}: ${order.senderPhone}"),
                Text("${loc.createOrderSenderAddress}: ${order.senderAddress}"),
                const SizedBox(height: 10),
                Text(loc.confirmOrderReceiverSection,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("${loc.createOrderReceiverName}: ${order.receiverName}"),
                Text("${loc.createOrderReceiverPhone}: ${order.receiverPhone}"),
                Text("${loc.createOrderReceiverAddress}: ${order.receiverAddress}"),
                const SizedBox(height: 10),
                Text(loc.confirmOrderItemsSection,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ...order.orderItems.map(
                      (item) => ListTile(
                    title: Text(item.name),
                    subtitle: Text("${loc.createOrderItemWeight(item.unit)}: ${item.weightEstimate}"),
                    trailing: Text("${item.price.toStringAsFixed(0)}đ/${item.unit}"),
                  ),
                ),
                const Divider(),
                const SizedBox(height: 10),
                Text(
                  loc.confirmOrderWalletBalance(_walletBalance.toStringAsFixed(0)),
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
                ),
                const SizedBox(height: 16),
                Center(
                  child: _isLoading
                      ? const CircularProgressIndicator()
                      : ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.orangeAccent,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                    ),
                    icon: const Icon(Icons.wallet, color: Colors.white),
                    label: Text(
                      loc.confirmOrderDepositButton,
                      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                    onPressed: _confirmOrder,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
