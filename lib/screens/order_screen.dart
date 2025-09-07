import 'package:flutter/material.dart';
import 'order_detail_screen.dart';

class Order {
  final String id;
  final String status;
  final String senderName;
  final String senderPhone;
  final String senderAddress;
  final String receiverName;
  final String receiverPhone;
  final String receiverAddress;
  final double weight;
  final int deposit;
  final int total;

  Order({
    required this.id,
    required this.status,
    required this.senderName,
    required this.senderPhone,
    required this.senderAddress,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverAddress,
    required this.weight,
    required this.deposit,
    required this.total,
  });
}

class OrderScreen extends StatelessWidget {
  const OrderScreen({super.key});

  Color _getStatusColor(String status) {
    if (status == "Đang xử lý" || status == "Đợi nhận hàng") {
      return Colors.orange;
    } else if (status == "Đang giao") {
      return Colors.blue;
    } else {
      return Colors.green;
    }
  }

  IconData _getStatusIcon(String status) {
    switch (status) {
      case "Đang xử lý":
      case "Đợi nhận hàng":
        return Icons.hourglass_top;
      case "Đang giao":
        return Icons.local_shipping;
      default:
        return Icons.check_circle;
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Order> orders = [
      Order(
        id: "ORD123456",
        status: "Đang xử lý",
        senderName: "Nguyễn Văn A",
        senderPhone: "0123456789",
        senderAddress: "Hà Nội",
        receiverName: "Trần Thị B",
        receiverPhone: "0987654321",
        receiverAddress: "Tokyo, Nhật Bản",
        weight: 12.5,
        deposit: 1500000,
        total: 2000000,
      ),
      Order(
        id: "ORD123457",
        status: "Đang giao",
        senderName: "Nguyễn Văn A",
        senderPhone: "0123456789",
        senderAddress: "Hà Nội",
        receiverName: "Trần Thị B",
        receiverPhone: "0987654321",
        receiverAddress: "Tokyo, Nhật Bản",
        weight: 12.5,
        deposit: 2000000,
        total: 2000000,
      ),
    ];

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        title: const Text("Danh sách đơn hàng"),
        elevation: 0,
      ),
      body: orders.isEmpty
          ? _buildEmptyOrders()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) {
          final order = orders[index];
          final canPay = order.total > order.deposit;

          return InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => OrderDetailScreen(order: order),
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
                          backgroundColor: _getStatusColor(order.status).withOpacity(0.15),
                          child: Icon(
                            _getStatusIcon(order.status),
                            color: _getStatusColor(order.status),
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Text(
                            "Mã đơn: ${order.id}",
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 17,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: _getStatusColor(order.status).withOpacity(0.12),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Text(
                            order.status,
                            style: TextStyle(
                              color: _getStatusColor(order.status),
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
                        const Icon(Icons.send, color: Colors.blueGrey, size: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "${order.senderName} (${order.senderPhone})",
                            style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "${order.weight}kg",
                          style: const TextStyle(fontSize: 13, color: Colors.grey),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Row(
                      children: [
                        const Icon(Icons.location_on, color: Colors.teal, size: 20),
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
                    Divider(color: Colors.blue[100], height: 22, thickness: 1),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.attach_money, color: Colors.orange, size: 18),
                        const SizedBox(width: 4),
                        Text(
                          "Tiền cọc: ",
                          style: const TextStyle(fontSize: 13),
                        ),
                        Text(
                          "${order.deposit} đ",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        const SizedBox(width: 16),
                        Text(
                          "Tổng: ",
                          style: const TextStyle(fontSize: 13),
                        ),
                        Text(
                          "${order.total} đ",
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                      ],
                    ),
                    if (canPay)
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
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                            ),
                            onPressed: () {
                              // Xử lý thanh toán
                            },
                            icon: const Icon(Icons.payment, size: 18, color: Colors.white),
                            label: const Text("Thanh toán", style: TextStyle(fontSize: 15, color: Colors.white)),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
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
            style: TextStyle(fontSize: 18, color: Colors.blueGrey[700], fontWeight: FontWeight.bold),
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