import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import 'login_screen.dart';
import 'home_screen.dart';
import 'Contructor/Contractor_home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkLogin();
  }

  Future<void> _checkLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString('accessToken');
    final refreshToken = prefs.getString('refreshToken');
    final role = prefs.getInt('role') ?? 1; // mặc định là user

    if (accessToken != null) {
      // Có access token → đi thẳng Home
      _goToHome(role, accessToken);
    } else if (refreshToken != null) {
      // Nếu có refresh token → thử refresh token
      try {
        final response = await ApiService.refreshToken(refreshToken: refreshToken);
        if (response.statusCode == 200) {
          final data = jsonDecode(response.body);
          final newAccessToken = data['accessToken'];
          final newRefreshToken = data['refreshToken'];

          // Lưu lại token mới
          await prefs.setString('accessToken', newAccessToken);
          await prefs.setString('refreshToken', newRefreshToken);

          _goToHome(role, newAccessToken);
        } else {
          // Refresh token không hợp lệ → về Login
          _goToLogin();
        }
      } catch (e) {
        _goToLogin();
      }
    } else {
      // Không có token → về Login
      _goToLogin();
    }
  }

  void _goToHome(int role, String accessToken) {
    if (role == 2) {
      // Nhà thầu
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const ContractorHomeScreen()),
      );
    } else {
      // User bình thường
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => HomeScreen(accessToken: accessToken)),
      );
    }
  }

  void _goToLogin() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // hiển thị loading trong lúc check
      ),
    );
  }
}
