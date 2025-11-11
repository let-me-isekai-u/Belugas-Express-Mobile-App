import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/Contructor/Contractor_home_screen.dart';
import 'screens/splash_screen.dart';
import 'models/home_model.dart';
import 'models/contructor_home_model.dart';

void main() {
  runApp(const BegulasApp());
}

class BegulasApp extends StatelessWidget {
  const BegulasApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HomeModel()),
        ChangeNotifierProvider(create: (_) => ContractorHomeModel()),
      ],
      child: MaterialApp(
        title: "Beluga Express",
        theme: AppTheme.theme,
        debugShowCheckedModeBanner: false,
        home: const SplashScreen(), // SplashScreen là màn hình đầu tiên
        routes: {
          '/home': (_) => const HomeScreen(accessToken: ''), // placeholder
          '/contractorHome': (_) => const ContractorHomeScreen(),
          '/login': (_) => const LoginScreen(),
        },
      ),
    );
  }
}
