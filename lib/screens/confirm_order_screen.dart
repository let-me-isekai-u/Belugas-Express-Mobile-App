import 'dart:convert';
import 'package:flutter/material.dart';
import '../models/create_order_model.dart';
import '../services/api_service.dart';
import 'order_detail_screen.dart';

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
    _fetchWalletBalance();
  }

  Future<void> _fetchWalletBalance() async {
    try {
      final res = await ApiService.getWalletBalance(accessToken: widget.accessToken);
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data["success"] == true) {
          setState(() => _walletBalance = (data["wallet"] as num).toDouble());
        } else {
          _showDialog("Không thể lấy số dư ví.");
        }
      } else {
        _showDialog("Lỗi khi kiểm tra ví: ${res.statusCode}");
      }
    } catch (e) {
      _showDialog("Đã xảy ra lỗi: $e");
    }
  }

  Future<void> _confirmOrder() async {
    if (_walletBalance < 500000) {
      _showDialog("Số dư ví không đủ để tạo đơn hàng. Vui lòng nạp thêm.");
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
            "Tạo đơn hàng thành công! Mã đơn: ${data["orderCode"]}",
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
          _showDialog(data["message"] ?? "Tạo đơn thất bại!");
        }
      } else if (res.statusCode == 111) {
        _showDialog("Số dư ví không đủ để tạo đơn hàng.");
      } else if (res.statusCode == 401) {
        _showDialog("Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.");
      } else {
        _showDialog("Lỗi không xác định. Mã lỗi: ${res.statusCode}");
      }
    } catch (e) {
      _showDialog("Đã xảy ra lỗi: $e");
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _showDialog(String message, {VoidCallback? onConfirm}) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text("Thông báo"),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text("Xác nhận đơn hàng"),
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
                const Text("Thông tin người gửi",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Tên: ${order.senderName}"),
                Text("SĐT: ${order.senderPhone}"),
                Text("Địa chỉ: ${order.senderAddress}"),
                const SizedBox(height: 10),
                const Text("Thông tin người nhận",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                Text("Tên: ${order.receiverName}"),
                Text("SĐT: ${order.receiverPhone}"),
                Text("Địa chỉ: ${order.receiverAddress}"),
                const SizedBox(height: 10),
                const Text("Chi tiết hàng hoá",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ...order.orderItems.map(
                      (item) => ListTile(
                    title: Text(item.name),
                    subtitle: Text("Khối lượng: ${item.weightEstimate} ${item.unit}"),
                    trailing: Text("${item.price.toStringAsFixed(0)}đ/${item.unit}"),
                  ),
                ),
                const Divider(),
                const SizedBox(height: 10),
                Text(
                  "Số dư ví hiện tại: ${_walletBalance.toStringAsFixed(0)} VND",
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
                    label: const Text(
                      "Xác nhận đặt cọc 500.000 VND",
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
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
