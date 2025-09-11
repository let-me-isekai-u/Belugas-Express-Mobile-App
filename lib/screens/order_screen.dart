import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'order_detail_screen.dart';
import 'package:http/http.dart' as http;

class Order {
  final int id;
  final String orderCode;
  final String senderName;
  final String senderPhone;
  final String senderAddress;
  final String receiverName;
  final String receiverPhone;
  final String receiverAddress;
  final double weightEstimate;
  final double weightReal;
  final double downPayment;
  final double pricePerKilogram;
  final String country;
  final int status;
  final DateTime createDate;

  Order({
    required this.id,
    required this.orderCode,
    required this.senderName,
    required this.senderPhone,
    required this.senderAddress,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverAddress,
    required this.weightEstimate,
    required this.weightReal,
    required this.downPayment,
    required this.pricePerKilogram,
    required this.country,
    required this.status,
    required this.createDate,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json["id"],
      orderCode: json["orderCode"],
      senderName: json["senderName"],
      senderPhone: json["senderPhone"],
      senderAddress: json["senderAddress"],
      receiverName: json["receiverName"],
      receiverPhone: json["receiverPhone"],
      receiverAddress: json["receiverAddress"],
      weightEstimate: (json["weightEstimate"] ?? 0).toDouble(),
      weightReal: (json["weightReal"] ?? 0).toDouble(),
      downPayment: (json["downPayment"] ?? 0).toDouble(),
      pricePerKilogram: (json["pricePerKilogram"] ?? 0).toDouble(),
      country: json["country"] ?? "",
      status: json["status"] ?? 0,
      createDate: DateTime.parse(json["createDate"]),
    );
  }

  double get total {
    if (status == 1 || status == 2) {
      return weightEstimate * pricePerKilogram;
    } else if (status == 3 || status == 4 || status == 5) {
      return weightReal * pricePerKilogram;
    } else {
      return 0;
    }
  }

  double get displayedDownPayment {
    if (status == 1 || status == 2) {
      return total;
    } else {
      return downPayment;
    }
  }

  bool get canShowPayButton {
    return status == 3 && downPayment < total;
  }

  String get statusText {
    switch (status) {
      case 1:
        return "Chờ xác nhận";
      case 2:
        return "Chờ lấy hàng";
      case 3:
        return "Đang xử lý";
      case 4:
        return "Đang giao";
      case 5:
        return "Đã giao";
      default:
        return "Không xác định";
    }
  }

  Color get statusColor {
    switch (status) {
      case 1:
      case 2:
      case 3:
        return Colors.orange;
      case 4:
      case 5:
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  IconData get statusIcon {
    switch (status) {
      case 1:
      case 2:
      case 3:
        return Icons.hourglass_top;
      case 4:
        return Icons.local_shipping;
      case 5:
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }
}

class OrderScreen extends StatefulWidget {
  const OrderScreen({super.key});

  @override
  State<OrderScreen> createState() => _OrderScreenState();
}

class _OrderScreenState extends State<OrderScreen> {
  late Future<List<Order>> _futureOrders;
  Timer? _pollingTimer;

  @override
  void initState() {
    super.initState();
    _futureOrders = _loadOrders();
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<List<Order>> _loadOrders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken") ?? "";

    final response = await ApiService.getOrders(accessToken: token);
    if (response.statusCode == 200) {
      final List<dynamic> jsonList = jsonDecode(response.body);
      return jsonList.map((e) => Order.fromJson(e)).toList();
    } else {
      throw Exception("Lỗi tải đơn hàng (${response.statusCode})");
    }
  }

  Future<void> _handlePayment(BuildContext context, Order order) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString("accessToken") ?? "";
    final userId = prefs.getInt("userId") ?? 0;

    final amount = order.total - order.downPayment;
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final description = "QR${userId}${timestamp}";

    // Gọi API tạo QR
    final response = await ApiService.createPayment(
      accessToken: token,
      orderId: order.id,
      amount: amount,
      content: description,
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final qrUrl = data["qrCodeUrl"];

      _showQrDialog(context, order, amount, description, qrUrl);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Lỗi tạo QR (${response.statusCode})")),
      );
    }
  }

  void _showQrDialog(BuildContext context, Order order, double amount,
      String description, String? qrUrl) {
    _pollingTimer?.cancel();

    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      final res = await http.get(Uri.parse(
          "https://script.google.com/macros/s/AKfycbyB5JISCpIjFJp9ikNS00RP34ywViepMogpyjAXaLgimbYkqSFb2KiY5APofTMW2arP_A/exec"));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        final List txs = body["data"] ?? [];

        for (var tx in txs) {
          final double txAmount =
          (tx["values_0_2"] is int ? tx["values_0_2"].toDouble() : tx["values_0_2"]);
          final String txDesc = tx["values_0_9"].toString();

          if (txAmount == amount && txDesc.contains(description)) {
            _pollingTimer?.cancel();
            Navigator.pop(context); // đóng dialog
            setState(() {
              _futureOrders = _loadOrders(); // reload list
            });

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => OrderDetailScreen(orderId: order.id),
              ),
            );
            return;
          }
        }
      }
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text("Thanh toán bổ sung"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Số tiền: $amount đ"),
            const SizedBox(height: 8),
            Text("Nội dung: $description"),
            const SizedBox(height: 12),
            if (qrUrl != null)
              Image.network(qrUrl, height: 200, fit: BoxFit.contain),
            const SizedBox(height: 10),
            const Text(
              "Hệ thống sẽ tự động kiểm tra giao dịch\nsau khi bạn chuyển khoản thành công.",
              style: TextStyle(fontSize: 12, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              _pollingTimer?.cancel();
              Navigator.pop(context);
            },
            child: const Text("Hủy"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        title: const Text("Danh sách đơn hàng"),
        elevation: 0,
      ),
      body: FutureBuilder<List<Order>>(
        future: _futureOrders,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Lỗi: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return _buildEmptyOrders();
          }

          final orders = snapshot.data!;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];

              return InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => OrderDetailScreen(orderId: order.id),
                    ),
                  );
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [Colors.white, Colors.blue[50]!],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.blue[100]!.withOpacity(0.2),
                        blurRadius: 18,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              backgroundColor:
                              order.statusColor.withOpacity(0.15),
                              child: Icon(
                                order.statusIcon,
                                color: order.statusColor,
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Text(
                                "Mã đơn: ${order.orderCode}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 17,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: order.statusColor.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(18),
                              ),
                              child: Text(
                                order.statusText,
                                style: TextStyle(
                                  color: order.statusColor,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            const Icon(Icons.send,
                                color: Colors.blueGrey, size: 20),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "${order.senderName} (${order.senderPhone})",
                                style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500),
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              "${order.weightEstimate}kg",
                              style: const TextStyle(
                                  fontSize: 13, color: Colors.grey),
                            ),
                          ],
                        ),
                        const SizedBox(height: 5),
                        Row(
                          children: [
                            const Icon(Icons.location_on,
                                color: Colors.teal, size: 20),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                "Đến: ${order.receiverName} - ${order.receiverAddress}",
                                style: const TextStyle(fontSize: 14),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Divider(
                            color: Colors.blue[100], height: 22, thickness: 1),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.attach_money,
                                color: Colors.orange, size: 18),
                            const SizedBox(width: 4),
                            Text("Tiền cọc: ",
                                style: const TextStyle(fontSize: 13)),
                            Text(
                              "${order.displayedDownPayment} đ",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                            const SizedBox(width: 16),
                            Text("Tổng: ",
                                style: const TextStyle(fontSize: 13)),
                            Text(
                              "${order.total} đ",
                              style: const TextStyle(
                                  fontWeight: FontWeight.bold, fontSize: 13),
                            ),
                          ],
                        ),
                        if (order.canShowPayButton)
                          Padding(
                            padding: const EdgeInsets.only(top: 10),
                            child: Align(
                              alignment: Alignment.centerRight,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.orange[400],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 20, vertical: 8),
                                ),
                                onPressed: () =>
                                    _handlePayment(context, order),
                                icon: const Icon(Icons.payment,
                                    size: 18, color: Colors.white),
                                label: const Text("Thanh toán",
                                    style: TextStyle(
                                        fontSize: 15, color: Colors.white)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildEmptyOrders() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.inbox, size: 70, color: Colors.blue[200]),
          const SizedBox(height: 20),
          Text(
            "Bạn chưa có đơn hàng nào!",
            style: TextStyle(
                fontSize: 18,
                color: Colors.blueGrey[700],
                fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          Text(
            "Nhấn 'Tạo đơn' để bắt đầu gửi hàng.",
            style: TextStyle(fontSize: 15, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
