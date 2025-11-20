import 'package:flutter/material.dart';
import 'change_password_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import '../l10n/app_localizations.dart';
import '../services/api_service.dart';
import 'dart:convert';

class ProfileScreen extends StatelessWidget {
  final String fullName;
  final String email;
  final String phoneNumber;
  final void Function(Locale)? onLocaleChange;

  const ProfileScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    this.onLocaleChange,
  });

  Future<void> _openZalo() async {
    final Uri zaloUrl = Uri.parse('https://zalo.me/0932265471');
    if (await canLaunchUrl(zaloUrl)) {
      await launchUrl(zaloUrl, mode: LaunchMode.externalApplication);
    }
  }

  Widget _buildInfoTile(String title, String value, IconData icon) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: Icon(icon, color: Colors.blue[400]),
        title: Text(title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Serif')),
        subtitle: Text(value,
            style: const TextStyle(fontSize: 15, fontFamily: 'Serif')),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
  }

  Future<void> _showSnackBar(BuildContext context, String message) async {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  // Lấy token: ưu tiên key "accessToken" (như HomeModel dùng), có fallback
  Future<String> _getAccessTokenFromPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('accessToken') ??
        prefs.getString('access_token') ??
        prefs.getString('token') ??
        prefs.getString('jwt') ??
        '';
  }

  Future<void> _showDeleteAccountDialog(BuildContext context) async {
    final loc = AppLocalizations.of(context)!;
    String code = "";

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(loc.deleteAccountButton),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(loc.enterVerificationCode ?? "Nhập mã xác thực"),
            const SizedBox(height: 10),
            TextField(
              onChanged: (v) => code = v,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                labelText: loc.verificationCode ?? "Mã xác thực",
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(loc.cancel ?? "Cancel"),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);

              final accessToken = await _getAccessTokenFromPrefs();

              if (accessToken.isEmpty) {
                await _showSnackBar(context, "Không tìm thấy token. Vui lòng đăng nhập lại.");
                return;
              }

              // Hiển thị loading
              showDialog(
                context: context,
                barrierDismissible: false,
                builder: (_) => const Center(child: CircularProgressIndicator()),
              );

              try {
                debugPrint("Deleting account: token length = ${accessToken.length}");

                final response =
                await ApiService.deleteAccount(accessToken: accessToken, code: code);

                Navigator.pop(context); // đóng loading

                String message = "Có lỗi xảy ra";
                try {
                  final body = jsonDecode(response.body);
                  if (body is Map && body.containsKey("message")) {
                    message = body["message"]?.toString() ?? message;
                  } else if (body is Map && body.containsKey("success") && body["success"] == true) {
                    message = "Thành công";
                  } else {
                    message = response.body;
                  }
                } catch (_) {
                  message = response.body.isNotEmpty ? response.body : message;
                }

                if (response.statusCode == 200) {
                  _logout(context);
                } else {
                  await _showSnackBar(context, message);
                }
              } catch (e) {
                try {
                  Navigator.pop(context);
                } catch (_) {}
                await _showSnackBar(context, "Lỗi kết nối: $e");
              }
            },
            child: Text(
              loc.confirm ?? "Confirm",
              style: const TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _sendVerificationAndDelete(BuildContext context) async {
    // Hiện loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      final response = await ApiService.sendVerificationCode(email: email);

      Navigator.pop(context); // đóng loading

      if (response.statusCode == 200) {
        bool ok = true;
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body.containsKey("success")) {
            ok = body["success"] == true;
          }
        } catch (_) {}

        if (ok) {
          await _showDeleteAccountDialog(context);
        } else {
          String msg = "Không thể gửi mã xác thực";
          try {
            final body = jsonDecode(response.body);
            if (body is Map && body.containsKey("message")) msg = body["message"].toString();
          } catch (_) {}
          await _showSnackBar(context, msg);
        }
      } else {
        String msg = "Không thể gửi mã xác thực";
        try {
          final body = jsonDecode(response.body);
          if (body is Map && body.containsKey("message")) msg = body["message"].toString();
        } catch (_) {}
        await _showSnackBar(context, msg);
      }
    } catch (e) {
      try {
        Navigator.pop(context);
      } catch (_) {}
      await _showSnackBar(context, "Lỗi kết nối: $e");
    }
  }

  // Helper: tạo danh sách PopupMenuItems để dùng ở cả showMenu
  List<PopupMenuEntry<int>> _buildMenuItems(AppLocalizations loc) {
    return [
      PopupMenuItem(
        value: 1,
        child: Row(
          children: [
            const Icon(Icons.language, color: Colors.blue),
            const SizedBox(width: 10),
            Text(loc.changeLanguage),
          ],
        ),
      ),
      PopupMenuItem(
        value: 2,
        child: Row(
          children: [
            const Icon(Icons.lock, color: Colors.orange),
            const SizedBox(width: 10),
            Text(loc.changePasswordButton),
          ],
        ),
      ),
      PopupMenuItem(
        value: 3,
        child: Row(
          children: [
            const Icon(Icons.delete, color: Colors.red),
            const SizedBox(width: 10),
            Text(loc.deleteAccountButton),
          ],
        ),
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        title: Text(loc.profileTitle, style: const TextStyle(fontFamily: 'Serif')),
        actions: [
          // Thay PopupMenuButton bằng IconButton + showMenu để await khi menu đóng
          Builder(
            builder: (context) {
              return IconButton(
                icon: const Icon(Icons.settings, color: Colors.white, size: 30),
                onPressed: () async {
                  // Tính vị trí menu dựa trên icon widget
                  final RenderBox button = context.findRenderObject() as RenderBox;
                  final RenderBox overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
                  final RelativeRect position = RelativeRect.fromRect(
                    Rect.fromPoints(
                      button.localToGlobal(Offset.zero, ancestor: overlay),
                      button.localToGlobal(Offset(button.size.width, button.size.height), ancestor: overlay),
                    ),
                    Offset.zero & overlay.size,
                  );

                  final selected = await showMenu<int>(
                    context: context,
                    position: position,
                    items: _buildMenuItems(loc),
                    // color: Colors.white, // nếu muốn style
                    elevation: 4,
                  );

                  // showMenu returns only after menu is dismissed, so safe to act now
                  if (selected == null) {
                    return; // user dismissed menu
                  }

                  if (selected == 1) {
                    // Đổi ngôn ngữ: capture current locale và gọi onLocaleChange
                    final currentLocale = Localizations.localeOf(context);
                    final newLocale = currentLocale.languageCode == 'vi'
                        ? const Locale('en')
                        : const Locale('vi');
                    onLocaleChange?.call(newLocale);
                  } else if (selected == 2) {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (_) => ChangePasswordScreen(email: email),
                    ));
                  } else if (selected == 3) {
                    // Gửi mã xác thực trước khi show dialog
                    // Hiển thị loading
                    showDialog(
                      context: context,
                      barrierDismissible: false,
                      builder: (_) => const Center(child: CircularProgressIndicator()),
                    );

                    try {
                      final response = await ApiService.sendVerificationCode(email: email);
                      Navigator.pop(context); // close loading

                      if (response.statusCode == 200) {
                        _showDeleteAccountDialog(context);
                      } else {
                        String msg = "Không thể gửi mã xác thực";
                        try {
                          final body = jsonDecode(response.body);
                          if (body is Map && body.containsKey("message")) msg = body["message"].toString();
                        } catch (_) {}
                        await _showSnackBar(context, msg);
                      }
                    } catch (e) {
                      try {
                        Navigator.pop(context);
                      } catch (_) {}
                      await _showSnackBar(context, "Lỗi kết nối: $e");
                    }
                  }
                },
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 16),
            CircleAvatar(
              radius: 45,
              backgroundColor: Colors.blue[200],
              child: const Icon(Icons.person, size: 60, color: Colors.white),
            ),
            const SizedBox(height: 16),
            _buildInfoTile(loc.profileName, fullName, Icons.badge),
            _buildInfoTile(loc.profileEmail, email, Icons.email),
            _buildInfoTile(loc.profilePhone, phoneNumber, Icons.phone),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.only(right: 28),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _openZalo,
                  child: Column(
                    children: [
                      CircleAvatar(
                        radius: 40,
                        backgroundColor: Colors.white,
                        child: Image.asset(
                          'lib/assets/icons/icons8-zalo-100.png',
                          width: 45,
                          height: 45,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        loc.profileContactUs,
                        style: const TextStyle(
                          fontSize: 14,
                          fontFamily: 'Serif',
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red[400],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => _logout(context),
                      icon: const Icon(Icons.logout),
                      label: Text(loc.logoutButton,
                          style: const TextStyle(fontSize: 16, fontFamily: 'Serif')),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}