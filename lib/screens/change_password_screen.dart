import 'package:flutter/material.dart';
import 'login_screen.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmController = TextEditingController();

  bool _obscurePass = true;
  bool _obscureConfirm = true;

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
                ),
                const SizedBox(height: 20),

                // Xác nhận mật khẩu
                _buildPasswordField(
                  controller: confirmController,
                  hint: "Xác nhận mật khẩu",
                  obscureText: _obscureConfirm,
                  onToggle: () => setState(() => _obscureConfirm = !_obscureConfirm),
                ),
                const SizedBox(height: 25),

                // Nút xác nhận
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _onConfirm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[400],
                      padding: const EdgeInsets.symmetric(vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                    ),
                    child: const Text(
                      "Xác nhận",
                      style: TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(height: 20),

                // TextButton(
                //   onPressed: () => Navigator.pop(context),
                //   child: const Text(
                //     "Quay lại",
                //     style: TextStyle(color: Colors.white, fontSize: 15),
                //   ),
                // ),
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
  }) {
    return TextField(
      controller: controller,
      obscureText: obscureText,
      style: const TextStyle(color: Colors.black),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[50],
        hintText: hint,
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.blue),
        suffixIcon: IconButton(
          icon: Icon(obscureText ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey),
          onPressed: onToggle,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _onConfirm() {
    final pass = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    if (pass.isEmpty || confirm.isEmpty) {
      _showSnackBar("Vui lòng nhập đầy đủ thông tin", Colors.red);
      return;
    }
    if (pass.length < 6) {
      _showSnackBar("Mật khẩu phải có ít nhất 6 ký tự", Colors.red);
      return;
    }
    if (pass != confirm) {
      _showSnackBar("Mật khẩu xác nhận không khớp", Colors.red);
      return;
    }

    _showSnackBar("Đổi mật khẩu thành công!", Colors.green);

    // Sau khi đổi mật khẩu, quay lại login
    Future.delayed(const Duration(seconds: 2), () {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
            (route) => false,
      );
    });
  }
}
