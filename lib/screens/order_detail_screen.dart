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
      } else if (res.statusCode == 404) {
        setState(() {
          isLoading = false;
          errorMessage = "Không tìm thấy đơn hàng";
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

  // ====== Trạng thái (7 trạng thái mới) ======
  String _statusText(int? status) {
    switch (status) {
      case 1: return "Đang đến lấy hàng";
      case 2: return "Đang trên đường gửi hàng";
      case 3: return "Đã lấy hàng";
      case 4: return "Chờ lên máy bay";
      case 5: return "Chờ gửi hàng";
      case 6: return "Đang gửi hàng";
      case 7: return "Giao hàng thành công";
      default: return "Không xác định";
    }
  }

  String? _statusNote(int? status) {
    switch (status) {
      case 1: return "Đơn hàng đã được xác nhận";
      case 2: return "Đơn hàng đã được lấy";
      case 3: return "Đang xử lý đơn hàng tại kho";
      case 4: return "Xác minh đơn hàng và chi phí";
      case 5: return "Đơn hàng đang trên đường tới quốc gia xác nhận";
      case 6: return "Đã tới quốc gia xác nhận và đang tới điểm nhận";
      case 7: return null;
      default: return null;
    }
  }

  Color _getStatusColor(int? status) {
    switch (status) {
      case 1:
      case 2:
      case 3:
      case 4:
        return Colors.orange;
      case 5:
      case 6:
      case 7:
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
      case 4:
        return Icons.hourglass_top;
      case 5:
      case 6:
        return Icons.local_shipping;
      case 7:
        return Icons.check_circle;
      default:
        return Icons.help_outline;
    }
  }

  // ====== Tính tiền theo items và top-level ======
  double _toDouble(dynamic v) => (v is num) ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;

  double _calcTotalFromItems(Map<String, dynamic> o) {
    final items = (o['items'] as List?) ?? [];
    double total = 0.0;
    for (final itRaw in items) {
      final it = itRaw as Map<String, dynamic>;
      final amount = it['amount'];
      if (amount is num) {
        total += amount.toDouble();
        continue;
      }
      final price = _toDouble(it['price']);
      final weightReal = _toDouble(it['weightReal']);
      final weightEstimate = _toDouble(it['weightEstimate']);
      final weight = weightReal > 0 ? weightReal : weightEstimate;
      total += price * weight;
    }
    return total;
  }

  double _readDownPayment(Map<String, dynamic> o) => _toDouble(o['downPayment']);
  double _readWalletUsed(Map<String, dynamic> o) => _toDouble(o['payWithBalance']);

  String _fmtMoney(num v) => v.toStringAsFixed(0) + " đ";

  void _showStatusNote(BuildContext context, int? status) {
    final note = _statusNote(status);
    if (note == null) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_statusText(status)),
        content: Text(note),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text("Đóng")),
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
    final o = orderDetail!;
    final total = _calcTotalFromItems(o);
    final downPayment = _readDownPayment(o);
    final walletUsed = _readWalletUsed(o);
    final int? statusValue = o["status"] as int?;

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
                    "Mã đơn: ${o["orderCode"] ?? o["id"]}",
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
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _statusText(statusValue),
                    style: TextStyle(
                      color: _getStatusColor(statusValue),
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                    ),
                  ),
                  if (_statusNote(statusValue) != null) ...[
                    const SizedBox(width: 6),
                    InkWell(
                      onTap: () => _showStatusNote(context, statusValue),
                      child: Icon(Icons.info_outline, size: 18, color: _getStatusColor(statusValue)),
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Người gửi
            _buildSection("Người gửi", [
              _buildRow("Họ tên", o["senderName"]?.toString() ?? ""),
              _buildRow("SĐT", o["senderPhone"]?.toString() ?? ""),
              _buildRow("Địa chỉ", o["senderAddress"]?.toString() ?? ""),
            ]),
            const SizedBox(height: 16),

            // Người nhận
            _buildSection("Người nhận", [
              _buildRow("Họ tên", o["receiverName"]?.toString() ?? ""),
              _buildRow("SĐT", o["receiverPhone"]?.toString() ?? ""),
              _buildRow("Địa chỉ", o["receiverAddress"]?.toString() ?? ""),
            ]),
            const SizedBox(height: 16),

            // Mặt hàng
            _buildItemsSection(o),
            const SizedBox(height: 12),

            // Tiền cọc / ví / tổng
            _buildRow("Tiền cọc (QR)", _fmtMoney(downPayment), valueColor: Colors.orange),
            if (walletUsed > 0) _buildRow("Sử dụng ví", _fmtMoney(walletUsed), valueColor: Colors.orange),
            _buildRow("Tổng tiền", _fmtMoney(total), valueColor: Colors.green, bold: true),
          ],
        ),
      ),
    );
  }

  Widget _buildItemsSection(Map<String, dynamic> o) {
    final items = (o['items'] as List?) ?? [];
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text("Mặt hàng:", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        ...items.map((raw) {
          final it = raw as Map<String, dynamic>;
          final name = (it['name'] ?? '').toString();
          final unit = (it['unit'] ?? '').toString();
          final price = _toDouble(it['price']);
          final weightReal = _toDouble(it['weightReal']);
          final weightEstimate = _toDouble(it['weightEstimate']);
          final weight = weightReal > 0 ? weightReal : weightEstimate;
          final amount = (it['amount'] is num) ? (it['amount'] as num).toDouble() : price * weight;

          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                Expanded(child: Text(name)),
                Text("[${weight.toStringAsFixed(2)} $unit]"),
                const SizedBox(width: 8),
                Text("${price.toStringAsFixed(0)} đ/$unit", style: const TextStyle(color: Colors.green)),
                const SizedBox(width: 8),
                Text(_fmtMoney(amount), style: const TextStyle(fontWeight: FontWeight.bold)),
              ],
            ),
          );
        }).toList(),
      ],
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

  Widget _buildRow(String label, String value, {Color? valueColor, bool bold = false}) {
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