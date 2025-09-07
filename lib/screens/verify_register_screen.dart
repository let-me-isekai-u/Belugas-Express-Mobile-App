// import 'dart:async';
// import 'dart:convert';
// import 'package:flutter/material.dart';
// import 'package:begulas_express/services/api_service.dart';
//
// class VerifyRegisterScreen extends StatefulWidget {
//   final String email; // truyền email để gửi lại mã hoặc xác nhận
//
//   const VerifyRegisterScreen({Key? key, required this.email}) : super(key: key);
//
//   @override
//   State<VerifyRegisterScreen> createState() => _VerifyRegisterScreenState();
// }
//
// class _VerifyRegisterScreenState extends State<VerifyRegisterScreen> {
//   final _otpController = TextEditingController();
//   bool _isLoading = false;
//   bool _isResendAvailable = false;
//   int _secondsRemaining = 30;
//   Timer? _timer;
//
//   @override
//   void initState() {
//     super.initState();
//     _startResendCountdown();
//   }
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     _otpController.dispose();
//     super.dispose();
//   }
//
//   void _startResendCountdown() {
//     setState(() {
//       _isResendAvailable = false;
//       _secondsRemaining = 30;
//     });
//     _timer?.cancel();
//     _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
//       setState(() {
//         _secondsRemaining--;
//         if (_secondsRemaining <= 0) {
//           _isResendAvailable = true;
//           _timer?.cancel();
//         }
//       });
//     });
//   }
//
//   void _showSnackBar(String message, {Color color = Colors.red}) {
//     ScaffoldMessenger.of(context).showSnackBar(
//       SnackBar(
//         content: Text(message, style: const TextStyle(color: Colors.white)),
//         backgroundColor: color,
//         behavior: SnackBarBehavior.floating,
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
//       ),
//     );
//   }
//
//   /// Gọi API xác thực OTP thật
//   Future<void> _verifyOtp() async {
//     if (_otpController.text.isEmpty) {
//       _showSnackBar("Vui lòng nhập mã xác nhận!");
//       return;
//     }
//
//     setState(() => _isLoading = true);
//
//     try {
//       final response = await ApiService.verifyCode(
//         email: widget.email,
//         code: _otpController.text,
//       );
//
//       setState(() => _isLoading = false);
//
//       if (response.statusCode == 200) {
//         final data = jsonDecode(response.body);
//         _showSnackBar("Xác thực thành công!", color: Colors.green);
//         Navigator.popUntil(context, (route) => route.isFirst); // Trở về màn hình login
//       } else {
//         final error = jsonDecode(response.body);
//         _showSnackBar(error["message"] ?? "Mã xác nhận không hợp lệ!");
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//       _showSnackBar("Lỗi kết nối: $e");
//     }
//   }
//
//   /// Gọi API gửi lại mã xác nhận
//   Future<void> _resendOtp() async {
//     setState(() {
//       _isResendAvailable = false;
//       _secondsRemaining = 30;
//     });
//     _startResendCountdown();
//
//     try {
//       final response = await ApiService.resendCode(email: widget.email);
//       if (response.statusCode == 200) {
//         _showSnackBar("Đã gửi lại mã xác nhận về email!", color: Colors.blue);
//       } else {
//         final error = jsonDecode(response.body);
//         _showSnackBar(error["message"] ?? "Không gửi lại được mã xác nhận!");
//       }
//     } catch (e) {
//       _showSnackBar("Lỗi kết nối: $e");
//     }
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: Colors.blue[700],
//       body: SafeArea(
//         child: Center(
//           child: SingleChildScrollView(
//             padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
//             child: Column(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 const Icon(Icons.mark_email_read, size: 80, color: Colors.white),
//                 const SizedBox(height: 10),
//                 const Text(
//                   "Xác nhận đăng ký",
//                   style: TextStyle(
//                     fontFamily: 'Serif',
//                     color: Colors.white,
//                     fontSize: 28,
//                     fontWeight: FontWeight.bold,
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 Text(
//                   "Mã xác nhận đã được gửi tới email:",
//                   style: const TextStyle(color: Colors.white),
//                   textAlign: TextAlign.center,
//                 ),
//                 Text(
//                   widget.email,
//                   style: const TextStyle(
//                     color: Colors.yellow,
//                     fontWeight: FontWeight.bold,
//                   ),
//                   textAlign: TextAlign.center,
//                 ),
//                 const SizedBox(height: 25),
//                 Container(
//                   padding: const EdgeInsets.all(20),
//                   decoration: BoxDecoration(
//                     color: Colors.white,
//                     borderRadius: BorderRadius.circular(15),
//                     boxShadow: [
//                       BoxShadow(
//                         color: Colors.black.withOpacity(0.1),
//                         blurRadius: 8,
//                         offset: const Offset(0, 4),
//                       ),
//                     ],
//                   ),
//                   child: Column(
//                     children: [
//                       TextFormField(
//                         controller: _otpController,
//                         keyboardType: TextInputType.number,
//                         decoration: InputDecoration(
//                           labelText: "Nhập mã xác nhận",
//                           prefixIcon: Icon(Icons.numbers, color: Colors.blue[700]),
//                           border: OutlineInputBorder(
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                         ),
//                         maxLength: 6,
//                       ),
//                       const SizedBox(height: 18),
//                       SizedBox(
//                         width: double.infinity,
//                         child: ElevatedButton(
//                           onPressed: _isLoading ? null : _verifyOtp,
//                           style: ElevatedButton.styleFrom(
//                             backgroundColor: Colors.blue[400],
//                             padding: const EdgeInsets.symmetric(vertical: 14),
//                             shape: RoundedRectangleBorder(
//                               borderRadius: BorderRadius.circular(12),
//                             ),
//                             elevation: 3,
//                           ),
//                           child: _isLoading
//                               ? const SizedBox(
//                             height: 20,
//                             width: 20,
//                             child: CircularProgressIndicator(
//                                 strokeWidth: 2, color: Colors.white),
//                           )
//                               : const Text("Xác nhận", style: TextStyle(fontSize: 18)),
//                         ),
//                       ),
//                       const SizedBox(height: 10),
//                       TextButton.icon(
//                         onPressed: _isResendAvailable ? _resendOtp : null,
//                         icon: const Icon(Icons.refresh),
//                         label: _isResendAvailable
//                             ? const Text("Nhận lại mã")
//                             : Text("Nhận lại mã (${_secondsRemaining}s)"),
//                       ),
//                     ],
//                   ),
//                 ),
//                 const SizedBox(height: 16),
//                 TextButton(
//                   onPressed: () => Navigator.pop(context),
//                   child: const Text("Quay lại đăng ký", style: TextStyle(color: Colors.white)),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
