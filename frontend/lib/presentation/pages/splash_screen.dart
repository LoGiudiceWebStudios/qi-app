import 'package:flutter/material.dart';
import 'dart:io' show Platform;
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'update_screen.dart';
import '../../data/services/secure_storage_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _checkVersionAndNavigate();
  }

  Future<void> _checkVersionAndNavigate() async {
    bool needsUpdate = false;
    String storeUrl = '';
    String nextRoute = '/login';

    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      await remoteConfig.setConfigSettings(RemoteConfigSettings(
        fetchTimeout: const Duration(seconds: 10),
        minimumFetchInterval: const Duration(minutes: 5), // Fetch often during dev
      ));

      // Defaults
      await remoteConfig.setDefaults(const {
        'force_update_version': '1.0.0',
        'store_url_android': 'https://play.google.com/store/apps/details?id=com.qifoodfocus.app',
        'store_url_ios': 'https://apps.apple.com/app/id123456789',
      });

      await remoteConfig.fetchAndActivate();

      final forceVersion = remoteConfig.getString('force_update_version');
      final androidUrl = remoteConfig.getString('store_url_android');
      final iosUrl = remoteConfig.getString('store_url_ios');
      
      if (Platform.isAndroid) {
        storeUrl = androidUrl;
      } else if (Platform.isIOS) {
        storeUrl = iosUrl;
      }
      
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version; 

      if (_isVersionLower(currentVersion: currentVersion, requiredVersion: forceVersion)) {
        needsUpdate = true;
      }
    } catch (e) {
      debugPrint('Errore durante il controllo della versione: $e');
    }

    // Minimo tempo di attesa per mostrare la splash
    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;

    if (needsUpdate) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UpdateScreen(storeUrl: storeUrl)),
      );
    } else {
      final token = await SecureStorageService.getToken();
      if (token != null && token.isNotEmpty) {
        // Se il token esiste, manteniamo la sessione locale ed entriamo in home.
        // Evitiamo di invalidarlo in splash per errori temporanei di rete/server.
        nextRoute = '/home';
      }

      Navigator.pushReplacementNamed(context, nextRoute);
    }
  }

  bool _isVersionLower({required String currentVersion, required String requiredVersion}) {
    List<String> currentParts = currentVersion.split('.');
    List<String> requiredParts = requiredVersion.split('.');

    for (int i = 0; i < currentParts.length && i < requiredParts.length; i++) {
      int currentPart = int.tryParse(currentParts[i]) ?? 0;
      int requiredPart = int.tryParse(requiredParts[i]) ?? 0;

      if (currentPart < requiredPart) {
        return true; // E.g., 1.0.0 < 1.0.1
      } else if (currentPart > requiredPart) {
        return false;
      }
    }
    return false; // Equal versions
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
                    'assets/icons/Logo_2.jpg',
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
