import '../services/api_service.dart';
import 'dart:convert';

class RegisterModel {
  /// Gửi mã OTP về email
  ///
  /// [email] - Email người dùng
  /// Trả về: null nếu thành công, hoặc chuỗi thông báo lỗi
  static Future<String?> sendVerificationCode({required String email}) async {
    try {
      final response = await ApiService.sendVerificationCode(email: email);

      switch (response.statusCode) {
        case 200:
          return null; // thành công
        case 500:
          return "Lỗi khi gửi email, vui lòng thử lại";
        default:
          return "Có lỗi xảy ra, vui lòng thử lại";
      }
    } catch (e) {
      return "Lỗi kết nối: $e";
    }
  }

  /// Đăng ký tài khoản mới
  ///
  /// [email] - Email người dùng
  /// [password] - Mật khẩu
  /// [fullName] - Họ tên
  /// [phoneNumber] - Số điện thoại
  /// [code] - Mã OTP (bắt buộc)
  /// [referredByCode] - Mã giới thiệu (không bắt buộc)
  ///
  /// Trả về: chuỗi mô tả kết quả đăng ký
  static Future<String> register({
    required String email,
    required String password,
    required String fullName,
    required String phoneNumber,
    required String code,
    String? referredByCode,
  }) async {
    try {
      final response = await ApiService.register(
        email: email,
        password: password,
        fullName: fullName,
        phoneNumber: phoneNumber,
        code: code,
        referredByCode: referredByCode,
      );

      switch (response.statusCode) {
        case 200:
          return "Đăng ký thành công!";
        case 409:
          return "Email hoặc số điện thoại đã được đăng ký";
        case 400:
          return "Dữ liệu không hợp lệ, vui lòng kiểm tra lại";
        case 401:
          return "Mã OTP không hợp lệ hoặc đã hết hạn";
        default:
          try {
            final body = json.decode(response.body);
            return body['message'] ?? "Có lỗi xảy ra, vui lòng thử lại";
          } catch (_) {
            return "Có lỗi xảy ra, vui lòng thử lại";
          }
      }
    } catch (e) {
      return "Lỗi kết nối: $e";
    }
  }
}
