import 'dart:async';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import '../models/register_model.dart';
import 'terms_screen.dart';
import '../l10n/app_localizations.dart';

class RegisterScreen extends StatefulWidget {
  final void Function(Locale)? onLocaleChange;
  const RegisterScreen({super.key, this.onLocaleChange});

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
  final _referralController = TextEditingController();
  final _zaloController = TextEditingController(); // Thêm controller mới

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
    final loc = AppLocalizations.of(context)!;

    if (_emailController.text.trim().isEmpty) {
      _showSnackBar(loc.enterEmail, Colors.orange);
      return;
    }

    setState(() => _isSendingCode = true);

    try {
      final response = await ApiService.sendVerificationCode(
        email: _emailController.text.trim(),
      );

      if (response.statusCode == 200) {
        _showSnackBar(loc.sendCodeSuccess, Colors.blue);
        _startCountdown();
      } else if (response.statusCode == 500) {
        _showSnackBar(loc.sendCodeError500, Colors.red);
      } else {
        final errorMsg = response.body.isNotEmpty ? response.body : loc.sendCodeError;
        _showSnackBar(errorMsg, Colors.red);
      }
    } catch (e) {
      _showSnackBar(loc.connectionError(e.toString()), Colors.red);
    } finally {
      setState(() => _isSendingCode = false);
    }
  }

  Future<void> _register() async {
    final loc = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;
    if (!_agreeTerms) {
      _showSnackBar(loc.agreeTermsWarning, Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final message = await RegisterModel.register(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
        fullName: _nameController.text.trim(),
        phoneNumber: _phoneController.text.trim(),
        code: _codeController.text.trim(),
        referredByCode: _referralController.text.trim().isEmpty
            ? null
            : _referralController.text.trim(),
        phoneZalo: _zaloController.text.trim(), // Gửi luôn, có thể trống
      );

      // RegisterModel.register returns a message string from server (may be localized server-side).
      // We show it directly. If you want to map known success messages to loc strings, change here.
      if (message == "Đăng ký thành công!" || message.toLowerCase().contains("success")) {
        _showSnackBar(message, Colors.green);
        Navigator.pop(context);
      } else {
        _showSnackBar(message, Colors.red);
      }
    } catch (e) {
      _showSnackBar("${loc.sendCodeError}: $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

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
                Text(
                  loc.registerTitle,
                  style: const TextStyle(
                    fontFamily: 'Serif',
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),

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
                          hint: loc.nameHint,
                          icon: Icons.person,
                          validator: (v) => v == null || v.isEmpty ? loc.enterName : null,
                        ),
                        const SizedBox(height: 15),

                        _buildTextField(
                          controller: _emailController,
                          hint: loc.emailHint,
                          icon: Icons.email,
                          keyboardType: TextInputType.emailAddress,
                          validator: (value) {
                            if (value == null || value.isEmpty) return loc.enterEmail;
                            final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                            if (!emailRegex.hasMatch(value)) return loc.invalidEmail;
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        _buildPasswordField(
                          controller: _passwordController,
                          hint: loc.passwordHint,
                          obscure: _obscurePassword,
                          onToggle: () => setState(() => _obscurePassword = !_obscurePassword),
                        ),
                        const SizedBox(height: 15),

                        _buildPasswordField(
                          controller: _confirmPasswordController,
                          hint: loc.confirmPasswordHint,
                          obscure: _obscureConfirmPassword,
                          onToggle: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
                          validator: (value) {
                            if (value == null || value.isEmpty) return loc.enterPassword;
                            if (value != _passwordController.text) return loc.passwordMismatch;
                            return null;
                          },
                        ),
                        const SizedBox(height: 15),

                        _buildTextField(
                          controller: _phoneController,
                          hint: loc.phoneHint,
                          icon: Icons.phone,
                          keyboardType: TextInputType.phone,
                          validator: (value) {
                            if (value == null || value.isEmpty) return loc.enterPhone;
                            if (!RegExp(r'^[0-9]{9,11}$').hasMatch(value)) return loc.invalidPhone;
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
                                hint: loc.verificationCodeHint,
                                icon: Icons.verified,
                                keyboardType: TextInputType.number,
                                validator: (v) => v == null || v.isEmpty ? loc.enterVerificationCode : null,
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
                                  : Text(_countdown > 0 ? loc.resendCode(_countdown) : loc.sendCode),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),

                        // Referral Code
                        _buildTextField(
                          controller: _referralController,
                          hint: loc.referralCodeHint,
                          icon: Icons.card_giftcard,
                        ),
                        const SizedBox(height: 15),

                        // Số Zalo (không bắt buộc)
                        _buildTextField(
                          controller: _zaloController,
                          hint: loc.zaloHint,
                          icon: Icons.phone_android,
                          keyboardType: TextInputType.phone,
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
                                child: Text.rich(
                                  TextSpan(
                                    text: loc.agreeTerms,
                                    children: [
                                      TextSpan(
                                        text: loc.termsOfUse,
                                        style: const TextStyle(
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
                                : Text(loc.registerButton, style: const TextStyle(fontSize: 18)),
                          ),
                        ),
                        const SizedBox(height: 12),

                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(loc.alreadyAccount),
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
            final loc = AppLocalizations.of(context)!;
            if (v == null || v.isEmpty) return loc.enterPassword;
            if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$').hasMatch(v)) {
              // No dedicated message in arb for strong password - fall back to enterPassword
              return loc.enterPassword;
            }
            return null;
          },
    );
  }
}