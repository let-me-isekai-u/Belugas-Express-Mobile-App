import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import '../l10n/app_localizations.dart';

class ChangePasswordScreen extends StatefulWidget {
  final String email;

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

  Future<void> _onConfirm(AppLocalizations loc) async {
    final pass = passwordController.text.trim();
    final confirm = confirmController.text.trim();

    setState(() {
      _passwordError = null;
      _confirmError = null;
    });

    if (pass.isEmpty) {
      setState(() => _passwordError = loc.changePasswordErrorEmpty);
      return;
    }
    if (pass.length < 8) {
      setState(() => _passwordError = loc.changePasswordErrorWeak);
      return;
    }
    if (confirm.isEmpty) {
      setState(() => _confirmError = loc.changePasswordErrorConfirmEmpty);
      return;
    }
    if (pass != confirm) {
      setState(() => _confirmError = loc.changePasswordErrorNotMatch);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.forgotPassword(
        email: widget.email,
        newPassword: pass,
      );

      if (response.statusCode == 200) {
        _showSnackBar(loc.changePasswordSuccess, Colors.green);
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.pushAndRemoveUntil(
            context,
            MaterialPageRoute(builder: (_) => LoginScreen()),
                (route) => false,
          );
        });
      } else if (response.statusCode == 400) {
        _showSnackBar(loc.changePasswordEmailNotRegistered, Colors.red);
      } else {
        final error = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        _showSnackBar(error["message"] ?? loc.changePasswordFailed, Colors.red);
      }
    } catch (e) {
      _showSnackBar(loc.changePasswordConnectionError("$e"), Colors.red);
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
                const Icon(Icons.lock, size: 80, color: Colors.white),
                const SizedBox(height: 12),
                Text(
                  loc.changePasswordTitle,
                  style: const TextStyle(
                    fontFamily: 'Serif',
                    color: Colors.white,
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 30),
                // New password field
                _buildPasswordField(
                  controller: passwordController,
                  hint: loc.changePasswordNew,
                  obscureText: _obscurePass,
                  onToggle: () => setState(() => _obscurePass = !_obscurePass),
                  errorText: _passwordError,
                ),
                const SizedBox(height: 20),
                // Confirm password field
                _buildPasswordField(
                  controller: confirmController,
                  hint: loc.changePasswordConfirm,
                  obscureText: _obscureConfirm,
                  onToggle: () =>
                      setState(() => _obscureConfirm = !_obscureConfirm),
                  errorText: _confirmError,
                ),
                const SizedBox(height: 25),
                // Confirm button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : () => _onConfirm(loc),
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
                        : Text(
                      loc.againConfirmPasswordButton,
                      style:
                      const TextStyle(fontSize: 18, color: Colors.white),
                    ),
                  ),
                ),
                TextButton(
                  onPressed: _isLoading
                      ? null
                      : () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(builder: (_) => LoginScreen()),
                    );
                  },
                  child: Text(
                    loc.changePasswordBackLogin,
                    style: const TextStyle(
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