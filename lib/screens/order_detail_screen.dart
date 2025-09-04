import 'package:flutter/material.dart';
import 'order_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;
  const OrderDetailScreen({super.key, required this.order});

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
    final canPay = order.total > order.deposit;

    return Scaffold(
      backgroundColor: const Color(0xFFF6FAFF),
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        elevation: 0,
        title: const Text("Chi tiết đơn hàng"),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: const EdgeInsets.symmetric(vertical: 22, horizontal: 12),
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.white, Colors.blue[50]!],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.blue[100]!.withOpacity(0.18),
                  blurRadius: 22,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header trạng thái & mã đơn
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: _getStatusColor(order.status).withOpacity(0.15),
                      radius: 26,
                      child: Icon(
                        _getStatusIcon(order.status),
                        color: _getStatusColor(order.status),
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 18),
                    Expanded(
                      child: Text(
                        "Mã đơn: ${order.id}",
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 19,
                          letterSpacing: 0.7,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getStatusColor(order.status).withOpacity(0.12),
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Text(
                      order.status,
                      style: TextStyle(
                        color: _getStatusColor(order.status),
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 18),
                Divider(color: Colors.blue[100], thickness: 1, height: 1),
                const SizedBox(height: 18),
                // Người gửi
                _InfoSection(
                  title: "Người gửi",
                  children: [
                    _InfoRow(label: "Họ tên", value: order.senderName),
                    _InfoRow(label: "SĐT", value: order.senderPhone),
                    _InfoRow(label: "Địa chỉ", value: order.senderAddress),
                  ],
                ),
                const SizedBox(height: 18),
                Divider(color: Colors.blue[100], thickness: 1, height: 1),
                const SizedBox(height: 18),
                // Người nhận
                _InfoSection(
                  title: "Người nhận",
                  children: [
                    _InfoRow(label: "Họ tên", value: order.receiverName),
                    _InfoRow(label: "SĐT", value: order.receiverPhone),
                    _InfoRow(label: "Địa chỉ", value: order.receiverAddress),
                  ],
                ),
                const SizedBox(height: 18),
                Divider(color: Colors.blue[100], thickness: 1, height: 1),
                const SizedBox(height: 18),
                // Thông tin đơn hàng
                _InfoRow(
                  label: "Khối lượng",
                  value: "${order.weight} kg",
                  icon: Icons.inventory_2,
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  label: "Tiền cọc",
                  value: "${order.deposit} đ",
                  icon: Icons.savings,
                  valueStyle: const TextStyle(color: Colors.orange, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 10),
                _InfoRow(
                  label: "Tổng tiền",
                  value: "${order.total} đ",
                  icon: Icons.attach_money,
                  valueStyle: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 17),
                ),
                const SizedBox(height: 26),
                // Nút thanh toán
                if (canPay)
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[400],
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                        elevation: 0,
                      ),
                      icon: const Icon(Icons.payment, color: Colors.white, size: 20),
                      label: const Text(
                        "Thanh toán",
                        style: TextStyle(fontSize: 17, color: Colors.white),
                      ),
                      onPressed: () {
                        // Xử lý thanh toán
                      },
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

// Widget hiển thị từng dòng thông tin
class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData? icon;
  final TextStyle? valueStyle;
  const _InfoRow({
    required this.label,
    required this.value,
    this.icon,
    this.valueStyle,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        if (icon != null) ...[
          Icon(icon, color: Colors.blueGrey[400], size: 19),
          const SizedBox(width: 6),
        ],
        Text(
          "$label: ",
          style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 15),
        ),
        Expanded(
          child: Text(
            value,
            style: valueStyle ?? const TextStyle(fontSize: 15),
          ),
        ),
      ],
    );
  }
}

// Widget cho từng section thông tin
class _InfoSection extends StatelessWidget {
  final String title;
  final List<Widget> children;
  const _InfoSection({
    required this.title,
    required this.children,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.blueAccent,
          ),
        ),
        const SizedBox(height: 8),
        ...children,
      ],
    );
  }
}