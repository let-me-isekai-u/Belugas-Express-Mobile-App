import 'package:flutter/material.dart';

class Order {
  final int id;
  final String orderCode;
  final String senderName;
  final String senderPhone;
  final String senderAddress;
  final String receiverName;
  final String receiverPhone;
  final String receiverAddress;
  final int status;
  final DateTime createDate;

  final double downPayment; // tiền đã cọc (QR)
  final double payWithBalance; // tiền đã trừ từ ví
  final List<Map<String, dynamic>> items;

  Order({
    required this.id,
    required this.orderCode,
    required this.senderName,
    required this.senderPhone,
    required this.senderAddress,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverAddress,
    required this.status,
    required this.createDate,
    required this.downPayment,
    required this.payWithBalance,
    required this.items,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json["id"],
      orderCode: (json["orderCode"] ?? "").toString(),
      senderName: (json["senderName"] ?? "").toString(),
      senderPhone: (json["senderPhone"] ?? "").toString(),
      senderAddress: (json["senderAddress"] ?? "").toString(),
      receiverName: (json["receiverName"] ?? "").toString(),
      receiverPhone: (json["receiverPhone"] ?? "").toString(),
      receiverAddress: (json["receiverAddress"] ?? "").toString(),
      status: json["status"] ?? 0,
      createDate: DateTime.tryParse(json["createDate"]?.toString() ?? "") ?? DateTime.now(),
      downPayment: (json["downPayment"] is num) ? (json["downPayment"] as num).toDouble() : 0.0,
      payWithBalance: (json["payWithBalance"] is num) ? (json["payWithBalance"] as num).toDouble() : 0.0,
      items: (json["items"] is List) ? List<Map<String, dynamic>>.from(json["items"]) : const [],
    );
  }

  double _toDouble(dynamic v) => (v is num) ? v.toDouble() : double.tryParse(v?.toString() ?? '') ?? 0.0;

  double get total {
    double t = 0.0;
    for (final it in items) {
      final amount = it["amount"];
      if (amount is num) {
        t += amount.toDouble();
        continue;
      }
      final price = _toDouble(it["price"]);
      final wReal = _toDouble(it["weightReal"]);
      final wEst = _toDouble(it["weightEstimate"]);
      final w = wReal > 0 ? wReal : wEst;
      t += price * w;
    }
    return t;
  }

  double get remainingVsDownPayment => (total - downPayment) > 0 ? (total - downPayment) : 0.0;
  bool get canShowPayButton => status == 3 && total > downPayment;

  String get statusText {
    switch (status) {
      case 1: return "Đang đến lấy hàng";
      case 2: return "Đang trên đường lấy hàng";
      case 3: return "Đã lấy hàng";
      case 4: return "Chờ lên máy bay";
      case 5: return "Chờ gửi hàng";
      case 6: return "Đang gửi hàng";
      case 7: return "Giao hàng thành công";
      default: return "Không xác định";
    }
  }

  Color get statusColor {
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

  IconData get statusIcon {
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

  String? get statusNote {
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

  double get displayedDownPayment {
    if (status == 1 || status == 2 || status == 5 || status == 6 || status == 7) {
      return total;
    }
    return downPayment;
  }
}
