import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/splash_screen.dart';
import 'presentation/pages/login_screen.dart';

void main() {
  runApp(
    const ProviderScope(
      child: QiApp(),
    ),
  );
}

class QiApp extends StatelessWidget {
  const QiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QI App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginScreen(),
        '/home': (context) => const HomePage(), // Andrà sostituito da Nav Screen in futuro
      },
    );
  }
}
