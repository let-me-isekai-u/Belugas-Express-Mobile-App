import 'package:flutter/material.dart';

class CreateOrderScreen extends StatefulWidget {
  const CreateOrderScreen({super.key});

  @override
  State<CreateOrderScreen> createState() => _CreateOrderScreenState();
}

class _CreateOrderScreenState extends State<CreateOrderScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController senderPhoneController = TextEditingController();
  final TextEditingController senderNameController = TextEditingController();
  final TextEditingController senderAddressController = TextEditingController();

  final TextEditingController receiverPhoneController = TextEditingController();
  final TextEditingController receiverNameController = TextEditingController();
  final TextEditingController receiverAddressController = TextEditingController();

  final TextEditingController weightController = TextEditingController();

  String? selectedCountry;

  // Danh sách quốc gia + cờ
  final List<Map<String, String>> countries = [
    {"name": "Nhật Bản", "flag": "🇯🇵"},
    {"name": "Hàn Quốc", "flag": "🇰🇷"},
    {"name": "Trung Quốc", "flag": "🇨🇳"},
    {"name": "Đài Loan", "flag": "🇹🇼"},
    {"name": "Mỹ", "flag": "🇺🇸"},
    {"name": "Áo", "flag": "🇦🇹"},
    {"name": "Ba Lan", "flag": "🇵🇱"},
    {"name": "Bỉ", "flag": "🇧🇪"},
    {"name": "Bồ Đào Nha", "flag": "🇵🇹"},
    {"name": "Bulgaria", "flag": "🇧🇬"},
    {"name": "Croatia", "flag": "🇭🇷"},
    {"name": "Cộng hòa Síp", "flag": "🇨🇾"},
    {"name": "Cộng hòa Séc", "flag": "🇨🇿"},
    {"name": "Đan Mạch", "flag": "🇩🇰"},
    {"name": "Đức", "flag": "🇩🇪"},
    {"name": "Estonia", "flag": "🇪🇪"},
    {"name": "Pháp", "flag": "🇫🇷"},
    {"name": "Hy Lạp", "flag": "🇬🇷"},
    {"name": "Hà Lan", "flag": "🇳🇱"},
    {"name": "Hungary", "flag": "🇭🇺"},
    {"name": "Ireland", "flag": "🇮🇪"},
    {"name": "Ý", "flag": "🇮🇹"},
    {"name": "Latvia", "flag": "🇱🇻"},
    {"name": "Litva", "flag": "🇱🇹"},
    {"name": "Luxembourg", "flag": "🇱🇺"},
    {"name": "Malta", "flag": "🇲🇹"},
    {"name": "Phần Lan", "flag": "🇫🇮"},
    {"name": "Romania", "flag": "🇷🇴"},
    {"name": "Slovakia", "flag": "🇸🇰"},
    {"name": "Slovenia", "flag": "🇸🇮"},
    {"name": "Tây Ban Nha", "flag": "🇪🇸"},
    {"name": "Thụy Điển", "flag": "🇸🇪"},
  ];

  void _submitForm() {
    if (_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đơn hàng đã được tạo thành công")),
      );
      // TODO: lưu đơn hàng vào DB/API sau này
    }
  }

  Widget _buildSection({required String title, required List<Widget> children}) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    String? Function(String?)? validator,
    TextInputType inputType = TextInputType.text,
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
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Người gửi
              _buildSection(title: "Thông tin người gửi", children: [
                _buildTextField(
                  controller: senderPhoneController,
                  label: "Số điện thoại người gửi",
                  icon: Icons.phone,
                  inputType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? "Vui lòng nhập số điện thoại" : null,
                ),
                _buildTextField(
                  controller: senderNameController,
                  label: "Họ tên người gửi",
                  icon: Icons.person,
                  validator: (v) => v!.isEmpty ? "Vui lòng nhập họ tên" : null,
                ),
                _buildTextField(
                  controller: senderAddressController,
                  label: "Địa chỉ người gửi",
                  icon: Icons.location_on,
                  validator: (v) => v!.isEmpty ? "Vui lòng nhập địa chỉ" : null,
                ),
              ]),

              // Người nhận
              _buildSection(title: "Thông tin người nhận", children: [
                _buildTextField(
                  controller: receiverPhoneController,
                  label: "Số điện thoại người nhận",
                  icon: Icons.phone_android,
                  inputType: TextInputType.phone,
                  validator: (v) => v!.isEmpty ? "Vui lòng nhập số điện thoại" : null,
                ),
                _buildTextField(
                  controller: receiverNameController,
                  label: "Họ tên người nhận",
                  icon: Icons.person_outline,
                  validator: (v) => v!.isEmpty ? "Vui lòng nhập họ tên" : null,
                ),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    prefixIcon: const Icon(Icons.flag, color: Colors.blue),
                    labelText: "Quốc gia nhận",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  value: selectedCountry,
                  items: countries
                      .map((c) => DropdownMenuItem(
                    value: c["name"],
                    child: Row(
                      children: [
                        Text(c["flag"] ?? "", style: const TextStyle(fontSize: 20)),
                        const SizedBox(width: 8),
                        Text(c["name"] ?? ""),
                      ],
                    ),
                  ))
                      .toList(),
                  onChanged: (v) => setState(() => selectedCountry = v),
                  validator: (v) => v == null ? "Vui lòng chọn quốc gia" : null,
                ),
                const SizedBox(height: 12),
                _buildTextField(
                  controller: receiverAddressController,
                  label: "Địa chỉ người nhận",
                  icon: Icons.home,
                  validator: (v) => v!.isEmpty ? "Vui lòng nhập địa chỉ" : null,
                ),
              ]),

              // Đơn hàng
              _buildSection(title: "Thông tin đơn hàng", children: [
                _buildTextField(
                  controller: weightController,
                  label: "Khối lượng đơn hàng (kg)",
                  icon: Icons.inventory,
                  inputType: TextInputType.number,
                  validator: (v) {
                    if (v!.isEmpty) return "Vui lòng nhập khối lượng";
                    final w = double.tryParse(v);
                    if (w == null || w <= 0) return "Khối lượng không hợp lệ";
                    return null;
                  },
                ),
              ]),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _submitForm,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue[500],
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.check, color: Colors.white),
                  label: const Text("Xác nhận đơn hàng",
                      style: TextStyle(fontSize: 18, color: Colors.white)),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
