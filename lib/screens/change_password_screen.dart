import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String email; // nhận email từ ForgotPasswordScreen

  const ChangePasswordScreen({super.key, required this.email});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;
  bool _isLoading = false;

  // lưu lỗi để hiện custom
  String? _passwordError;
  String? _confirmError;

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    );
  }

  Future<void> _onConfirm() async {
    final pass = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    setState(() {
      _passwordError = null;
      _confirmError = null;
    });

    if (pass.isEmpty) {
      setState(() => _passwordError = "Vui lòng nhập mật khẩu mới");
      return;
    }
    if (pass.length < 8) {
      setState(() => _passwordError =
      "Mật khẩu phải ≥ 8 ký tự, gồm chữ hoa, chữ thường, số và ký tự đặc biệt");
      return;
    }
    if (confirm.isEmpty) {
      setState(() => _confirmError = "Vui lòng nhập lại mật khẩu");
      return;
    }
    if (pass != confirm) {
      setState(() => _confirmError = "Mật khẩu xác nhận không khớp");
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.forgotPassword(
        email: widget.email,
        newPassword: pass,
      );

      if (response.statusCode == 200) {
        _showSnackBar("Đổi mật khẩu thành công!", Colors.green);

        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => const LoginScreen()),
                (route) => false,
          );
        });
      } else if (response.statusCode == 400) {
        _showSnackBar("Tài khoản email này chưa được đăng ký!", Colors.red);
      } else {
        final error = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        _showSnackBar(error["message"] ?? "Đổi mật khẩu thất bại!", Colors.red);
      }
    } catch (e) {
      _showSnackBar("Lỗi kết nối: $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blue[700],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
            child: Column(
              children: [
                const Icon(Icons.lock, size: 80, color: Colors.white),
                const SizedBox(height: 12),
                const Text(
                  "Đổi mật khẩu",
                  style: TextStyle(
                    fontFamily: 'Serif',
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // Mật khẩu mới
                _buildPasswordField(
                  controller: passwordController,
                  hint: "Mật khẩu mới",
                  obscureText: _obscurePass,
                  onToggle: () => setState(() => _obscurePass = !_obscurePass),
                  errorText: _passwordError,
                ),
                const SizedBox(height: 20),

                // Xác nhận mật khẩu
                _buildPasswordField(
                  controller: confirmController,
                  hint: "Xác nhận mật khẩu",
                  obscureText: _obscureConfirm,
                  onToggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  errorText: _confirmError,
                ),
                const SizedBox(height: 25),

                // Nút xác nhận
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[400],
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: _isLoading
                        ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                        : const Text(
                      "Xác nhận",
                      style:
                      TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const LoginScreen()),
                    );
                  },
                  child: const Text(
                    "Quay về đăng nhập",
                    style: TextStyle(
                        color: Colors.black, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscureText,
    required VoidCallback onToggle,
    String? errorText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: controller,
          obscureText: obscureText,
          style: const TextStyle(color: Colors.black),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            hintText: hint,
            prefixIcon: const Icon(Icons.lock_outline, color: Colors.blue),
            suffixIcon: IconButton(
              icon: Icon(
                obscureText ? Icons.visibility_off : Icons.visibility,
                color: Colors.grey,
              ),
              onPressed: onToggle,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
          ),
        ),
        if (errorText != null)
          Padding(
            padding: const EdgeInsets.only(left: 8, top: 4),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.error, color: Colors.red, size: 18),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    errorText,
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
