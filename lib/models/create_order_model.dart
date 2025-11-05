class OrderItemModel {
  int pricingTableId;
  String name;
  String unit;
  double weightEstimate;
  double price;

  OrderItemModel({
    required this.pricingTableId,
    required this.name,
    required this.unit,
    required this.weightEstimate,
    required this.price,
  });

  Map<String, dynamic> toJson() => {
    "pricingTableId": pricingTableId,
    "name": name,
    "unit": unit,
    "weightEstimate": weightEstimate,
    "price": price,
  };
}

class CreateOrderModel {
  String senderName;
  String senderPhone;
  String senderAddress;
  String receiverName;
  String receiverPhone;
  String receiverAddress;
  int countryId;
  double payWithBalance;
  double downPayment;
  List<OrderItemModel> orderItems;

  CreateOrderModel({
    required this.senderName,
    required this.senderPhone,
    required this.senderAddress,
    required this.receiverName,
    required this.receiverPhone,
    required this.receiverAddress,
    required this.countryId,
    required this.payWithBalance,
    required this.downPayment,
    required this.orderItems,
  });

  Map<String, dynamic> toJson() => {
    "senderName": senderName,
    "receiverName": receiverName,
    "senderPhone": senderPhone,
    "receiverPhone": receiverPhone,
    "senderAddress": senderAddress,
    "receiverAddress": receiverAddress,
    "countryId": countryId,
    "payWithBalance": payWithBalance,
    "downPayment": downPayment,
    "orderItems": orderItems.map((e) => e.toJson()).toList(),
  };
}