import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'register_screen.dart';
import 'terms_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;
  bool _isSendingCode = false;
  bool _agreeTerms = false;

  int _countdown = 0;
  Timer? _timer;

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  void _startCountdown() {
    setState(() => _countdown = 60);
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown == 0) {
        timer.cancel();
      } else {
        setState(() => _countdown--);
      }
    });
  }

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

  Future<void> _sendCode() async {
    if (_emailController.text.trim().isEmpty) {
      _showSnackBar("Vui lòng nhập email trước khi nhận mã", Colors.orange);
      return;
    }

    setState(() => _isSendingCode = true);

    try {
      final response = await ApiService.sendVerificationCode(
        email: _emailController.text.trim(),
      );

      if (response.statusCode == 200) {
        _showSnackBar("Đã gửi mã xác nhận về email!", Colors.blue);
        _startCountdown();
      } else if (response.statusCode == 500) {
        _showSnackBar("Internal Server Error: Lỗi khi gửi email, vui lòng thử lại", Colors.red);
      } else {
        final errorMsg = response.body.isNotEmpty ? response.body : "Gửi mã thất bại!";
        _showSnackBar(errorMsg, Colors.red);
      }
    } catch (e) {
      _showSnackBar("Lỗi kết nối: $e", Colors.red);
    } finally {
      setState(() => _isSendingCode = false);
    }
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      _showSnackBar("Bạn cần đồng ý với điều khoản sử dụng", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        code: _codeController.text.trim(),
      );

      if (response.statusCode == 200) {
        _showSnackBar("Đăng ký thành công!", Colors.green);
        Navigator.pop(context);
      } else if (response.statusCode == 409) {
        _showSnackBar("Email hoặc số điện thoại đã được đăng ký", Colors.red);
      } else if (response.statusCode == 400) {
        _showSnackBar("Dữ liệu truyền vào không hợp lệ (có trường bị trống)", Colors.red);
      } else if (response.statusCode == 401) {
        _showSnackBar("Mã xác nhận không hợp lệ hoặc đã hết hạn", Colors.red);
      } else {
        final errorMsg = response.body.isNotEmpty ? response.body : "Đăng ký thất bại!";
        _showSnackBar(errorMsg, Colors.red);
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
                const Icon(Icons.app_registration, size: 80, color: Colors.white),
                const SizedBox(height: 12),
                const Text(
                  "Begulas Express",
                  style: TextStyle(
                    fontFamily: 'Serif',
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

                // Form đăng ký
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        _buildTextField(
                          controller: _nameController,
                          hint: "Tên",
                          icon: Icons.person,
                          validator: (v) => v == null || v.isEmpty ? "Vui lòng nhập tên" : null,
                        ),
                        const SizedBox(height: 15),

                        _buildTextField(
                          controller: _emailController,
                          hint: "Email",
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Vui lòng nhập email";
                            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                            if (!emailRegex.hasMatch(value)) return "Email không hợp lệ";
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        _buildPasswordField(
                          controller: _passwordController,
                          hint: "Mật khẩu",
                          obscure: _obscurePassword,
                          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        const SizedBox(height: 15),

                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          hint: "Xác nhận mật khẩu",
                          obscure: _obscureConfirmPassword,
                          onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Vui lòng xác nhận mật khẩu";
                            if (value != _passwordController.text) return "Mật khẩu không khớp";
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        _buildTextField(
                          controller: _phoneController,
                          hint: "Số điện thoại",
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) return "Vui lòng nhập số điện thoại";
                            if (!RegExp(r'^[0-9]{9,11}$').hasMatch(value)) return "Số điện thoại không hợp lệ";
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        // OTP + nút nhận mã
                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _codeController,
                                hint: "Mã xác nhận",
                                icon: Icons.verified,
                                keyboardType: TextInputType.number,
                                validator: (v) => v == null || v.isEmpty ? "Nhập mã xác nhận" : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: (_isSendingCode || _countdown > 0) ? null : _sendCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              child: _isSendingCode
                                  ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                                  : Text(_countdown > 0 ? "Gửi lại ($_countdown)" : "Nhận mã"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // Checkbox điều khoản
                        Row(
                          children: [
                            Checkbox(
                              value: _agreeTerms,
                              onChanged: (val) => setState(() => _agreeTerms = val ?? false),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(builder: (_) => const TermsScreen()),
                                  );
                                },
                                child: const Text.rich(
                                  TextSpan(
                                    text: "Tôi đồng ý với ",
                                    children: [
                                      TextSpan(
                                        text: "Điều khoản sử dụng",
                                        style: TextStyle(
                                          color: Colors.blue,
                                          decoration: TextDecoration.underline,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Nút Đăng ký
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: _agreeTerms ? Colors.blue[400] : Colors.grey,
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              elevation: 3,
                            ),
                            onPressed: (_isLoading || !_agreeTerms) ? null : _register,
                            child: _isLoading
                                ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                            )
                                : const Text("Đăng ký", style: TextStyle(fontSize: 18)),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text("Đã có tài khoản? Đăng nhập"),
                        ),
                      ],
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

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[50],
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue[700]),
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
        errorMaxLines: 3,
      ),
      validator: validator,
    );
  }

  Widget _buildPasswordField({
    required TextEditingController controller,
    required String hint,
    required bool obscure,
    required VoidCallback onToggle,
    String? Function(String?)? validator,
  }) {
    return _buildTextField(
      controller: controller,
      hint: hint,
      icon: Icons.lock,
      obscure: obscure,
      suffixIcon: IconButton(
        icon: Icon(obscure ? Icons.visibility_off : Icons.visibility, color: Colors.grey),
        onPressed: onToggle,
      ),
      validator: validator ??
              (v) {
            if (v == null || v.isEmpty) return "Vui lòng nhập mật khẩu";
            if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$').hasMatch(v)) {
              return "Mật khẩu ≥8 ký tự, gồm chữ hoa, chữ thường, số & ký tự đặc biệt";
            }
            return null;
          },
    );
  }
}
