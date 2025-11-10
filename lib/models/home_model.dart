import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class HomeModel extends ChangeNotifier {
  int? userId; // <-- Thêm dòng này để lưu userId
  String? fullName;
  String? email;
  String? phoneNumber;

  /// Số dư ví (cập nhật bởi API 23 - getWalletBalance)
  double? wallet;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  /// Hàm load profile khi vào HomeScreen
  /// Nếu đã có userId từ login thì truyền vào initialUserId
  Future<void> loadProfile(BuildContext context, {int? initialUserId}) async {
    if (initialUserId != null) {
      userId = initialUserId; // Lưu userId từ login
    }

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

    try {
      var response = await ApiService.getProfile(accessToken: accessToken).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        fullName = data["fullName"]?.toString();
        email = data["email"]?.toString();
        phoneNumber = data["phoneNumber"]?.toString();

        // Nếu API profile trả wallet luôn, cập nhật
        try {
          if (data.containsKey("wallet")) {
            final w = data["wallet"];
            if (w is num) wallet = w.toDouble();
            else if (w is String) wallet = double.tryParse(w);
          }
        } catch (_) {}

        // Nếu profile không trả wallet, gọi API 23 để lấy chi tiết ví
        if (wallet == null) {
          await fetchWallet(context: context);
        }
      } else if (response.statusCode == 401) {
        // Token hết hạn => gọi refreshToken
        final success = await _refreshTokensAndRetry(prefs, refreshToken);
        if (success) {
          // sau khi refresh token, gọi lại profile
          final newAccess = prefs.getString("accessToken");
          if (newAccess != null) {
            var retry = await ApiService.getProfile(accessToken: newAccess).timeout(const Duration(seconds: 10));
            if (retry.statusCode == 200) {
              final data = jsonDecode(retry.body);
              fullName = data["fullName"]?.toString();
              email = data["email"]?.toString();
              phoneNumber = data["phoneNumber"]?.toString();
              try {
                if (data.containsKey("wallet")) {
                  final w = data["wallet"];
                  if (w is num) wallet = w.toDouble();
                  else if (w is String) wallet = double.tryParse(w);
                }
              } catch (_) {}
            }
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
        debugPrint("Lỗi load profile: ${response.statusCode} ${response.body}");
      }
    } catch (e) {
      debugPrint("Lỗi khi gọi profile: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Gọi API 23 (getWalletBalance) để cập nhật số dư ví.
  /// Nếu cần có thể truyền context để model có thể điều hướng / hiển thị snackbar khi refresh token thất bại.
  Future<void> fetchWallet({BuildContext? context}) async {
    final prefs = await SharedPreferences.getInstance();
    String? accessToken = prefs.getString("accessToken");
    String? refreshToken = prefs.getString("refreshToken");

    if (accessToken == null || refreshToken == null) {
      return;
    }

    try {
      final res = await ApiService.getWalletBalance(accessToken: accessToken).timeout(const Duration(seconds: 10));
      if (res.statusCode == 200) {
        final body = jsonDecode(res.body);
        double? w;

        // Hỗ trợ nhiều dạng trả về: số, chuỗi, object {wallet|balance}, {data: ...}
        if (body is num) {
          w = body.toDouble();
        } else if (body is String) {
          w = double.tryParse(body);
        } else if (body is Map) {
          if (body.containsKey('wallet') && body['wallet'] is num) {
            w = (body['wallet'] as num).toDouble();
          } else if (body.containsKey('balance') && body['balance'] is num) {
            w = (body['balance'] as num).toDouble();
          } else if (body.containsKey('data')) {
            final d = body['data'];
            if (d is num) w = d.toDouble();
            else if (d is Map && (d['wallet'] is num || d['balance'] is num)) {
              if (d['wallet'] is num) w = (d['wallet'] as num).toDouble();
              else if (d['balance'] is num) w = (d['balance'] as num).toDouble();
            }
          }
        }

        if (w != null) {
          wallet = w;
          notifyListeners();
        } else {
          debugPrint("fetchWallet: không parse được body: ${res.body}");
        }
      } else if (res.statusCode == 401) {
        // Thử refresh token và retry
        final success = await _refreshTokensAndRetry(prefs, refreshToken);
        if (success) {
          final newAccess = prefs.getString("accessToken");
          if (newAccess != null) {
            // retry once
            final retry = await ApiService.getWalletBalance(accessToken: newAccess).timeout(const Duration(seconds: 10));
            if (retry.statusCode == 200) {
              final body = jsonDecode(retry.body);
              double? w;
              if (body is num) w = body.toDouble();
              else if (body is String) w = double.tryParse(body);
              else if (body is Map) {
                if (body.containsKey('wallet') && body['wallet'] is num) {
                  w = (body['wallet'] as num).toDouble();
                } else if (body.containsKey('balance') && body['balance'] is num) {
                  w = (body['balance'] as num).toDouble();
                }
              }
              if (w != null) {
                wallet = w;
                notifyListeners();
              }
            }
          }
        } else {
          // Refresh token fail => bắt login lại
          await prefs.clear();
          if (context != null && context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Phiên đăng nhập hết hạn, vui lòng login lại")),
            );
            Navigator.pushReplacementNamed(context, "/login");
          }
        }
      } else {
        debugPrint("fetchWallet lỗi: ${res.statusCode} ${res.body}");
      }
    } catch (e) {
      debugPrint("Lỗi khi gọi getWalletBalance: $e");
    }
  }

  /// Helper: gọi API refresh token, nếu thành công lưu lại SharedPreferences và trả về true
  Future<bool> _refreshTokensAndRetry(SharedPreferences prefs, String refreshToken) async {
    try {
      final refreshResponse = await ApiService.refreshToken(refreshToken: refreshToken).timeout(const Duration(seconds: 10));
      if (refreshResponse.statusCode == 200) {
        final newData = jsonDecode(refreshResponse.body);
        final String? newAccessToken = newData["accessToken"]?.toString();
        final String? newRefreshToken = newData["refreshToken"]?.toString();

        if (newAccessToken != null && newRefreshToken != null) {
          await prefs.setString("accessToken", newAccessToken);
          await prefs.setString("refreshToken", newRefreshToken);
          return true;
        }
      } else {
        debugPrint("refreshToken failed: ${refreshResponse.statusCode} ${refreshResponse.body}");
      }
    } catch (e) {
      debugPrint("Lỗi khi refresh token: $e");
    }
    return false;
  }

  /// Cho phép set ví thủ công (ví dụ sau khi nạp tiền thành công)
  void setWallet(double? value) {
    wallet = value;
    notifyListeners();
  }
}