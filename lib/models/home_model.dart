import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class HomeModel extends ChangeNotifier {
  String? fullName;
  String? email;
  String? phoneNumber;
  double? wallet;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Hàm load profile khi vào HomeScreen
  Future<void> loadProfile(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("accessToken");
    String? refreshToken = prefs.getString("refreshToken");

    if (accessToken == null || refreshToken == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    var response = await ApiService.getProfile(accessToken: accessToken);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      fullName = data["fullName"];
      email = data["email"];
      phoneNumber = data["phoneNumber"];
      wallet = (data["wallet"] as num).toDouble();
    } else if (response.statusCode == 401) {
      /// Token hết hạn => gọi refreshToken
      var refreshResponse =
      await ApiService.refreshToken(refreshToken: refreshToken);

      if (refreshResponse.statusCode == 200) {
        final newData = jsonDecode(refreshResponse.body);
        String newAccessToken = newData["accessToken"];
        String newRefreshToken = newData["refreshToken"];

        // Lưu lại token mới
        await prefs.setString("accessToken", newAccessToken);
        await prefs.setString("refreshToken", newRefreshToken);

        // Gọi lại profile với token mới
        var retry = await ApiService.getProfile(accessToken: newAccessToken);
        if (retry.statusCode == 200) {
          final data = jsonDecode(retry.body);
          fullName = data["fullName"];
          email = data["email"];
          phoneNumber = data["phoneNumber"];
          wallet = (data["wallet"] as num).toDouble();
        }
      } else {
        // Refresh token cũng fail => bắt user login lại
        await prefs.clear();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Phiên đăng nhập hết hạn, vui lòng login lại")),
          );
          Navigator.pushReplacementNamed(context, "/login");
        }
      }
    } else {
      debugPrint("Lỗi load profile: ${response.body}");
    }

    _isLoading = false;
    notifyListeners();
  }
}
