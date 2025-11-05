import 'dart:convert';
import 'dart:async';
import 'package:flutter/material.dart';
import '../models/create_order_model.dart';
import '../services/api_service.dart';
import 'order_detail_screen.dart';

class ConfirmOrderScreen extends StatefulWidget {
  final String accessToken;
  final int userId;
  final CreateOrderModel orderModel;
  final String countryCode;

  const ConfirmOrderScreen({
    super.key,
    required this.accessToken,
    required this.userId,
    required this.orderModel,
    required this.countryCode,
  });

  @override
  State<ConfirmOrderScreen> createState() => _ConfirmOrderScreenState();
}

class _ConfirmOrderScreenState extends State<ConfirmOrderScreen> {
  bool isLoading = false;
  bool showQR = false;
  String qrUrl = "";
  int countdown = 300;
  Timer? countdownTimer;
  Timer? pollTimer;
  String paymentStatus = "";
  String qrDescription = "";

  @override
  void dispose() {
    countdownTimer?.cancel();
    pollTimer?.cancel();
    super.dispose();
  }

  String countryCodeToEmoji(String countryCode) {
    return countryCode.toUpperCase().codeUnits
        .map((c) => String.fromCharCode(0x1F1E6 - 65 + c))
        .join();
  }

  double getTotalOrderAmount() {
    double total = 0;
    for (final item in widget.orderModel.orderItems) {
      total += item.weightEstimate * item.price;
    }
    return total;
  }

  double getDownPayment() {
    return widget.orderModel.downPayment;
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
      ),
    );
  }

  Future<void> _onPayment() async {
    final amount = getDownPayment();

    // Nếu dùng ví hoặc số dư ví >= tổng tiền
    if (amount <= 0) {
      setState(() => isLoading = true);
      await _submitOrder();
      return;
    }

    // Trường hợp cần quét QR để chuyển khoản
    final now = DateTime.now();
    final timestamp =
        "${now.hour.toString().padLeft(2, '0')}${now.minute.toString().padLeft(2, '0')}${now.second.toString().padLeft(2, '0')}";
    final description = "${widget.userId}$timestamp";
    qrDescription = description;

    final qrImageUrl =
        "https://img.vietqr.io/image/MB-34567200288888-compact2.png?amount=${amount.toStringAsFixed(0)}&addInfo=${description}&accountName=LY%20NHAT%20ANH";
    qrUrl = qrImageUrl;

    setState(() {
      showQR = true;
      countdown = 300;
      paymentStatus = "";
    });

    // Đếm ngược thời gian QR
    countdownTimer?.cancel();
    countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        countdown--;
      });
      if (countdown <= 0) {
        timer.cancel();
        pollTimer?.cancel();
        setState(() {
          paymentStatus = "⛔ Hết thời gian thanh toán. Giao dịch thất bại.";
          showQR = false;
        });
        _showSnackBar("⛔ Hết thời gian thanh toán!", Colors.red);
      }
    });

    // ✅ Sau 15 giây mới bắt đầu kiểm tra giao dịch mỗi 7 giây
    Future.delayed(const Duration(seconds: 15), () {
      pollTimer?.cancel();
      pollTimer = Timer.periodic(const Duration(seconds: 7), (poll) async {
        final res = await ApiService.getLastTransactions(
          amount: amount,
          content: description,
        );

        if (res.statusCode == 200) {
          try {
            final parsed = jsonDecode(res.body);
            final success = parsed['success'] == true;

            if (success) {
              countdownTimer?.cancel();
              pollTimer?.cancel();
              setState(() {
                paymentStatus = "✅ Thanh toán thành công!";
                showQR = false;
              });
              _showSnackBar("✅ Thanh toán thành công!", Colors.green);
              await _submitOrder();
              return;
            }
          } catch (e) {
            debugPrint("❌ Lỗi parse JSON: $e");
          }
        }
      });
    });
  }

  Future<void> _submitOrder() async {
    setState(() => isLoading = true);
    try {
      final res = await ApiService.createOrder(
        accessToken: widget.accessToken,
        senderName: widget.orderModel.senderName,
        receiverName: widget.orderModel.receiverName,
        senderPhone: widget.orderModel.senderPhone,
        receiverPhone: widget.orderModel.receiverPhone,
        senderAddress: widget.orderModel.senderAddress,
        receiverAddress: widget.orderModel.receiverAddress,
        countryId: widget.orderModel.countryId,
        payWithBalance: widget.orderModel.payWithBalance,
        downPayment: widget.orderModel.downPayment,
        orderItems:
        widget.orderModel.orderItems.map((e) => e.toJson()).toList(),
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body is Map &&
            (body['success'] == true || body['orderId'] != null)) {
          final orderId = body['orderId'];
          final code = body['orderCode'] ?? '';
          _showSnackBar("Tạo đơn hàng thành công${code.isNotEmpty ? ': $code' : ''}",
              Colors.green);
          if (orderId != null) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (_) => OrderDetailScreen(orderId: orderId),
              ),
            );
            return;
          }
        } else {
          final msg = (body is Map && body['message'] != null)
              ? body['message']
              : "Tạo đơn không thành công";
          _showSnackBar(msg.toString(), Colors.orange);
        }
      } else if (res.statusCode == 401) {
        _showSnackBar("Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.", Colors.red);
      } else {
        _showSnackBar("Lỗi khi tạo đơn: ${res.statusCode}", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Lỗi kết nối: $e", Colors.red);
    } finally {
      setState(() => isLoading = false);
    }
  }

  Widget _buildOrderInfo() {
    final order = widget.orderModel;
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text("Quốc gia:",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(width: 8),
                Text(
                  countryCodeToEmoji(widget.countryCode),
                  style: const TextStyle(fontSize: 20),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text("Người gửi: ${order.senderName} - ${order.senderPhone}",
                style: const TextStyle(fontSize: 15)),
            Text("Địa chỉ gửi: ${order.senderAddress}",
                style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 8),
            Text("Người nhận: ${order.receiverName} - ${order.receiverPhone}",
                style: const TextStyle(fontSize: 15)),
            Text("Địa chỉ nhận: ${order.receiverAddress}",
                style: const TextStyle(fontSize: 15)),
            const SizedBox(height: 10),
            const Text("Mặt hàng:",
                style: TextStyle(fontWeight: FontWeight.bold)),
            ...order.orderItems.map((item) => Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                children: [
                  Text(item.name, style: const TextStyle(fontSize: 15)),
                  const SizedBox(width: 8),
                  Text("[${item.weightEstimate} ${item.unit}]",
                      style: const TextStyle(fontSize: 15)),
                  const SizedBox(width: 8),
                  Text("${item.price.toStringAsFixed(0)}đ/${item.unit}",
                      style: const TextStyle(
                          color: Colors.green, fontSize: 15)),
                ],
              ),
            )),
            const SizedBox(height: 10),
            Text("Tổng tiền: ${getTotalOrderAmount().toStringAsFixed(0)}đ",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                    fontSize: 16)),
            Text("Tiền chuyển khoản: ${getDownPayment().toStringAsFixed(0)}đ",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                    fontSize: 16)),
            if (order.payWithBalance > 0)
              Text("Sử dụng ví: ${order.payWithBalance.toStringAsFixed(0)}đ",
                  style:
                  const TextStyle(color: Colors.orange, fontSize: 15)),
          ],
        ),
      ),
    );
  }

  Widget _buildQRSection() {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text("Quét mã QR để chuyển khoản",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blue)),
            const SizedBox(height: 16),
            Image.network(qrUrl, height: 280, width: 280, fit: BoxFit.contain),
            const SizedBox(height: 10),
            Text("Số tiền: ${getDownPayment().toStringAsFixed(0)} VND",
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            Text("Nội dung: $qrDescription",
                style:
                const TextStyle(color: Colors.orange, fontSize: 16)),
            const SizedBox(height: 10),
            Text(
              "Thời gian còn lại: ${countdown ~/ 60}:${(countdown % 60).toString().padLeft(2, '0')}",
              style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red,
                  fontSize: 18),
            ),
            const SizedBox(height: 8),
            const Text(
              "Sau khi chuyển khoản, hệ thống sẽ kiểm tra tự động.\nVui lòng không tắt màn hình khi chưa xác nhận.",
              style: TextStyle(fontSize: 13, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            if (paymentStatus.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  paymentStatus,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: paymentStatus.contains("thành công")
                        ? Colors.green
                        : Colors.red,
                    fontSize: 15,
                  ),
                ),
              ),
            const SizedBox(height: 10),
            TextButton.icon(
              onPressed: () {
                countdownTimer?.cancel();
                pollTimer?.cancel();
                setState(() {
                  showQR = false;
                  paymentStatus = "";
                });
              },
              icon: const Icon(Icons.close, color: Colors.red),
              label:
              const Text("Đóng mã QR", style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: const Text("Xác nhận đơn hàng",
            style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _buildOrderInfo(),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: isLoading || showQR ? null : _onPayment,
                          icon:
                          const Icon(Icons.qr_code, color: Colors.white),
                          label: isLoading
                              ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(
                                  color: Colors.white, strokeWidth: 2))
                              : const Text("Thanh toán",
                              style: TextStyle(fontSize: 18)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[500],
                            padding:
                            const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: const Icon(Icons.cancel, color: Colors.red),
                          label: const Text("Huỷ",
                              style:
                              TextStyle(fontSize: 18, color: Colors.red)),
                          style: OutlinedButton.styleFrom(
                            padding:
                            const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          if (showQR)
            Center(
              child: _buildQRSection(),
            ),
        ],
      ),
    );
  }
}
