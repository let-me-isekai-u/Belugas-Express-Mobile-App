// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:shared_preferences/shared_preferences.dart';
// import '../services/api_service.dart';
// import 'order_detail_screen.dart';
//
// class CreateOrderScreen extends StatefulWidget {
//   final String? accessToken;
//   const CreateOrderScreen({Key? key, this.accessToken}) : super(key: key);
//
//   @override
//   State<CreateOrderScreen> createState() => _CreateOrderScreenState();
// }
//
// class _CreateOrderScreenState extends State<CreateOrderScreen> {
//   final _formKey = GlobalKey<FormState>();
//
//   final TextEditingController senderPhoneController = TextEditingController();
//   final TextEditingController senderNameController = TextEditingController();
//   final TextEditingController senderAddressController = TextEditingController();
//   final TextEditingController receiverPhoneController = TextEditingController();
//   final TextEditingController receiverNameController = TextEditingController();
//   final TextEditingController receiverAddressController = TextEditingController();
//   final TextEditingController weightController = TextEditingController();
//
//   String? selectedCountry;
//   double pricePerKilogram = 0.0;
//   bool isLoading = false;
//   bool isFeeLoading = false;
//   List<Map<String, dynamic>> feeList = [];
//
//   // QR & payment
//   bool showQR = false;
//   String qrUrl = "";
//   int countdown = 120; // 2 phút
//   Timer? countdownTimer;
//   Timer? pollTimer;
//   bool isWaitingPayment = false;
//   String paymentStatus = "";
//   double paymentAmount = 0.0;
//   String qrDescription = "";
//
//   String countryCodeToEmoji(String countryCode) {
//     return countryCode.toUpperCase().codeUnits
//         .map((c) => String.fromCharCode(0x1F1E6 - 65 + c))
//         .join();
//   }
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchFeeList();
//   }
//
//   @override
//   void dispose() {
//     senderPhoneController.dispose();
//     senderNameController.dispose();
//     senderAddressController.dispose();
//     receiverPhoneController.dispose();
//     receiverNameController.dispose();
//     receiverAddressController.dispose();
//     weightController.dispose();
//     countdownTimer?.cancel();
//     pollTimer?.cancel();
//     super.dispose();
//   }
//
//   Future<String?> _resolveAccessToken() async {
//     if (widget.accessToken != null && widget.accessToken!.isNotEmpty) {
//       return widget.accessToken;
//     }
//     final prefs = await SharedPreferences.getInstance();
//     final t = prefs.getString('accessToken') ?? '';
//     return t.isEmpty ? null : t;
//   }
//
//   Future<int?> _resolveUserId() async {
//     final prefs = await SharedPreferences.getInstance();
//     return prefs.getInt('id');
//   }
//
//   Future<void> _fetchFeeList() async {
//     setState(() => isFeeLoading = true);
//     try {
//       final res = await ApiService.getFee();
//       if (res.statusCode == 200) {
//         final parsed = jsonDecode(res.body);
//         if (parsed is List) {
//           feeList = parsed.map<Map<String, dynamic>>((e) {
//             return {
//               "countryName": e['countryName'] ?? '',
//               "flag": e['flag'] ?? '',
//               "pricePerKilogram": (e['pricePerKilogram'] is num)
//                   ? (e['pricePerKilogram'] as num).toDouble()
//                   : double.tryParse((e['pricePerKilogram'] ?? '0').toString()) ?? 0.0,
//             };
//           }).toList();
//
//           if (feeList.isNotEmpty) {
//             selectedCountry = feeList.first['countryName'];
//             pricePerKilogram = feeList.first['pricePerKilogram'] as double;
//           }
//           setState(() {});
//         } else {
//           _showSnackBar("API trả về dữ liệu không hợp lệ cho phí vận chuyển.", Colors.orange);
//         }
//       } else {
//         _showSnackBar("Không thể lấy đơn giá: ${res.statusCode}", Colors.red);
//       }
//     } catch (e) {
//       _showSnackBar("Lỗi kết nối khi lấy đơn giá: $e", Colors.red);
//     } finally {
//       setState(() => isFeeLoading = false);
//     }
//   }
//
//   void _showSnackBar(String message, Color color) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(content: Text(message, style: const TextStyle(color: Colors.white)), backgroundColor: color),
//     );
//   }
//
//   Future<void> _createOrder() async {
//     if (!_formKey.currentState!.validate()) return;
//
//     final token = await _resolveAccessToken();
//     if (token == null) {
//       _showSnackBar("Phiên đăng nhập không tồn tại. Vui lòng đăng nhập lại.", Colors.red);
//       return;
//     }
//
//     final userId = await _resolveUserId() ?? 0;
//
//     final weight = double.tryParse(weightController.text.trim()) ?? 0.0;
//     if (weight <= 0) {
//       _showSnackBar("Khối lượng không hợp lệ", Colors.red);
//       return;
//     }
//
//     if (pricePerKilogram <= 0) {
//       _showSnackBar("Không tìm thấy đơn giá cho quốc gia này!", Colors.red);
//       return;
//     }
//
//     final amount = weight * pricePerKilogram;
//     paymentAmount = amount;
//
//     final now = DateTime.now();
//     final timestamp = "${now.hour.toString().padLeft(2, '0')}"
//         "${now.minute.toString().padLeft(2, '0')}"
//         "${now.second.toString().padLeft(2, '0')}";
//     final description = "QR ${userId}${timestamp}";
//     qrDescription = description;
//
//     final qrImageUrl =
//         "https://img.vietqr.io/image/MB-34567200288888-compact2.png?amount=${amount.toStringAsFixed(0)}&addInfo=${description}&accountName=LY%20NHAT%20ANH";
//     qrUrl = qrImageUrl;
//
//     setState(() {
//       showQR = true;
//       countdown = 120;
//       isWaitingPayment = true;
//       paymentStatus = "";
//     });
//
//     countdownTimer?.cancel();
//     countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         countdown--;
//       });
//       if (countdown <= 0) {
//         timer.cancel();
//         pollTimer?.cancel();
//         setState(() {
//           isWaitingPayment = false;
//           paymentStatus = "⛔ Hết thời gian thanh toán. Giao dịch thất bại.";
//           showQR = false;
//         });
//         _showSnackBar("⛔ Hết thời gian thanh toán!", Colors.red);
//       }
//     });
//
//     // Đợi 5s rồi bắt đầu check giao dịch mỗi 5s
//     Future.delayed(const Duration(seconds: 5), () {
//       pollTimer?.cancel();
//       pollTimer = Timer.periodic(const Duration(seconds: 5), (poll) async {
//         final res = await ApiService.getLastTransactions();
//         if (res.statusCode == 200) {
//           try {
//             final parsed = jsonDecode(res.body);
//             final data = parsed['data'];
//             if (data is List) {
//               for (final row in data) {
//                 final transAmount = double.tryParse(row['values_0_2'].toString()) ?? 0;
//                 final content = row['values_0_9'].toString();
//                 if (transAmount == amount && content.contains(description)) {
//                   countdownTimer?.cancel();
//                   pollTimer?.cancel();
//                   setState(() {
//                     paymentStatus = "✅ Thanh toán thành công!";
//                     isWaitingPayment = false;
//                     showQR = false;
//                   });
//                   _showSnackBar("✅ Thanh toán thành công!", Colors.green);
//
//                   // Gọi API tạo đơn hàng
//                   _submitOrder(token, weight);
//
//                   return;
//                 }
//               }
//             }
//           } catch (_) {}
//         }
//       });
//     });
//   }
//
//   Future<void> _submitOrder(String token, double weight) async {
//     setState(() => isLoading = true);
//     try {
//       final res = await ApiService.createOrder(
//         accessToken: token,
//         weightEstimate: weight,
//         senderName: senderNameController.text.trim(),
//         receiverName: receiverNameController.text.trim(),
//         senderPhone: senderPhoneController.text.trim(),
//         receiverPhone: receiverPhoneController.text.trim(),
//         senderAddress: senderAddressController.text.trim(),
//         receiverAddress: receiverAddressController.text.trim(),
//         downPayment: paymentAmount,
//         pricePerKilogram: pricePerKilogram,
//         country: selectedCountry ?? '',
//       );
//
//       if (res.statusCode == 200) {
//         final body = jsonDecode(res.body);
//         if (body is Map && (body['success'] == true || res.body.contains('"orderCode"'))) {
//           final orderId = body['orderId'];
//           final code = body['orderCode'] ?? '';
//           _showSnackBar("Tạo đơn hàng thành công${code != null ? ': $code' : ''}", Colors.green);
//
//           if (orderId != null) {
//             Navigator.of(context).pushReplacement(
//               MaterialPageRoute(
//                 builder: (_) => OrderDetailScreen(orderId: orderId),
//               ),
//             );
//             return;
//           }
//
//           setState(() {
//             showQR = false;
//             isWaitingPayment = false;
//             paymentStatus = "";
//
//             senderPhoneController.clear();
//             senderNameController.clear();
//             senderAddressController.clear();
//             receiverPhoneController.clear();
//             receiverNameController.clear();
//             receiverAddressController.clear();
//             weightController.clear();
//           });
//         } else {
//           final msg = (body is Map && body['message'] != null) ? body['message'] : "Tạo đơn không thành công";
//           _showSnackBar(msg.toString(), Colors.orange);
//         }
//       } else if (res.statusCode == 401) {
//         _showSnackBar("Phiên đăng nhập hết hạn. Vui lòng đăng nhập lại.", Colors.red);
//       } else {
//         _showSnackBar("Lỗi khi tạo đơn: ${res.statusCode}", Colors.red);
//       }
//     } catch (e) {
//       _showSnackBar("Lỗi kết nối: $e", Colors.red);
//     } finally {
//       setState(() => isLoading = false);
//     }
//   }
//
//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String label,
//     required IconData icon,
//     TextInputType inputType = TextInputType.text,
//     String? Function(String?)? validator,
//     String? hintText,
//   }) {
//     return Padding(
//       padding: const EdgeInsets.only(bottom: 12),
//       child: TextFormField(
//         controller: controller,
//         keyboardType: inputType,
//         validator: validator,
//         decoration: InputDecoration(
//           prefixIcon: Icon(icon, color: Colors.blue),
//           labelText: label,
//           hintText: hintText,
//           border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//           contentPadding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
//         ),
//       ),
//     );
//   }
//
//   Widget _buildSection({required String title, required List<Widget> children}) {
//     return Card(
//       margin: const EdgeInsets.symmetric(vertical: 10),
//       elevation: 3,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//       child: Padding(
//         padding: const EdgeInsets.all(14),
//         child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
//           Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
//           const SizedBox(height: 10),
//           ...children,
//         ]),
//       ),
//     );
//   }
//
//   Widget _buildQRSection() {
//     return Dialog(
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//       child: Padding(
//
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text("Quét mã QR để chuyển khoản", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Colors.blue)),
//             const SizedBox(height: 16),
//             Image.network(qrUrl, height: 280, width: 280, fit: BoxFit.contain),
//             const SizedBox(height: 10),
//             Text(
//               "Số tiền: ${paymentAmount.toStringAsFixed(0)} VND",
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//             Text(
//               "Nội dung: $qrDescription",
//               style: const TextStyle(color: Colors.orange, fontSize: 16),
//             ),
//             const SizedBox(height: 10),
//             Text(
//               "Thời gian còn lại: ${countdown ~/ 60}:${(countdown % 60).toString().padLeft(2, '0')}",
//               style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red, fontSize: 18),
//             ),
//             const SizedBox(height: 8),
//             if (isWaitingPayment)
//               const Text(
//                 "Sau khi chuyển khoản, hệ thống sẽ kiểm tra tự động.\nVui lòng không tắt màn hình khi chưa xác nhận.",
//                 style: TextStyle(fontSize: 13, color: Colors.grey),
//                 textAlign: TextAlign.center,
//               ),
//             if (paymentStatus.isNotEmpty)
//               Padding(
//                 padding: const EdgeInsets.symmetric(vertical: 5),
//                 child: Text(
//                   paymentStatus,
//                   style: TextStyle(
//                     fontWeight: FontWeight.bold,
//                     color: paymentStatus.contains("thành công") ? Colors.green : Colors.red,
//                     fontSize: 15,
//                   ),
//                 ),
//               ),
//             const SizedBox(height: 10),
//             TextButton.icon(
//               onPressed: () {
//                 countdownTimer?.cancel();
//                 pollTimer?.cancel();
//                 setState(() {
//                   showQR = false;
//                   isWaitingPayment = false;
//                   paymentStatus = "";
//                 });
//               },
//               icon: const Icon(Icons.close, color: Colors.red),
//               label: const Text("Đóng mã QR", style: TextStyle(color: Colors.red)),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.grey[100],
//       appBar: AppBar(
//         backgroundColor: Colors.blue[400],
//         title: const Text("Tạo đơn hàng", style: TextStyle(color: Colors.white)),
//         centerTitle: true,
//       ),
//       body: Stack(
//         children: [
//           SafeArea(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(16),
//               child: Form(
//                 key: _formKey,
//                 child: Column(
//                   children: [
//                     _buildSection(title: "Thông tin người gửi", children: [
//                       _buildTextField(
//                         controller: senderPhoneController,
//                         label: "Số điện thoại người gửi",
//                         icon: Icons.phone,
//                         inputType: TextInputType.phone,
//                         validator: (v) => (v == null || v.trim().isEmpty) ? "Vui lòng nhập số điện thoại" : null,
//                       ),
//                       _buildTextField(
//                         controller: senderNameController,
//                         label: "Họ tên người gửi",
//                         icon: Icons.person,
//                         validator: (v) => (v == null || v.trim().isEmpty) ? "Vui lòng nhập họ tên" : null,
//                       ),
//                       _buildTextField(
//                         controller: senderAddressController,
//                         label: "Địa chỉ lấy hàng",
//                         icon: Icons.location_on,
//                         validator: (v) => (v == null || v.trim().isEmpty) ? "Vui lòng nhập địa chỉ" : null,
//                       ),
//                     ]),
//                     _buildSection(title: "Thông tin người nhận", children: [
//                       _buildTextField(
//                         controller: receiverPhoneController,
//                         label: "Số điện thoại người nhận",
//                         icon: Icons.phone_android,
//                         inputType: TextInputType.phone,
//                         validator: (v) => (v == null || v.trim().isEmpty) ? "Vui lòng nhập số điện thoại" : null,
//                       ),
//                       _buildTextField(
//                         controller: receiverNameController,
//                         label: "Họ tên người nhận",
//                         icon: Icons.person_outline,
//                         validator: (v) => (v == null || v.trim().isEmpty) ? "Vui lòng nhập họ tên" : null,
//                       ),
//                       Padding(
//                         padding: const EdgeInsets.only(bottom: 12),
//                         child: DropdownButtonFormField<String>(
//                           decoration: InputDecoration(
//                             prefixIcon: const Icon(Icons.flag, color: Colors.blue),
//                             labelText: "Quốc gia nhận",
//                             border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
//                           ),
//                           value: selectedCountry,
//                           items: feeList
//                               .map((c) => DropdownMenuItem<String>(
//                             value: c['countryName'],
//                             child: Row(
//                               children: [
//                                 Text(
//                                   countryCodeToEmoji(c['flag'] ?? ''),
//                                   style: const TextStyle(fontSize: 20),
//                                 ),
//                                 const SizedBox(width: 8),
//                                 Text(c['countryName'] ?? ''),
//                               ],
//                             ),
//                           ))
//                               .toList(),
//                           onChanged: (v) {
//                             setState(() => selectedCountry = v);
//                             final found = feeList.firstWhere((f) => f['countryName'] == v, orElse: () => {});
//                             setState(() {
//                               pricePerKilogram = found.isNotEmpty ? found['pricePerKilogram'] as double : 0.0;
//                             });
//                           },
//                           validator: (v) => (v == null || v.isEmpty) ? "Vui lòng chọn quốc gia" : null,
//                         ),
//                       ),
//                       _buildTextField(
//                         controller: receiverAddressController,
//                         label: "Địa chỉ người nhận",
//                         icon: Icons.home,
//                         validator: (v) => (v == null || v.trim().isEmpty) ? "Vui lòng nhập địa chỉ" : null,
//                       ),
//                     ]),
//                     _buildSection(title: "Thông tin đơn hàng", children: [
//                       _buildTextField(
//                         controller: weightController,
//                         label: "Khối lượng đơn hàng (kg)",
//                         icon: Icons.inventory,
//                         inputType: TextInputType.numberWithOptions(decimal: true),
//                         validator: (v) {
//                           if (v == null || v.trim().isEmpty) return "Vui lòng nhập khối lượng";
//                           final w = double.tryParse(v);
//                           if (w == null || w <= 0) return "Khối lượng không hợp lệ";
//                           return null;
//                         },
//                       ),
//                       const SizedBox(height: 6),
//                       Text(
//                         pricePerKilogram > 0
//                             ? "Đơn giá: ${pricePerKilogram.toStringAsFixed(0)} VND/kg"
//                             : "Chưa có đơn giá",
//                         style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 16),
//                       ),
//                     ]),
//                     const SizedBox(height: 18),
//                     SizedBox(
//                       width: double.infinity,
//                       child: ElevatedButton.icon(
//                         onPressed: isLoading || isWaitingPayment || showQR ? null : _createOrder,
//                         icon: const Icon(Icons.check, color: Colors.white),
//                         label: isLoading
//                             ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                             : const Text("Xác nhận đơn hàng", style: TextStyle(fontSize: 18)),
//                         style: ElevatedButton.styleFrom(
//                           backgroundColor: Colors.blue[500],
//                           padding: const EdgeInsets.symmetric(vertical: 14),
//                           shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           if (showQR)
//             Center(
//               child: _buildQRSection(),
//             ),
//         ],
//       ),
//     );
//   }
// }