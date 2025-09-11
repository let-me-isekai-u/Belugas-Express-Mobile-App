import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _baseUrl = "https://reekingly-noninduced-chanel.ngrok-free.app/api/accountapi";
  static const String _profileUrl = "https://reekingly-noninduced-chanel.ngrok-free.app/api/homeapi/profile";

  /// ------------------ AUTH & ACCOUNT ------------------

  /// Gửi mã xác nhận về email
  static Future<http.Response> sendVerificationCode({required String email}) async {
    final url = Uri.parse("$_baseUrl/send-verification-code");
    final body = jsonEncode(email); // API yêu cầu body là string
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
    return await http.post(url, body: body, headers: {"Content-Type": "application/json"});
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
    return await http.post(url, body: body, headers: {"Content-Type": "application/json"});
  }

  /// Đăng nhập tài khoản
  static Future<http.Response> login({
    required String phoneNumber,
    required String password,
  }) async {
    final url = Uri.parse("$_baseUrl/login");
    final body = jsonEncode({
      "phoneNumber": phoneNumber,
      "password": password,
    });
    return await http.post(url, body: body, headers: {"Content-Type": "application/json"});
  }

  /// Refresh Token
  static Future<http.Response> refreshToken({
    required String refreshToken,
  }) async {
    final url = Uri.parse("$_baseUrl/login");
    final body = jsonEncode({"refreshToken": refreshToken});
    return await http.post(url, body: body, headers: {"Content-Type": "application/json"});
  }

  /// Lấy thông tin cá nhân
  static Future<http.Response> getProfile({required String accessToken}) async {
    final url = Uri.parse(_profileUrl);
    return await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    });
  }

  /// ------------------ ORDER & FEE ------------------

  /// API lấy giá VND/kg
  static Future<http.Response> getFee() async {
    final url = Uri.parse("https://reekingly-noninduced-chanel.ngrok-free.app/api/feeapi/get-fee");
    return await http.get(url, headers: {"Content-Type": "application/json"});
  }

  /// API tạo đơn hàng
  static Future<http.Response> createOrder({
    required String accessToken,
    required double weightEstimate,
    required String senderName,
    required String receiverName,
    required String senderPhone,
    required String receiverPhone,
    required String senderAddress,
    required String receiverAddress,
    required double downPayment,
    required double pricePerKilogram,
    required String country,
  }) async {
    final url = Uri.parse("https://reekingly-noninduced-chanel.ngrok-free.app/api/orderapi/create");
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    };
    final body = jsonEncode({
      "senderName": senderName,
      "receiverName": receiverName,
      "senderPhone": senderPhone,
      "receiverPhone": receiverPhone,
      "senderAddress": senderAddress,
      "receiverAddress": receiverAddress,
      "downPayment": downPayment,
      "pricePerKilogram": pricePerKilogram,
      "country": country,
      "weightEstimate": weightEstimate,
    });
    return await http.post(url, headers: headers, body: body);
  }

  /// Lấy danh sách đơn hàng
  static Future<http.Response> getOrders({required String accessToken}) async {
    final url = Uri.parse("https://reekingly-noninduced-chanel.ngrok-free.app/api/orderapi/my-orders");
    return await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    });
  }

  /// Lấy chi tiết đơn hàng theo ID
  static Future<http.Response> orderDetails({
    required String accessToken,
    required int id,
  }) async {
    final url = Uri.parse("https://reekingly-noninduced-chanel.ngrok-free.app/api/orderapi/$id");
    return await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    });
  }

  /// ------------------ PAYMENT ------------------

  /// Lấy lịch sử thanh toán
  static Future<http.Response> getPaymentHistory({
    required String accessToken,
  }) async {
    final url = Uri.parse("https://reekingly-noninduced-chanel.ngrok-free.app/api/paymentapi/get-history-payment");
    return await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    });
  }

  /// Tạo thanh toán (lấy QR code)
  static Future<http.Response> createPayment({
    required String accessToken,
    required int orderId,
    required double amount,
    required String content,
  }) async {
    final url = Uri.parse("https://reekingly-noninduced-chanel.ngrok-free.app/api/paymentapi/create-payment");
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    };
    final body = jsonEncode({
      "orderId": orderId,
      "amount": amount,
      "content": content,
    });
    return await http.post(url, headers: headers, body: body);
  }

  /// ------------------ TRANSACTION (Google Script) ------------------

  /// Lấy danh sách 6 giao dịch cuối cùng
  static Future<http.Response> getLastTransactions() async {
    final url = Uri.parse(
        "https://script.google.com/macros/s/AKfycbyB5JISCpIjFJp9ikNS00RP34ywViepMogpyjAXaLgimbYkqSFb2KiY5APofTMW2arP_A/exec");
    return await http.get(url);
  }
}
