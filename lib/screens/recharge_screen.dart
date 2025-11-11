import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../l10n/app_localizations.dart';

class RechargeScreen extends StatefulWidget {
  final String accessToken;
  const RechargeScreen({super.key, required this.accessToken});

  @override
  State<RechargeScreen> createState() => _RechargeScreenState();
}

class _RechargeScreenState extends State<RechargeScreen> {
  final _formKey = GlobalKey<FormState>();
  final amountController = TextEditingController();
  bool isLoading = false;
  bool showQR = false;
  String qrUrl = "";
  String qrDescription = "";
  int countdown = 300;
  Timer? countdownTimer;
  Timer? pollTimer;
  String paymentStatus = "";
  double? rechargeAmount;
  int? userId;

  @override
  void initState() {
    super.initState();
    _loadUserId();
  }

  Future<void> _loadUserId() async {
    final prefs = await SharedPreferences.getInstance();
    userId = prefs.getInt('id') ?? 0;
    if (mounted) setState(() {});
  }

  void _showSnackBar(String message, Color color) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)), backgroundColor: color),
    );
  }

  Future<void> _startRecharge(double amount) async {
    final loc = AppLocalizations.of(context)!;
    if (amount < 50000) {
      _showSnackBar(loc.rechargeMinAmountError, Colors.red);
      return;
    }
    if (userId == null || userId == 0) {
      _showSnackBar(loc.rechargeUserIdError, Colors.red);
      return;
    }

    final timestamp = DateTime.now();
    final description =
        "${userId}${timestamp.hour.toString().padLeft(2, '0')}${timestamp.minute.toString().padLeft(2, '0')}${timestamp.second.toString().padLeft(2, '0')}";
    qrDescription = description;
    qrUrl =
    "https://img.vietqr.io/image/MB-34567200288888-compact2.png?amount=${amount.toStringAsFixed(0)}&addInfo=$description&accountName=LY%20NHAT%20ANH";

    if (!mounted) return;
    setState(() {
      showQR = true;
      countdown = 300;
      paymentStatus = "";
      rechargeAmount = amount;
    });

    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      setState(() => countdown--);
      if (countdown <= 0) {
        timer.cancel();
        pollTimer?.cancel();
        if (!mounted) return;
        setState(() {
          showQR = false;
          paymentStatus = loc.rechargeTimeout;
        });
        _showSnackBar(loc.rechargeTimeout, Colors.red);
      }
    });

    // Bắt đầu kiểm tra giao dịch sau 15 giây
    Future.delayed(const Duration(seconds: 15), () {
      pollTimer?.cancel();
      pollTimer = Timer.periodic(const Duration(seconds: 7), (t) async {
        if (!mounted || !showQR) {
          t.cancel();
          return;
        }
        final res = await ApiService.checkDepositStatus(
          accessToken: widget.accessToken,
          amount: amount,
          content: description,
        );
        if (res.statusCode == 200) {
          try {
            final data = jsonDecode(res.body);
            if (data['success'] == true) {
              countdownTimer?.cancel();
              t.cancel();
              if (!mounted) return;
              setState(() {
                paymentStatus = loc.rechargeSuccess;
                showQR = false;
              });
              _showSnackBar(loc.rechargeSuccess, Colors.green);
            }
          } catch (e) {
            debugPrint("❌ Lỗi parse JSON: $e");
          }
        } else if (res.statusCode == 456) {
          debugPrint("Chưa thấy giao dịch: ${res.body}");
        } else {
          debugPrint("Lỗi nạp tiền: ${res.statusCode}");
        }
      });
    });
  }

  Widget _buildAmountInput(AppLocalizations loc) {
    return TextFormField(
      controller: amountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: loc.rechargeAmountHint,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.monetization_on, color: Colors.blue),
      ),
      validator: (v) {
        final val = double.tryParse(v ?? "");
        if (val == null || val <= 0) return loc.rechargeAmountHint;
        return null;
      },
    );
  }

  Widget _buildQRDialog(AppLocalizations loc) {
    final minutes = countdown ~/ 60;
    final seconds = (countdown % 60).toString().padLeft(2, '0');
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loc.rechargeQRCodeTitle, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
            const SizedBox(height: 16),
            Image.network(qrUrl, height: 280, width: 280, fit: BoxFit.contain),
            const SizedBox(height: 10),
            Text(loc.rechargeQRCodeAmount(rechargeAmount?.toStringAsFixed(0) ?? "0"), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text(loc.rechargeQRCodeContent(qrDescription), style: const TextStyle(color: Colors.orange, fontSize: 16)),
            const SizedBox(height: 10),
            Text(loc.rechargeQRCodeCountdown(minutes, seconds), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
            const SizedBox(height: 8),
            if (paymentStatus.isNotEmpty)
              Text(paymentStatus, style: TextStyle(color: paymentStatus.contains("thành công") || paymentStatus.contains("successful") ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 15)),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {
                countdownTimer?.cancel();
                pollTimer?.cancel();
                if (!mounted) return;
                setState(() {
                  showQR = false;
                  paymentStatus = "";
                });
              },
              icon: const Icon(Icons.close, color: Colors.red),
              label: Text(loc.rechargeQRCodeCloseButton, style: const TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    countdownTimer?.cancel();
    pollTimer?.cancel();
    amountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: Text(loc.rechargeTitle, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    const SizedBox(height: 20),
                    _buildAmountInput(loc),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: isLoading
                            ? null
                            : () {
                          if (_formKey.currentState!.validate()) {
                            final amount = double.parse(amountController.text);
                            _startRecharge(amount);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green[500],
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        child: Text(loc.rechargeTitle, style: const TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (isLoading) const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          ),
          if (showQR) Center(child: _buildQRDialog(loc)),
        ],
      ),
    );
  }
}