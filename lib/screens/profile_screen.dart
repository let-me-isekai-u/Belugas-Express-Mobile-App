import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'change_password_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';

class ProfileScreen extends StatelessWidget {
  final String fullName;
  final String email;
  final String phoneNumber;

  const ProfileScreen({
    super.key,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
  });

  // 🆕 Hàm mở Zalo
  Future<void> _openZalo() async {
    final Uri zaloUrl = Uri.parse('https://zalo.me/0932265471'); // 🔹 thay số Zalo thật nếu cần
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
        subtitle: Text(value, style: const TextStyle(fontSize: 15, fontFamily: 'Serif')),
      ),
    );
  }

  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => LoginScreen()),
          (route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.blue[300],
        title: const Text("Trang cá nhân", style: TextStyle(fontFamily: 'Serif')),
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

            // Thông tin cá nhân
            _buildInfoTile("Họ tên", fullName, Icons.badge),
            _buildInfoTile("Email", email, Icons.email),
            _buildInfoTile("Số điện thoại", phoneNumber, Icons.phone),

            const SizedBox(height: 10),

            // 🆕 Nút Zalo nhỏ góc phải trên phần nút chức năng
            Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Align(
                alignment: Alignment.centerRight,
                child: GestureDetector(
                  onTap: _openZalo,
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: Image.asset(
                      'lib/assets/icons/icons8-zalo-100.png',
                      width: 32,
                      height: 32,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            // Nút chức năng
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange[400],
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => ChangePasswordScreen(email: email)),
                        );
                      },
                      icon: const Icon(Icons.lock),
                      label: const Text("Đổi mật khẩu",
                          style: TextStyle(fontSize: 16, fontFamily: 'Serif')),
                    ),
                  ),
                  const SizedBox(height: 12),
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
                      label: const Text("Đăng xuất",
                          style: TextStyle(fontSize: 16, fontFamily: 'Serif')),
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
