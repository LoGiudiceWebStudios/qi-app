import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/home_page.dart';

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
      home: HomePage(),
    );
  }
}
