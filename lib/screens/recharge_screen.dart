import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

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
    if (amount < 50000) {
      _showSnackBar("Số tiền nạp tối thiểu là 50.000 VND", Colors.red);
      return;
    }
    if (userId == null || userId == 0) {
      _showSnackBar("Không lấy được ID người dùng.", Colors.red);
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
          paymentStatus = "⛔ Hết thời gian thanh toán.";
        });
        _showSnackBar("⛔ Hết thời gian thanh toán!", Colors.red);
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
                paymentStatus = "✅ Nạp tiền thành công!";
                showQR = false;
              });
              _showSnackBar("✅ Nạp tiền thành công!", Colors.green);
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

  Widget _buildAmountInput() {
    return TextFormField(
      controller: amountController,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: "Nhập số tiền nạp",
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        prefixIcon: const Icon(Icons.monetization_on, color: Colors.blue),
      ),
      validator: (v) {
        final val = double.tryParse(v ?? "");
        if (val == null || val <= 0) return "Nhập số tiền hợp lệ";
        return null;
      },
    );
  }

  Widget _buildQRDialog() {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Quét mã QR để chuyển khoản", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
            const SizedBox(height: 16),
            Image.network(qrUrl, height: 280, width: 280, fit: BoxFit.contain),
            const SizedBox(height: 10),
            Text("Số tiền: ${rechargeAmount?.toStringAsFixed(0)} VND", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
            Text("Nội dung: $qrDescription", style: const TextStyle(color: Colors.orange, fontSize: 16)),
            const SizedBox(height: 10),
            Text("Thời gian còn lại: ${countdown ~/ 60}:${(countdown % 60).toString().padLeft(2, '0')}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.red)),
            const SizedBox(height: 8),
            if (paymentStatus.isNotEmpty)
              Text(paymentStatus, style: TextStyle(color: paymentStatus.contains("thành công") ? Colors.green : Colors.red, fontWeight: FontWeight.bold, fontSize: 15)),
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
              label: const Text("Đóng mã QR", style: TextStyle(color: Colors.red)),
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
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: const Text("Nạp tiền vào ví", style: TextStyle(color: Colors.white)),
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
                    _buildAmountInput(),
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
                        child: const Text("Xác nhận nạp tiền", style: TextStyle(fontSize: 18, color: Colors.white)),
                      ),
                    ),
                    const SizedBox(height: 20),
                    if (isLoading) const CircularProgressIndicator(),
                  ],
                ),
              ),
            ),
          ),
          if (showQR) Center(child: _buildQRDialog()),
        ],
      ),
    );
  }
}
