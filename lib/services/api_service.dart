import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = "https://reekingly-noninduced-chanel.ngrok-free.app/api/account";

  /// Gửi mã xác nhận về email
  static Future<http.Response> sendVerificationCode({required String email}) async {
    final url = Uri.parse("$_baseUrl/send-verification-code");
    // API yêu cầu body là một chuỗi (JSON string), KHÔNG phải object
    final body = jsonEncode(email); // => "example@gmail.com"
    return await http.post(
      url,
      body: body,
      headers: {"Content-Type": "application/json"},
    );
  }

  /// Đăng ký tài khoản với mã xác nhận
  static Future<http.Response> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String code,
  }) async {
    final url = Uri.parse("$_baseUrl/register");
    final body = jsonEncode({
      "email": email,
      "password": password,
      "fullName": fullName,
      "phoneNumber": phoneNumber,
      "code": code,
    });
    return await http.post(
      url,
      body: body,
      headers: {"Content-Type": "application/json"},
    );
  }

  /// Xác minh mã code (cho màn hình quên mật khẩu)
  static Future<http.Response> verifyCode({
    required String email,
    required String code,
  }) async {
    final url = Uri.parse("$_baseUrl/verify-code");
    final body = jsonEncode({
      "email": email,
      "code": code,
    });
    return await http.post(
      url,
      body: body,
      headers: {"Content-Type": "application/json"},
    );
  }

  /// Đổi mật khẩu sau khi xác minh code thành công
  static Future<http.Response> forgotPassword({
    required String email,
    required String newPassword,
  }) async {
    final url = Uri.parse("$_baseUrl/forgot-password");
    final body = jsonEncode({
      "email": email,
      "password": newPassword,
    });
    return await http.post(
      url,
      body: body,
      headers: {"Content-Type": "application/json"},
    );
  }
}
