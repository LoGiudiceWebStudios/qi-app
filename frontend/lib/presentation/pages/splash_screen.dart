import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({Key? key}) : super(key: key);

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Simulate some loading time, e.g. checking auth state
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Sfondo con l'immagine reale dal tavolo (assumendo ce ne sia una o la setti dopo)
          Image.asset(
            'assets/images/background.png', 
            
          ),
          
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                  Image.asset(
                    'assets/icons/Logo.png',
                    width: 212,
                    height: 212,
                    fit: BoxFit.contain,
                  ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
