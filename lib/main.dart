import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'l10n/app_localizations.dart';
import 'app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'screens/Contructor/Contractor_home_screen.dart';
import 'screens/splash_screen.dart';
import 'models/home_model.dart';
import 'models/contructor_home_model.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ⭐ Đọc ngôn ngữ đã lưu, nếu chưa có → tiếng Việt
  final prefs = await SharedPreferences.getInstance();
  final savedLang = prefs.getString('languageCode') ?? 'vi';

  runApp(BegulasApp(initialLocale: Locale(savedLang)));
}

class BegulasApp extends StatefulWidget {
  final Locale initialLocale;
  const BegulasApp({super.key, required this.initialLocale});

  @override
  State<BegulasApp> createState() => _BegulasAppState();
}

class _BegulasAppState extends State<BegulasApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
  }

  // ⭐ Hàm đổi ngôn ngữ & lưu lại SharedPreferences
  void setLocale(Locale locale) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('languageCode', locale.languageCode);
    setState(() => _locale = locale);
  }

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

        // ⭐ Áp dụng locale toàn app
        locale: _locale,

        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: const [
          AppLocalizations.delegate,
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],

        localeResolutionCallback: (locale, supportedLocales) {
          if (locale != null) {
            for (var supportedLocale in supportedLocales) {
              if (supportedLocale.languageCode == locale.languageCode) {
                return supportedLocale;
              }
            }
          }
          return supportedLocales.first;
        },

        // ⭐ Truyền setLocale vào Splash để Login nhận được
        home: SplashScreen(onLocaleChange: setLocale),

        routes: {
          '/home': (_) => HomeScreen(
              accessToken: '',
              onLocaleChange: setLocale,
          ),
          '/contractorHome': (_) => ContractorHomeScreen(onLocaleChange: setLocale),

          '/login': (_) => LoginScreen(onLocaleChange: setLocale),
        },
      ),
    );
  }
}
