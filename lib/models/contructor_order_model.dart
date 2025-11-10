class ContructorOrderItem {
  final int id;
  final double weightEstimate;
  final double? weightReal;
  final double price;
  final double amount;
  final String name;
  final String unit;

  ContructorOrderItem({
    required this.id,
    required this.weightEstimate,
    this.weightReal,
    required this.price,
    required this.amount,
    required this.name,
    required this.unit,
  });

  factory ContructorOrderItem.fromJson(Map<String, dynamic> json) {
    return ContructorOrderItem(
      id: json['id'],
      weightEstimate: (json['weightEstimate'] ?? 0).toDouble(),
      weightReal: json['weightReal'] != null ? (json['weightReal'] as num?)?.toDouble() : null,
      price: (json['price'] ?? 0).toDouble(),
      amount: (json['amount'] ?? 0).toDouble(),
      name: json['name'] ?? '',
      unit: json['unit'] ?? '',
    );
  }
}

class ContructorOrderModel {
  final int id;
  final String orderCode;
  final String receiverName;
  final String receiverPhone;
  final String receiverAddress;
  final double downPayment;
  final int countryId;
  final int status;
  final DateTime createDate;
  final DateTime updateDate;
  final double payWithBalance;
  final List<ContructorOrderItem> items;

  ContructorOrderModel({
    required this.id,
    required this.orderCode,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverAddress,
    required this.downPayment,
    required this.countryId,
    required this.status,
    required this.createDate,
    required this.updateDate,
    required this.payWithBalance,
    required this.items,
  });

  factory ContructorOrderModel.fromJson(Map<String, dynamic> json) {
    return ContructorOrderModel(
      id: json['id'],
      orderCode: json['orderCode'] ?? '',
      receiverName: json['receiverName'] ?? '',
      receiverPhone: json['receiverPhone'] ?? '',
      receiverAddress: json['receiverAddress'] ?? '',
      downPayment: (json['downPayment'] ?? 0).toDouble(),
      countryId: json['countryId'] ?? 0,
      status: json['status'] ?? 0,
      createDate: DateTime.parse(json['createDate']),
      updateDate: DateTime.parse(json['updateDate']),
      payWithBalance: (json['payWithBalance'] ?? 0).toDouble(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((e) => ContructorOrderItem.fromJson(e))
          .toList(),
    );
  }
}