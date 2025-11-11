import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/create_order_model.dart';
import '../services/api_service.dart';
import 'confirm_order_screen.dart';
import '../l10n/app_localizations.dart';

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

  String? accessToken;
  int? userId;

  @override
  void initState() {
    super.initState();
    _resolveAccessToken();
    _fetchCountries();
  }

  Future<void> _resolveAccessToken() async {
    final prefs = await SharedPreferences.getInstance();
    accessToken = widget.accessToken ?? prefs.getString('accessToken') ?? '';
    userId = prefs.getInt('id');
    setState(() {});
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

  Widget _buildOrderItem(int index, AppLocalizations loc) {
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
                decoration: InputDecoration(
                  labelText: loc.createOrderItemType,
                  border: const OutlineInputBorder(),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
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
                  labelText: loc.createOrderItemWeight(item.unit),
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
                  if (val == null || val <= 0) return loc.createOrderErrorInvalidWeight;
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
                    tooltip: loc.createOrderItemRemove,
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

  void _onConfirmOrder(AppLocalizations loc) async {
    if (!_formKey.currentState!.validate()) {
      _showSnackBar(loc.createOrderErrorEmptyField, Colors.red);
      return;
    }
    if (selectedCountryId == null) {
      _showSnackBar(loc.createOrderErrorCountry, Colors.red);
      return;
    }
    if (orderItems.any((e) => e.weightEstimate <= 0)) {
      _showSnackBar(loc.createOrderErrorInvalidWeight, Colors.red);
      return;
    }
    if (orderItems.isEmpty) {
      _showSnackBar(loc.createOrderErrorNoItems, Colors.red);
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
      payWithBalance: 0,
      downPayment: getTotalOrderAmount(),
      orderItems: orderItems,
    );

    // 🔹 Gọi API 23 trước khi sang confirm screen
    double walletBalance = 0;
    try {
      final res = await ApiService.getWalletBalance(accessToken: accessToken ?? '');
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        walletBalance = (body['wallet'] as num).toDouble();
      } else {
        _showSnackBar(loc.createOrderErrorWalletFetch("${res.statusCode}"), Colors.red);
      }
    } catch (e) {
      _showSnackBar(loc.createOrderErrorWalletFetch("$e"), Colors.red);
    }

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
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[400],
        title: Text(loc.createOrderTitle, style: const TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                _buildSection(title: loc.createOrderSenderSection, children: [
                  _buildTextField(
                    controller: senderPhoneController,
                    label: loc.createOrderSenderPhone,
                    icon: Icons.phone,
                    inputType: TextInputType.phone,
                    validator: (v) => (v == null || v.trim().isEmpty) ? loc.createOrderErrorEmptyField : null,
                  ),
                  _buildTextField(
                    controller: senderNameController,
                    label: loc.createOrderSenderName,
                    icon: Icons.person,
                    validator: (v) => (v == null || v.trim().isEmpty) ? loc.createOrderErrorEmptyField : null,
                  ),
                  _buildTextField(
                    controller: senderAddressController,
                    label: loc.createOrderSenderAddress,
                    icon: Icons.location_on,
                    validator: (v) => (v == null || v.trim().isEmpty) ? loc.createOrderErrorEmptyField : null,
                  ),
                ]),
                _buildSection(title: loc.createOrderReceiverSection, children: [
                  _buildTextField(
                    controller: receiverPhoneController,
                    label: loc.createOrderReceiverPhone,
                    icon: Icons.phone_android,
                    inputType: TextInputType.phone,
                    validator: (v) => (v == null || v.trim().isEmpty) ? loc.createOrderErrorEmptyField : null,
                  ),
                  _buildTextField(
                    controller: receiverNameController,
                    label: loc.createOrderReceiverName,
                    icon: Icons.person_outline,
                    validator: (v) => (v == null || v.trim().isEmpty) ? loc.createOrderErrorEmptyField : null,
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
                        labelText: loc.createOrderReceiverCountry,
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
                          selectedCountryCode = countryList.firstWhere((e) => e['id'] == v)['code'];
                          orderItems.clear();
                        });
                        _fetchPricingTable(v!);
                      },
                      validator: (v) => (v == null) ? loc.createOrderErrorCountry : null,
                    ),
                  ),
                  _buildTextField(
                    controller: receiverAddressController,
                    label: loc.createOrderReceiverAddress,
                    icon: Icons.home,
                    validator: (v) => (v == null || v.trim().isEmpty) ? loc.createOrderErrorEmptyField : null,
                  ),
                ]),
                _buildSection(title: loc.createOrderItemsSection, children: [
                  if (isLoadingPricing)
                    const Center(child: CircularProgressIndicator())
                  else
                    ...orderItems.asMap().entries.map((e) => _buildOrderItem(e.key, loc)),
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
                      label: Text(loc.createOrderAddItem),
                    ),
                  )
                ]),
                const SizedBox(height: 18),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: () => _onConfirmOrder(loc),
                    icon: const Icon(Icons.check, color: Colors.white),
                    label: Text(loc.createOrderConfirmButton, style: const TextStyle(fontSize: 18)),
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