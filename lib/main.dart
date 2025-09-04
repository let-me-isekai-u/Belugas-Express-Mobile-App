import 'package:flutter/material.dart';
import 'app_theme.dart';
import 'screens/login_screen.dart';

void main() {
  runApp(BegulasApp());
}

class BegulasApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Begulas Express",
      theme: AppTheme.theme,
      home: LoginScreen(),
    );
  }
}
