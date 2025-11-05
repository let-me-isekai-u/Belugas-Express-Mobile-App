import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/create_order_model.dart';
import '../services/api_service.dart';
import 'confirm_order_screen.dart';

class CreateOrderScreen extends StatefulWidget {
  final String? accessToken;
  const CreateOrderScreen({Key? key, this.accessToken}) : super(key: key);

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  final senderPhoneController = TextEditingController();
  final senderNameController = TextEditingController();
  final senderAddressController = TextEditingController();
  final receiverPhoneController = TextEditingController();
  final receiverNameController = TextEditingController();
  final receiverAddressController = TextEditingController();

  List<Map<String, dynamic>> countryList = [];
  int? selectedCountryId;
  String? selectedCountryCode;
  bool isLoadingCountry = false;

  List<Map<String, dynamic>> pricingTable = [];
  bool isLoadingPricing = false;

  List<OrderItemModel> orderItems = [];

  bool useWallet = false;
  double walletBalance = 0.0;

  String? accessToken;
  int? userId;

  @override
  void initState() {
    super.initState();
    _resolveAccessToken();
    _fetchCountries();
    WidgetsBinding.instance.addPostFrameCallback((_) => _getWalletFromProfile());
  }

  Future<void> _resolveAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = widget.accessToken ?? prefs.getString('accessToken') ?? '';
    userId = prefs.getInt('id');
    setState(() {});
    if (accessToken != null && accessToken!.isNotEmpty) {
      await _getWalletFromProfile();
    }
  }

  Future<void> _fetchCountries() async {
    setState(() => isLoadingCountry = true);
    final res = await ApiService.getCountries();
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body);
      if (list is List) {
        countryList = List<Map<String, dynamic>>.from(list);
        if (countryList.isNotEmpty) {
          selectedCountryId = countryList.first['id'];
          selectedCountryCode = countryList.first['code'];
          _fetchPricingTable(selectedCountryId!);
        }
      }
    }
    setState(() => isLoadingCountry = false);
  }

  Future<void> _fetchPricingTable(int countryId) async {
    setState(() => isLoadingPricing = true);
    final res = await ApiService.getPricingTable(countryId: countryId);
    if (res.statusCode == 200) {
      final list = jsonDecode(res.body);
      if (list is List) {
        pricingTable = List<Map<String, dynamic>>.from(list);
        if (orderItems.isEmpty && pricingTable.isNotEmpty) {
          orderItems.add(OrderItemModel(
            pricingTableId: pricingTable.first['id'],
            name: pricingTable.first['name'],
            unit: pricingTable.first['unit'],
            weightEstimate: 0,
            price: (pricingTable.first['pricePerKilogram'] as num).toDouble(),
          ));
        }
      }
    }
    setState(() => isLoadingPricing = false);
  }

  Future<void> _getWalletFromProfile() async {
    if (accessToken == null || accessToken!.isEmpty) return;
    final res = await ApiService.getProfile(accessToken: accessToken!);
    if (res.statusCode == 200) {
      final parsed = jsonDecode(res.body);
      walletBalance = (parsed['wallet'] is num) ? (parsed['wallet'] as num).toDouble() : 0.0;
      setState(() {});
    }
  }

  String countryCodeToEmoji(String countryCode) {
    return countryCode.toUpperCase().codeUnits
        .map((c) => String.fromCharCode(0x1F1E6 - 65 + c))
        .join();
  }

  double getTotalOrderAmount() {
    double total = 0;
    for (final item in orderItems) {
      total += item.weightEstimate * item.price;
    }
    return total;
  }

  double getDownPayment() {
    double total = getTotalOrderAmount();
    if (useWallet) {
      return (total - walletBalance).clamp(0, total);
    }
    return total;
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType inputType = TextInputType.text,
    String? Function(String?)? validator,
    String? hintText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextFormField(
        controller: controller,
        keyboardType: inputType,
        validator: validator,
        decoration: InputDecoration(
          prefixIcon: Icon(icon, color: Colors.blue),
          labelText: label,
          hintText: hintText,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
          contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
        ),
      ),
    );
  }

  Widget _buildOrderItem(int index) {
    final item = orderItems[index];
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Flexible(
              flex: 3,
              child: DropdownButtonFormField<int>(
                isExpanded: true,
                decoration: const InputDecoration(
                  labelText: "Loại hàng",
                  border: OutlineInputBorder(),
                  contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                ),
                value: item.pricingTableId,
                items: pricingTable
                    .map((e) => DropdownMenuItem<int>(
                  value: e['id'],
                  child: Text(
                    e['name'] ?? "",
                    style: const TextStyle(fontSize: 14),
                  ),
                ))
                    .toList(),
                onChanged: (v) {
                  final found = pricingTable.firstWhere((f) => f['id'] == v, orElse: () => {});
                  setState(() {
                    item.pricingTableId = found['id'] ?? item.pricingTableId;
                    item.name = found['name'] ?? item.name;
                    item.unit = found['unit'] ?? item.unit;
                    item.price = (found['pricePerKilogram'] is num)
                        ? (found['pricePerKilogram'] as num).toDouble()
                        : item.price;
                  });
                },
              ),
            ),
            const SizedBox(width: 10),
            Flexible(
              flex: 2,
              child: TextFormField(
                initialValue: item.weightEstimate > 0 ? item.weightEstimate.toString() : "",
                decoration: InputDecoration(
                  labelText: item.unit == "kg" ? "Kg" : item.unit,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                ),
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                onChanged: (v) {
                  final val = double.tryParse(v) ?? 0;
                  setState(() => item.weightEstimate = val);
                },
                validator: (v) {
                  final val = double.tryParse(v ?? "");
                  if (val == null || val <= 0) return "Nhập số lượng hợp lệ";
                  return null;
                },
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: 96,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    "${item.price.toStringAsFixed(0)}đ/${item.unit}",
                    style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.red, size: 20),
                    onPressed: orderItems.length > 1
                        ? () {
                      setState(() => orderItems.removeAt(index));
                    }
                        : null,
                    tooltip: "Xoá mặt hàng",
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
          const SizedBox(height: 10),
          ...children,
        ]),
      ),
    );
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)), backgroundColor: color),
    );
  }

  void _onConfirmOrder() async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar("Vui lòng kiểm tra lại thông tin!", Colors.red);
      return;
    }
    if (selectedCountryId == null) {
      _showSnackBar("Vui lòng chọn quốc gia!", Colors.red);
      return;
    }
    if (orderItems.any((e) => e.weightEstimate <= 0)) {
      _showSnackBar("Vui lòng nhập số lượng hợp lệ cho mỗi mặt hàng!", Colors.red);
      return;
    }
    if (orderItems.isEmpty) {
      _showSnackBar("Đơn hàng phải có ít nhất một mặt hàng!", Colors.red);
      return;
    }
    final model = CreateOrderModel(
      senderName: senderNameController.text.trim(),
      senderPhone: senderPhoneController.text.trim(),
      senderAddress: senderAddressController.text.trim(),
      receiverName: receiverNameController.text.trim(),
      receiverPhone: receiverPhoneController.text.trim(),
      receiverAddress: receiverAddressController.text.trim(),
      countryId: selectedCountryId!,
      payWithBalance: useWallet ? walletBalance : 0,
      downPayment: getDownPayment(),
      orderItems: orderItems,
    );
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ConfirmOrderScreen(
          accessToken: accessToken ?? '',
          userId: userId ?? 0,
          orderModel: model,
          countryCode: selectedCountryCode ?? '',
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
        title: const Text("Tạo đơn hàng", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildSection(title: "Thông tin người gửi", children: [
                  _buildTextField(
                    controller: senderPhoneController,
                    label: "Số điện thoại người gửi",
                    icon: Icons.phone,
                    inputType: TextInputType.phone,
                    validator: (v) => (v == null || v.trim().isEmpty) ? "Vui lòng nhập số điện thoại" : null,
                  ),
                  _buildTextField(
                    controller: senderNameController,
                    label: "Họ tên người gửi",
                    icon: Icons.person,
                    validator: (v) => (v == null || v.trim().isEmpty) ? "Vui lòng nhập họ tên" : null,
                  ),
                  _buildTextField(
                    controller: senderAddressController,
                    label: "Địa chỉ lấy hàng",
                    icon: Icons.location_on,
                    validator: (v) => (v == null || v.trim().isEmpty) ? "Vui lòng nhập địa chỉ" : null,
                  ),
                ]),
                _buildSection(title: "Thông tin người nhận", children: [
                  _buildTextField(
                    controller: receiverPhoneController,
                    label: "Số điện thoại người nhận",
                    icon: Icons.phone_android,
                    inputType: TextInputType.phone,
                    validator: (v) => (v == null || v.trim().isEmpty) ? "Vui lòng nhập số điện thoại" : null,
                  ),
                  _buildTextField(
                    controller: receiverNameController,
                    label: "Họ tên người nhận",
                    icon: Icons.person_outline,
                    validator: (v) => (v == null || v.trim().isEmpty) ? "Vui lòng nhập họ tên" : null,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: isLoadingCountry
                        ? const Center(child: CircularProgressIndicator())
                        : DropdownButtonFormField<int>(
                      isExpanded: true,
                      decoration: InputDecoration(
                        prefixIcon: selectedCountryCode != null
                            ? Text(countryCodeToEmoji(selectedCountryCode!), style: const TextStyle(fontSize: 20))
                            : const Icon(Icons.flag, color: Colors.blue),
                        labelText: "Quốc gia nhận",
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                      value: selectedCountryId,
                      items: countryList
                          .map((c) => DropdownMenuItem<int>(
                        value: c['id'],
                        child: Row(
                          children: [
                            Text(
                              countryCodeToEmoji(c['code'] ?? ''),
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 8),
                            Text(c['name'] ?? ''),
                          ],
                        ),
                      ))
                          .toList(),
                      onChanged: (v) {
                        setState(() {
                          selectedCountryId = v;
                          selectedCountryCode =
                          countryList.firstWhere((e) => e['id'] == v)['code'];
                          orderItems.clear();
                        });
                        _fetchPricingTable(v!);
                      },
                      validator: (v) => (v == null) ? "Vui lòng chọn quốc gia" : null,
                    ),
                  ),
                  _buildTextField(
                    controller: receiverAddressController,
                    label: "Địa chỉ người nhận",
                    icon: Icons.home,
                    validator: (v) => (v == null || v.trim().isEmpty) ? "Vui lòng nhập địa chỉ" : null,
                  ),
                ]),
                _buildSection(title: "Thông tin mặt hàng", children: [
                  if (isLoadingPricing)
                    const Center(child: CircularProgressIndicator())
                  else
                    ...orderItems.asMap().entries.map((e) => _buildOrderItem(e.key)),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: pricingTable.isNotEmpty
                          ? () {
                        setState(() {
                          orderItems.add(OrderItemModel(
                            pricingTableId: pricingTable.first['id'],
                            name: pricingTable.first['name'],
                            unit: pricingTable.first['unit'],
                            weightEstimate: 0,
                            price: (pricingTable.first['pricePerKilogram'] as num).toDouble(),
                          ));
                        });
                      }
                          : null,
                      icon: const Icon(Icons.add_box, color: Colors.blue),
                      label: const Text("Thêm mặt hàng"),
                    ),
                  )
                ]),
                _buildSection(title: "Thanh toán", children: [
                  Row(
                    children: [
                      Checkbox(
                        value: useWallet,
                        onChanged: (v) async {
                          setState(() => useWallet = v ?? false);
                          if (v == true) {
                            await _getWalletFromProfile();
                          }
                        },
                      ),
                      const Text("Sử dụng ví thanh toán"),
                      const SizedBox(width: 10),
                      if (useWallet)
                        Expanded(
                          child: Text(
                            "Số dư ví: ${walletBalance.toStringAsFixed(0)}đ",
                            style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                          ),
                        ),
                    ],
                  ),
                  Text(
                    "Tổng tiền đơn hàng: ${getTotalOrderAmount().toStringAsFixed(0)}đ",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16),
                  ),
                  Text(
                    "Tiền cần chuyển khoản: ${getDownPayment().toStringAsFixed(0)}đ",
                    style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 16),
                  ),
                ]),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _onConfirmOrder,
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: const Text("Xác nhận đơn hàng", style: TextStyle(fontSize: 18)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[500],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
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
