import 'dart:convert';
import 'package:http/http.dart' as http;

class ApiService {
  static const String _accountBaseUrl =
      "https://reekingly-noninduced-chanel.ngrok-free.app/api/accountapi";
  static const String _homeBaseUrl =
      "https://reekingly-noninduced-chanel.ngrok-free.app/api/homeapi";
  static const String _orderBaseUrl =
      "https://reekingly-noninduced-chanel.ngrok-free.app/api/orderapi";
  static const String _countryBaseUrl =
      "https://reekingly-noninduced-chanel.ngrok-free.app/api/countryapi";
  static const String _pricingTableBaseUrl =
      "https://reekingly-noninduced-chanel.ngrok-free.app/api/pricingtableapi";
  static const String _paymentBaseUrl =
      "https://reekingly-noninduced-chanel.ngrok-free.app/api/paymentapi";
  static const String _createOrderUrl = "https://reekingly-noninduced-chanel.ngrok-free.app/api/orderapi/create";
  static const String _getOrdersUrl = "https://reekingly-noninduced-chanel.ngrok-free.app/api/orderapi/my-orders";
  static const String _orderDetailUrl = "https://reekingly-noninduced-chanel.ngrok-free.app/api/orderapi";

  /// ------------------ AUTH & ACCOUNT ------------------

  /// Gửi mã xác nhận về email
  static Future<http.Response> sendVerificationCode(
      {required String email}) async {
    final url = Uri.parse("$_accountBaseUrl/send-verification-code");
    // Theo tài liệu API, body chỉ là một chuỗi email
    final body = jsonEncode(email);
    return await http.post(url,
        body: body, headers: {"Content-Type": "application/json"});
  }

  /// Đăng ký tài khoản
  static Future<http.Response> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String code,
    String? referredByCode,
  }) async {
    final url = Uri.parse("$_accountBaseUrl/register");
    final body = {
      "email": email,
      "password": password,
      "fullName": fullName,
      "phoneNumber": phoneNumber,
      "code": code,
      // Thêm trường này trực tiếp, không cần kiểm tra isNotEmpty
      "referredByCode": referredByCode,
    };
    return await http.post(url,
        body: jsonEncode(body), headers: {"Content-Type": "application/json"});
  }

  /// Xác minh mã code (cho màn hình quên mật khẩu)
  static Future<http.Response> verifyCode({
    required String email,
    required String code,
  }) async {
    final url = Uri.parse("$_accountBaseUrl/verify-code");
    final body = jsonEncode({"email": email, "code": code});
    return await http.post(url,
        body: body, headers: {"Content-Type": "application/json"});
  }

  /// Đổi mật khẩu sau khi xác minh code thành công
  static Future<http.Response> forgotPassword({
    required String email,
    required String newPassword,
  }) async {
    final url = Uri.parse("$_accountBaseUrl/forgot-password");
    final body = jsonEncode({"email": email, "password": newPassword});
    return await http.post(url,
        body: body, headers: {"Content-Type": "application/json"});
  }

  /// Đăng nhập tài khoản
  static Future<http.Response> login({
    required String phoneNumber,
    required String password,
  }) async {
    final url = Uri.parse("$_accountBaseUrl/login");
    final body = jsonEncode({"phoneNumber": phoneNumber, "password": password});
    return await http.post(url,
        body: body, headers: {"Content-Type": "application/json"});
  }

  /// Refresh Token
  static Future<http.Response> refreshToken({
    required String refreshToken,
  }) async {
    // URL này giống hệt API login
    final url = Uri.parse("$_accountBaseUrl/login");
    final body = jsonEncode({"refreshToken": refreshToken});
    return await http.post(url,
        body: body, headers: {"Content-Type": "application/json"});
  }

  /// Lấy thông tin cá nhân
  static Future<http.Response> getProfile({required String accessToken}) async {
    final url = Uri.parse("$_homeBaseUrl/profile");
    return await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    });
  }

  /// ------------------ ORDER & FEE ------------------

  /// Lấy danh sách các quốc gia
  static Future<http.Response> getCountries() async {
    final url = Uri.parse("$_countryBaseUrl/get-country");
    return await http.get(url, headers: {"Content-Type": "application/json"});
  }

  /// Lấy danh sách bảng giá theo quốc gia
  static Future<http.Response> getPricingTable(
      {required int countryId}) async {
    final url =
    Uri.parse("$_pricingTableBaseUrl/get-pricing-table/$countryId");
    return await http.get(url, headers: {"Content-Type": "application/json"});
  }

  /// API tạo đơn hàng
  static Future<http.Response> createOrder({
    required String accessToken,
    required String senderName,
    required String receiverName,
    required String senderPhone,
    required String receiverPhone,
    required String senderAddress,
    required String receiverAddress,
    required int countryId,
    required double payWithBalance,
    required double downPayment,
    required List<Map<String, dynamic>> orderItems,
  }) async {
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
      "countryId": countryId,
      "payWithBalance": payWithBalance,
      "downPayment": downPayment,
      "orderItems": orderItems,
    });
    return await http.post(Uri.parse(_createOrderUrl), headers: headers, body: body);
  }

  /// API lấy danh sách tất cả đơn hàng
  static Future<http.Response> getOrders({required String accessToken}) async {
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    };
    return await http.get(Uri.parse(_getOrdersUrl), headers: headers);
  }

  /// API lấy chi tiết đơn hàng theo ID
  static Future<http.Response> orderDetails({
    required String accessToken,
    required int id,
  }) async {
    final headers = {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    };
    final url = "$_orderDetailUrl/$id";
    return await http.get(Uri.parse(url), headers: headers);
  }

  /// ------------------ PAYMENT ------------------

  /// Lấy lịch sử thanh toán
  static Future<http.Response> getPaymentHistory(
      {required String accessToken}) async {
    final url = Uri.parse("$_paymentBaseUrl/get-history-payment");
    return await http.get(url, headers: {
      "Content-Type": "application/json",
      "Authorization": "Bearer $accessToken",
    });
  }

  /// kiểm tra giao dịch đã thành công chưa?
  static Future<http.Response> getLastTransactions({
    required double amount,
    required String content,
  }) async {
    final url = Uri.parse(
        "https://reekingly-noninduced-chanel.ngrok-free.app/api/paymentapi/check-transaction");

    final request = http.Request('GET', url)
      ..headers['Content-Type'] = 'application/json'
      ..headers['Accept'] = 'application/json'
      ..body = jsonEncode({
        "amount": amount,
        "content": content,
      });

    final streamedResponse = await request.send();
    return await http.Response.fromStream(streamedResponse);
  }

  /// ------------------ CONTRACTOR ------------------

  /// Lấy thông tin nhà thầu
  static Future<http.Response> getContractorProfile(String accessToken) async {
    final url = Uri.parse("$_homeBaseUrl/contractor-profile");
    return await http.get(
      url,
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $accessToken",
      },
    );
  }


}