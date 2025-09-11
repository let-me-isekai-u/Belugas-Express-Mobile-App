import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'home_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final int orderId;

  const OrderDetailScreen({Key? key, required this.orderId}) : super(key: key);

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  Map<String, dynamic>? orderDetail;
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrderDetail();
  }

  Future<void> _fetchOrderDetail() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('accessToken') ?? '';

      if (token.isEmpty) {
        setState(() {
          isLoading = false;
          errorMessage = "Chưa đăng nhập";
        });
        return;
      }

      final res = await ApiService.orderDetails(
        accessToken: token,
        id: widget.orderId,
      );

      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        if (body is Map<String, dynamic>) {
          setState(() {
            orderDetail = body;
            isLoading = false;
          });
        } else {
          setState(() {
            isLoading = false;
            errorMessage = "Dữ liệu không hợp lệ";
          });
        }
      } else if (res.statusCode == 401) {
        setState(() {
          isLoading = false;
          errorMessage = "Phiên đăng nhập hết hạn, vui lòng đăng nhập lại.";
        });
      } else {
        setState(() {
          isLoading = false;
          errorMessage = "Lỗi server: ${res.statusCode}";
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = "Có lỗi xảy ra: $e";
      });
    }
  }

  // Tính tổng tiền theo trạng thái
  double _calcTotal(Map<String, dynamic> o) {
    final status = o["status"];
    if (status == 1 || status == 2) {
      return (o["weightEstimate"] ?? 0) * (o["pricePerKilogram"] ?? 0);
    } else if (status == 3 || status == 4 || status == 5) {
      return (o["weightReal"] ?? 0) * (o["pricePerKilogram"] ?? 0);
    }
    return 0;
  }

  double _calcDownPayment(Map<String, dynamic> o, double total) {
    final status = o["status"];
    final downPayment = (o["downPayment"] ?? 0).toDouble();
    if (status == 1 || status == 2) {
      return total;
    } else {
      return downPayment;
    }
  }

  String _statusText(int? status) {
    switch (status) {
      case 1:
        return "Chờ xác nhận";
      case 2:
        return "Chờ lấy hàng";
      case 3:
        return "Chờ xác nhận lại";
      case 4:
        return "Đang giao";
      case 5:
        return "Đã giao";
      default:
        return "Không xác định";
    }
  }

  Color _getStatusColor(int? status) {
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

  IconData _getStatusIcon(int? status) {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        elevation: 0,
        title: const Text("Chi tiết đơn hàng"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () async {
            final prefs = await SharedPreferences.getInstance();
            final token = prefs.getString('accessToken') ?? '';
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => HomeScreen(accessToken: token),
              ),
            );
          },
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
        child: Text(
          errorMessage!,
          style: const TextStyle(color: Colors.red, fontSize: 16),
        ),
      )
          : orderDetail == null
          ? const Center(
        child: Text(
          "Không tìm thấy dữ liệu đơn hàng",
          style: TextStyle(color: Colors.red),
        ),
      )
          : _buildOrderDetail(),
    );
  }

  Widget _buildOrderDetail() {
    double total = _calcTotal(orderDetail!);
    double downPayment = _calcDownPayment(orderDetail!, total);
    int? statusValue = orderDetail!["status"];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue[100]!.withOpacity(0.2),
              blurRadius: 12,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header trạng thái
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: _getStatusColor(statusValue).withOpacity(0.15),
                  radius: 26,
                  child: Icon(
                    _getStatusIcon(statusValue),
                    color: _getStatusColor(statusValue),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Text(
                    "Mã đơn: ${orderDetail!["orderCode"] ?? orderDetail!["id"]}",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: _getStatusColor(statusValue).withOpacity(0.12),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Text(
                _statusText(statusValue),
                style: TextStyle(
                  color: _getStatusColor(statusValue),
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Người gửi
            _buildSection("Người gửi", [
              _buildRow("Họ tên", orderDetail!["senderName"] ?? ""),
              _buildRow("SĐT", orderDetail!["senderPhone"] ?? ""),
              _buildRow("Địa chỉ", orderDetail!["senderAddress"] ?? ""),
            ]),
            const SizedBox(height: 16),

            // Người nhận
            _buildSection("Người nhận", [
              _buildRow("Họ tên", orderDetail!["receiverName"] ?? ""),
              _buildRow("SĐT", orderDetail!["receiverPhone"] ?? ""),
              _buildRow("Địa chỉ", orderDetail!["receiverAddress"] ?? ""),
            ]),
            const SizedBox(height: 16),

            // Thông tin đơn hàng
            _buildRow("Khối lượng ước tính", "${orderDetail!["weightEstimate"] ?? 0} kg"),
            _buildRow("Khối lượng thực tế", "${orderDetail!["weightReal"] ?? 'chưa tính'} kg"),
            _buildRow("Đơn giá", "${orderDetail!["pricePerKilogram"] ?? 0} đ/kg"),
            _buildRow("Tiền cọc", "$downPayment đ", valueColor: Colors.orange),
            _buildRow("Tổng tiền", "$total đ", valueColor: Colors.green, bold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: Colors.blue,
          ),
        ),
        const SizedBox(height: 6),
        ...children,
      ],
    );
  }

  Widget _buildRow(String label, String value,
      {Color? valueColor, bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text(
            "$label: ",
            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                fontSize: 14,
                fontWeight: bold ? FontWeight.bold : FontWeight.normal,
                color: valueColor ?? Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
