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


  // Trong _RegisterScreenState
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            // 1. PHẦN NỀN TRÊN (Màu Chủ Đạo - Xanh Blue[700] cũ)
            Container(
              height: MediaQuery.of(context).size.height * 0.25,
              decoration: BoxDecoration(
                color: Colors.blue[700],
              ),
            ),

            // NÚT BACK VÀ ĐỔI NGÔN NGỮ
            // Positioned(
            //   top: 0,
            //   left: 0,
            //   right: 0,
            //   child: Row(
            //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //     children: [
            //       IconButton(
            //         icon: const Icon(Icons.arrow_back, color: Colors.white),
            //         onPressed: () => Navigator.pop(context),
            //       ),
            //       if (widget.onLocaleChange != null)
            //         Padding(
            //           padding: const EdgeInsets.only(right: 10, top: 5),
            //           child: TextButton(
            //             onPressed: _toggleLanguage,
            //             style: TextButton.styleFrom(
            //               padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            //             ),
            //             child: Row(
            //               mainAxisSize: MainAxisSize.min,
            //               children: [
            //                 Image.asset(
            //                   Localizations.localeOf(context).languageCode == 'vi'
            //                       ? 'lib/assets/icons/vietnam.png'
            //                       : 'lib/assets/icons/united-states.png',
            //                   width: 32,
            //                   height: 32,
            //                 ),
            //                 const SizedBox(width: 6),
            //                 Text(
            //                   Localizations.localeOf(context).languageCode == 'vi' ? 'VI' : 'EN',
            //                   style: const TextStyle(
            //                     fontSize: 18,
            //                     fontWeight: FontWeight.bold,
            //                     color: Colors.white,
            //                   ),
            //                 ),
            //               ],
            //             ),
            //           ),
            //         ),
            //     ],
            //   ),
            // ),

            // KHU VỰC CHÍNH CÓ CUỘN
            SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  const SizedBox(height: 50), // Khoảng trống cho AppBar/Button

                  // TIÊU ĐỀ
                  Text(
                    loc.registerTitle,
                    style: const TextStyle(
                      fontFamily: 'Serif',
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      shadows: [
                        Shadow(color: Colors.black38, offset: Offset(1, 1), blurRadius: 2),
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),

                  // CARD CHỨA FORM
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 15,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // --- PHÂN NHÓM 1: THÔNG TIN CÁ NHÂN ---
                          _buildSectionHeader(loc.personalInfo, theme.colorScheme.primary),
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
                          const SizedBox(height: 25),

                          // --- PHÂN NHÓM 2: BẢO MẬT ---
                          _buildSectionHeader(loc.securityInfo, theme.colorScheme.primary), // Giả sử có loc.securityInfo
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
                              // Regex validation được đặt trong hàm _buildPasswordField
                              return null;
                            },
                          ),
                          const SizedBox(height: 25),

                          // --- PHÂN NHÓM 3: LIÊN HỆ & KHÁC ---
                          _buildSectionHeader(loc.contactAndOther, theme.colorScheme.primary), // Giả sử có loc.contactAndOther
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

                          // Số Zalo (không bắt buộc)
                          _buildTextField(
                            controller: _zaloController,
                            hint: loc.zaloHint,
                            icon: Icons.chat_bubble, // Icon Zalo rõ hơn
                            keyboardType: TextInputType.phone,
                          ),
                          const SizedBox(height: 15),

                          // Referral Code (Không bắt buộc)
                          _buildTextField(
                            controller: _referralController,
                            hint: loc.referralCodeHint,
                            icon: Icons.card_giftcard,
                          ),
                          const SizedBox(height: 25),

                          // --- PHÂN NHÓM 4: XÁC THỰC (OTP) ---
                          _buildSectionHeader(loc.verification, theme.colorScheme.primary), // Giả sử có loc.verification

                          // OTP + nút nhận mã
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
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
                              SizedBox(
                                height: 50, // Chiều cao cố định
                                child: ElevatedButton(
                                  onPressed: (_isSendingCode || _countdown > 0) ? null : _sendCode,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: theme.colorScheme.secondary,
                                    padding: const EdgeInsets.symmetric(horizontal: 16),
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    elevation: 3,
                                  ),
                                  child: _isSendingCode
                                      ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                  )
                                      : Text(
                                    _countdown > 0 ? loc.resendCode(_countdown) : loc.sendCode,
                                    style: const TextStyle(fontSize: 14, color: Colors.white),
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 25),

                          // Checkbox điều khoản
                          _buildTermsCheckbox(loc, theme.colorScheme.primary),
                          const SizedBox(height: 20),

                          // Nút Đăng ký
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _agreeTerms ? theme.colorScheme.primary : Colors.grey,
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
                                  : Text(loc.registerButton, style: const TextStyle(fontSize: 18, color: Colors.white)),
                            ),
                          ),
                          const SizedBox(height: 12),

                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: Text(loc.alreadyAccount, style: TextStyle(color: theme.colorScheme.primary)),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 30), // Padding cuối cùng
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Hàm mới: Tiêu đề phân nhóm
  Widget _buildSectionHeader(String title, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Align(
        alignment: Alignment.centerLeft,
        child: Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ),
    );
  }

// Hàm mới: Checkbox Điều khoản
  Widget _buildTermsCheckbox(AppLocalizations loc, Color primary) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 24,
          height: 24,
          child: Checkbox(
            value: _agreeTerms,
            onChanged: (val) => setState(() => _agreeTerms = val ?? false),
            activeColor: primary,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const TermsScreen()),
              );
            },
            child: Padding(
              padding: const EdgeInsets.only(top: 4.0),
              child: Text.rich(
                TextSpan(
                  text: loc.agreeTerms,
                  style: const TextStyle(fontSize: 14),
                  children: [
                    TextSpan(
                      text: loc.termsOfUse,
                      style: TextStyle(
                        color: primary,
                        fontWeight: FontWeight.w600,
                        decoration: TextDecoration.underline,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }


// Hàm _buildTextField (Trong _RegisterScreenState, Cập nhật để đồng bộ với Login)
  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscure = false,
    Widget? suffixIcon,
    String? Function(String?)? validator,
  }) {
    final theme = Theme.of(context);
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100, // Nền xám nhạt
        hintText: hint,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary), // Icon màu chủ đạo
        suffixIcon: suffixIcon,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // Bỏ viền cố định
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2), // Viền khi focus
        ),
        errorMaxLines: 3,
      ),
      validator: validator,
    );
  }

// Hàm _buildPasswordField (Trong _RegisterScreenState, giữ nguyên validation cũ)
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
            // Logic kiểm tra mật khẩu mạnh cũ của bạn được giữ nguyên
            if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)(?=.*[@$!%*?&])[A-Za-z\d@$!%*?&]{8,}$')
                .hasMatch(v)) {
              return loc.changePasswordErrorWeak;
            }
            return null;
          },
    );
  }
// Thêm hàm _toggleLanguage (Nếu bạn chưa có)
  void _toggleLanguage() {
    final currentLocale = Localizations.localeOf(context);
    final newLocale = currentLocale.languageCode == 'vi' ? const Locale('en') : const Locale('vi');
    widget.onLocaleChange?.call(newLocale);
  }






}