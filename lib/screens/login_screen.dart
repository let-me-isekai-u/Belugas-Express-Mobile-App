import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../screens/register_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/home_screen.dart';
import '../l10n/app_localizations.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class LoginScreen extends StatefulWidget {
  final void Function(Locale)? onLocaleChange;

  const LoginScreen({super.key, this.onLocaleChange});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with TickerProviderStateMixin {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  late final AnimationController _logoController;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
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

  void _toggleLanguage() {
    final currentLocale = Localizations.localeOf(context);
    final newLocale = currentLocale.languageCode == 'vi' ? const Locale('en') : const Locale('vi');
    widget.onLocaleChange?.call(newLocale);
  }

  Future<void> _login(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;

    String phone = phoneController.text.trim();
    String password = passwordController.text.trim();

    if (phone.isEmpty || password.isEmpty) {
      _showSnackBar(loc.loginErrorEmpty, Colors.red);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1️⃣ Request permission iOS
      await FirebaseMessaging.instance.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      // 2️⃣ Lấy device token
      final deviceToken = await FirebaseMessaging.instance.getToken();

      if (deviceToken == null) {
        _showSnackBar("Không lấy được device token, vui lòng thử lại", Colors.red);
        setState(() => _isLoading = false);
        return;
      }

      // 3️⃣ Gọi API login kèm deviceToken
      final response = await ApiService.login(
        phoneNumber: phone,
        password: password,
        deviceToken: deviceToken,
      );

      // 4️⃣ Xử lý kết quả
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("accessToken", data["accessToken"]);
        await prefs.setString("refreshToken", data["refreshToken"]);
        await prefs.setString("fullName", data["fullName"] ?? "");
        await prefs.setString("email", data["email"] ?? "");
        await prefs.setInt("role", data["role"] ?? 0);
        await prefs.setInt("id", data["id"] ?? 0);

        _showSnackBar(loc.loginSuccess, Colors.green);

        final role = data["role"] ?? 1;
        if (role == 2) {
          Navigator.pushReplacementNamed(context, "/contractorHome");
        } else {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => HomeScreen(
                accessToken: data["accessToken"],
                onLocaleChange: widget.onLocaleChange,
              ),
            ),
          );
        }
      } else if (response.statusCode == 401) {
        _showSnackBar(loc.loginErrorWrong, Colors.red);
      } else if (response.statusCode == 404) {
        _showSnackBar(loc.loginErrorLocked, Colors.red);
      } else {
        _showSnackBar(loc.loginErrorOther, Colors.red);
      }
    } catch (e) {
      _showSnackBar("${loc.loginErrorOther}: $e", Colors.red);
    } finally {
      setState(() => _isLoading = false);
    }
  }


  // Trong _LoginScreenState
  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    final theme = Theme.of(context); // Lấy Theme để dùng màu chủ đạo

    return Scaffold(
      // Bỏ backgroundColor ở đây vì chúng ta dùng Stack
      body: SafeArea(
        child: Stack(
          children: [
            // 1. PHẦN NỀN TRÊN (Màu Chủ Đạo - Xanh Blue[700] cũ)
            Container(
              height: MediaQuery.of(context).size.height * 0.4,
              decoration: BoxDecoration(
                color: Colors.blue[700],
              ),
            ),

            // 2. KHU VỰC CHÍNH CÓ CUỘN (Tất cả nội dung)
            SingleChildScrollView(
              // Padding ngang rộng hơn cho tổng thể đẹp hơn
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                children: [
                  // NÚT ĐỔI NGÔN NGỮ
                  Padding(
                    padding: const EdgeInsets.only(top: 10, bottom: 20),
                    child: Align(
                      alignment: Alignment.topRight,
                      child: TextButton(
                        onPressed: _toggleLanguage,
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(
                              Localizations.localeOf(context).languageCode == 'vi'
                                  ? 'lib/assets/icons/vietnam.png'
                                  : 'lib/assets/icons/united-states.png',
                              width: 32, // Nhỏ hơn chút cho tinh tế
                              height: 32,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              Localizations.localeOf(context).languageCode == 'vi' ? 'VI' : 'EN',
                              style: const TextStyle(
                                fontSize: 18, // Nhỏ hơn chút
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // LOGO VÀ TIÊU ĐỀ
                  _buildLogoSection(theme, loc),

                  const SizedBox(height: 30),

                  // CARD FORM ĐĂNG NHẬP
                  _buildLoginFormCard(theme, loc, context),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

// Hàm tách biệt phần Logo và Tiêu đề
  Widget _buildLogoSection(ThemeData theme, AppLocalizations loc) {
    return Column(
      children: [
        // Logo với hiệu ứng Scale
        ScaleTransition(
          scale: Tween<double>(begin: 1.0, end: 1.05).animate(
            CurvedAnimation(parent: _logoController, curve: Curves.easeInOut),
          ),
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20), // Bo góc lớn hơn
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3), // Đổ bóng nhẹ
                  blurRadius: 20,
                  spreadRadius: 3,
                  offset: const Offset(0, 10),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.asset(
                'lib/assets/icons/LOGO BELUGA FINAL.png',
                width: 150, // Lớn hơn chút
                height: 150,
                fit: BoxFit.contain,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        // Tiêu đề
        Text(
          loc.appTitle,
          style: const TextStyle(
            fontFamily: 'Serif',
            color: Colors.white,
            fontSize: 32,
            fontWeight: FontWeight.bold,
            shadows: [
              Shadow(
                color: Colors.black38,
                offset: Offset(1, 1),
                blurRadius: 2,
              ),
            ],
          ),
        ),
      ],
    );
  }

// Hàm tách biệt phần Card Form
  Widget _buildLoginFormCard(ThemeData theme, AppLocalizations loc, BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20), // Bo góc lớn
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Tiêu đề form
            Text(
              loc.loginTitle, // Thêm loc.key cho "Đăng nhập" nếu có
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary, // Màu chủ đạo
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),

            // INPUTS
            _buildTextField(phoneController, loc.phone, Icons.phone, false),
            const SizedBox(height: 16),
            _buildTextField(passwordController, loc.password, Icons.lock, true),
            const SizedBox(height: 24),

            // LOGIN BUTTON
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: theme.colorScheme.secondary, // Dùng màu Secondary cho nút chính
                minimumSize: const Size(double.infinity, 50),
                elevation: 5,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                foregroundColor: Colors.white,
                textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
              onPressed: _isLoading ? null : () => _login(context),
              child: _isLoading
                  ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
                  : Text(loc.login),
            ),
            const SizedBox(height: 16),

            // FOOTER LINKS (ĐÃ SỬA LỖI OVERFLOW VÀ BỐ CỤC)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: _goToForgotPassword, // Sử dụng hàm riêng cho điều hướng
                  child: Text(loc.forgotPassword, style: TextStyle(color: theme.colorScheme.primary)),
                ),
                TextButton(
                  onPressed: _goToRegister, // Sử dụng hàm riêng cho điều hướng
                  child: Text(loc.register, style: TextStyle(color: theme.colorScheme.secondary)),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Hàm _buildTextField (Trong _LoginScreenState)
  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool isPassword) {
    final theme = Theme.of(context);
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      keyboardType: isPassword ? TextInputType.text : TextInputType.phone,
      style: const TextStyle(fontSize: 16, color: Colors.black87),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey.shade100, // Nền xám nhạt tinh tế hơn
        hintText: hint,
        prefixIcon: Icon(icon, color: theme.colorScheme.primary), // Icon màu chủ đạo
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: theme.colorScheme.secondary, // Icon màu secondary
          ),
          onPressed: () {
            setState(() {
              _obscurePassword = !_obscurePassword;
            });
          },
        )
            : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none, // Bỏ viền cố định
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: theme.colorScheme.primary, width: 2), // Viền khi focus
        ),
      ),
    );
  }

  // Hàm điều hướng
  void _goToForgotPassword() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
    );
  }

  void _goToRegister() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => RegisterScreen(onLocaleChange: widget.onLocaleChange),
      ),
    );
  }
}
