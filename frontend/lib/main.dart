import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'core/theme/app_theme.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/splash_screen.dart';
import 'presentation/pages/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inizializza Firebase
  try {
    await Firebase.initializeApp();
  } catch (e) {
    debugPrint("Errore inizializzazione Firebase: $e");
  }

  runApp(const ProviderScope(child: QiApp()));
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
        '/home':
            (context) =>
                const HomePage(), // HomePage include ora la shell con floating navbar
      },
    );
  }
}
