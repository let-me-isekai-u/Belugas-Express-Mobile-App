import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../screens/register_screen.dart';
import '../screens/forgot_password_screen.dart';
import '../screens/home_screen.dart';
import '../l10n/app_localizations.dart';

class LoginScreen extends StatefulWidget {
  final void Function(Locale)? onLocaleChange;

  const LoginScreen({super.key, this.onLocaleChange});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

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
      final response = await ApiService.login(phoneNumber: phone, password: password);

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

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.blue[700],
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Nút đổi ngôn ngữ
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(
                      onPressed: _toggleLanguage,
                      child: Row(
                        children: [
                          Image.asset(
                            Localizations.localeOf(context).languageCode == 'vi'
                                ? 'lib/assets/icons/vietnam.png'
                                : 'lib/assets/icons/united-states.png',
                            width: 38,
                            height: 38,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            Localizations.localeOf(context).languageCode == 'vi' ? 'VI' : 'EN',
                            style: const TextStyle(
                              fontSize: 23,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const Icon(Icons.local_shipping, size: 80, color: Colors.white),
                const SizedBox(height: 12),

                Text(
                  loc.appTitle,
                  style: const TextStyle(
                    fontFamily: 'Serif',
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 40),
                _buildTextField(phoneController, loc.phone, Icons.phone, false),
                const SizedBox(height: 16),
                _buildTextField(passwordController, loc.password, Icons.lock, true),
                const SizedBox(height: 20),

                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlue[300],
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                  ),
                  onPressed: _isLoading ? null : () => _login(context),
                  child: _isLoading
                      ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                  )
                      : Text(loc.login),
                ),

                const SizedBox(height: 16),

                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()),
                        );
                      },
                      child: Text(loc.forgotPassword, style: const TextStyle(color: Colors.white)),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => RegisterScreen(onLocaleChange: widget.onLocaleChange),
                          ),
                        );
                      },
                      child: Text(loc.register, style: const TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon, bool isPassword) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? _obscurePassword : false,
      keyboardType: isPassword ? TextInputType.text : TextInputType.phone,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        prefixIcon: Icon(icon, color: Colors.blue[700]),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            _obscurePassword ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
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
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
