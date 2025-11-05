import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class ContractorHomeModel extends ChangeNotifier {
  String? fullName;
  String? email;
  String? phoneNumber;
  double? wallet;
  double? rating;
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  Future<void> loadProfile(BuildContext context) async {
    _isLoading = true;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    final accessToken = prefs.getString("accessToken");
    final refreshToken = prefs.getString("refreshToken");

    if (accessToken == null || refreshToken == null) {
      _isLoading = false;
      notifyListeners();
      return;
    }

    final response = await ApiService.getProfile(accessToken: accessToken);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      fullName = data["fullName"];
      email = data["email"];
      phoneNumber = data["phoneNumber"];
      wallet = (data["wallet"] ?? 0).toDouble();
      rating = (data["rating"] ?? 0).toDouble();
    } else if (response.statusCode == 401) {
      final refreshResponse = await ApiService.refreshToken(refreshToken: refreshToken);
      if (refreshResponse.statusCode == 200) {
        final newData = jsonDecode(refreshResponse.body);
        final newAccessToken = newData["accessToken"];
        final newRefreshToken = newData["refreshToken"];
        await prefs.setString("accessToken", newAccessToken);
        await prefs.setString("refreshToken", newRefreshToken);

        final retry = await ApiService.getProfile(accessToken: newAccessToken);
        if (retry.statusCode == 200) {
          final data = jsonDecode(retry.body);
          fullName = data["fullName"];
          email = data["email"];
          phoneNumber = data["phoneNumber"];
          wallet = (data["wallet"] ?? 0).toDouble();
          rating = (data["rating"] ?? 0).toDouble();
        }
      } else {
        await prefs.clear();
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Phiên đăng nhập hết hạn, vui lòng đăng nhập lại")),
          );
          Navigator.pushReplacementNamed(context, "/login");
        }
      }
    } else {
      debugPrint("Lỗi load profile nhà thầu: ${response.body}");
    }

    _isLoading = false;
    notifyListeners();
  }
}
