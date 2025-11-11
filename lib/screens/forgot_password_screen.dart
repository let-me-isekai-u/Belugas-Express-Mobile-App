import 'dart:convert';
import 'package:flutter/material.dart';
import '../services/api_service.dart';
import 'change_password_screen.dart';
import '../l10n/app_localizations.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _codeController = TextEditingController();

  bool _isLoading = false;
  bool _isResendAvailable = true;
  int _secondsRemaining = 30;

  void _showSnackBar(String message, {Color color = Colors.red}) {
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

    if (_emailController.text.isEmpty) {
      _showSnackBar(loc.enterEmail);
      return;
    }

    setState(() {
      _isLoading = true;
      _isResendAvailable = false;
      _secondsRemaining = 30;
    });

    try {
      final response =
      await ApiService.sendVerificationCode(email: _emailController.text.trim());

      if (response.statusCode == 200) {
        _showSnackBar(loc.sendCodeSuccess, color: Colors.blue);
        _startResendCountdown();
      } else if (response.statusCode == 400) {
        _showSnackBar(loc.sendCodeError, color: Colors.red);
      } else {
        final error = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        _showSnackBar(error["message"] ?? loc.sendCodeError);
      }
    } catch (e) {
      _showSnackBar(loc.connectionError(e));

    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _startResendCountdown() {
    Future.doWhile(() async {
      await Future.delayed(const Duration(seconds: 1));
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
        return true;
      } else {
        setState(() => _isResendAvailable = true);
        return false;
      }
    });
  }

  Future<void> _verifyCode() async {
    final loc = AppLocalizations.of(context)!;

    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final response = await ApiService.verifyCode(
        email: _emailController.text.trim(),
        code: _codeController.text.trim(),
      );

      if (response.statusCode == 200) {
        _showSnackBar(loc.loginSuccess, color: Colors.green);
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ChangePasswordScreen(
              email: _emailController.text.trim(),
            ),
          ),
        );
      } else {
        final error = response.body.isNotEmpty ? jsonDecode(response.body) : {};
        _showSnackBar(error["message"] ?? loc.enterVerificationCode);
      }
    } catch (e) {
      _showSnackBar(loc.connectionError(e));

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
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Icon(Icons.lock_reset, size: 80, color: Colors.white),
                  const SizedBox(height: 12),
                  Text(
                    loc.forgotPassword,
                    style: const TextStyle(
                      fontFamily: 'Serif',
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 25),

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
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            labelText: loc.enterEmail,
                            prefixIcon: Icon(Icons.email, color: Colors.blue[700]),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          validator: (v) =>
                          v == null || v.isEmpty ? loc.enterEmail : null,
                        ),
                        const SizedBox(height: 15),

                        Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                controller: _codeController,
                                decoration: InputDecoration(
                                  labelText: loc.enterVerificationCode,
                                  prefixIcon: Icon(Icons.numbers, color: Colors.blue[700]),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                validator: (v) => v == null || v.isEmpty
                                    ? loc.enterVerificationCode
                                    : null,
                              ),
                            ),
                            const SizedBox(width: 10),
                            ElevatedButton(
                              onPressed: _isResendAvailable ? _sendCode : null,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.blue[400],
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isResendAvailable
                                  ? Text(loc.sendCode)
                                  : Text("(${_secondsRemaining}s)"),
                            ),
                          ],
                        ),
                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _verifyCode,
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
                                : Text(loc.login, style: const TextStyle(fontSize: 18)),
                          ),
                        ),
                        const SizedBox(height: 15),

                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            loc.login,
                            style: const TextStyle(color: Colors.blue, fontSize: 15),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
