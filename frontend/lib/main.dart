import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/home_page.dart';

void main() {
  runApp(const QiApp());
}

class QiApp extends StatelessWidget {
  const QiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'QI App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme, // Usiamo il tema scuro come in Directa
      home: const HomePage(),
    );
  }
}
