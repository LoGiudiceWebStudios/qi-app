import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import '../../data/services/auth_api_service.dart';
import 'forgot_password_screen.dart';
import 'signup_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final GoogleSignIn _googleSignIn = GoogleSignIn(
  serverClientId: 'INCOLLA_QUI_IL_TUO_WEB_CLIENT_ID.apps.googleusercontent.com',
);
  bool _obscurePassword = true;
  bool _savePassword = false;

  bool _isLoading = false;

  final Color orangeColor = const Color(0xFFE9B416);

  // Focus nodes per chiudere la tastiera tappando fuori
  final _emailFocus = FocusNode();
  final _passFocus = FocusNode();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passFocus.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _emailController.text.trim();
    final pass = _passwordController.text.trim();

    if (email.isEmpty || pass.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci email e password')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final res = await AuthApiService.login(email, pass);
      // Login Successo (Salva il token JWT, Naviga)
      if (res && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  Future<void> _handleGoogleSignIn() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return; // L'utente ha annullato

      setState(() => _isLoading = true);

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      final success = await AuthApiService.socialLogin(
        provider: 'google',
        socialId: googleUser.id,
        idToken: googleAuth.idToken, // Add idToken to the request
        email: googleUser.email,
        name: googleUser.displayName ?? 'Google User',
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore Google Sign-In: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleAppleSignIn() async {
    try {
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      setState(() => _isLoading = true);

      final success = await AuthApiService.socialLogin(
        provider: 'apple',
        socialId: credential.userIdentifier!,
        idToken: credential.identityToken, // Add idToken to the request for backend validation
        email: credential.email ?? '${credential.userIdentifier}@apple.id', // Fallback se non fornisce l'email
        name: (credential.givenName != null) 
              ? '${credential.givenName} ${credential.familyName}'
              : 'Apple User',
      );

      if (success && mounted) {
        Navigator.pushReplacementNamed(context, '/home');
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Errore Apple Sign-In: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap:
          () =>
              FocusScope.of(
                context,
              ).unfocus(), // Chiude la tastiera toccando sul bianco
      child: Stack(
        children: [
          // Sfondo dietro allo Scaffold, così non si ridimensiona con la tastiera
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit:
                  BoxFit
                      .cover, // Usa cover per riempire tutto lo schermo in modo uniforme
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0),
            ),
          ),
          Scaffold(
            backgroundColor:
                Colors.transparent, // Permette di vedere lo sfondo dietro
            body: SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24.0,
                      vertical: 40.0,
                    ),
                    child: Column(
                      children: [
                        const SizedBox(height: 40),

                        // LOGO
                        Image.asset(
                          'assets/icons/Logo_2.jpg',
                          width: 212,
                          height: 212,
                          fit: BoxFit.contain,
                        ),

                    const SizedBox(height: 30),

                    // Social Buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _buildSocialButton(
                          '',
                          backupIcon: Icons.g_mobiledata,
                          onTap: _handleGoogleSignIn,
                        ),
                        const SizedBox(width: 24),
                        _buildSocialButton(
                          '',
                          backupIcon: Icons.apple,
                          onTap: _handleAppleSignIn,
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      "Or",
                      style: TextStyle(color: Colors.white, fontSize: 16),
                    ),
                    const SizedBox(height: 24),

                    // Text Fields
                    _buildTextField(
                      hint: "Email",
                      controller: _emailController,
                      focusNode: _emailFocus,
                    ),
                    const SizedBox(height: 16),
                    _buildTextField(
                      hint: "Password",
                      controller: _passwordController,
                      isPassword: true,
                      focusNode: _passFocus,
                    ),

                    const SizedBox(height: 8), // Più vicini
                    // Save Password & Forgot
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            setState(() {
                              _savePassword = !_savePassword;
                            });
                          },
                          child: Row(
                            children: [
                              Container(
                                width: 18,
                                height: 18,
                                decoration: BoxDecoration(
                                  color: Colors.transparent,
                                  borderRadius: BorderRadius.circular(
                                    4,
                                  ), // Quadrato arrotondato
                                  border: Border.all(
                                    color: Colors.white,
                                    width: 1.5,
                                  ),
                                ),
                                child:
                                    _savePassword
                                        ? const Icon(
                                          Icons.check,
                                          size: 14,
                                          color: Colors.white,
                                        )
                                        : null,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                "Save Password",
                                style: TextStyle(
                                  fontFamily: 'Open Sauce',
                                  color: Colors.white,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder:
                                    (context) => const ForgotPasswordScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Forgot password?",
                            style: TextStyle(
                              fontFamily: 'Open Sauce',
                              color: Colors.white70,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16), // Più vicino all'Accedi
                    // ACCEDI Button
                    SizedBox(
                      width: double.infinity,
                      height: 60, // Ingrandito
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _handleLogin,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE9B416),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11.0),
                          ),
                        ),
                        child:
                            _isLoading
                                ? const SizedBox(
                                  height: 24,
                                  width: 24,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                                : const Text(
                                  "ACCEDI",
                                  style: TextStyle(
                                    fontFamily: 'Open Sauce',
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                  ),
                                ),
                      ),
                    ),

                    const SizedBox(height: 16), // Più vicino al signup
                    // Sign Up
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Don't have an account? ",
                          style: TextStyle(
                            fontFamily: 'Open Sauce',
                            color: Colors.white70,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const SignupScreen(),
                              ),
                            );
                          },
                          child: const Text(
                            "Sign Up",
                            style: TextStyle(
                              fontFamily: 'Open Sauce',
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 12),

                    // Linea di divisione
                    Divider(
                      color: Colors.white.withOpacity(0.3),
                      thickness: 1,
                      indent: 40,
                      endIndent: 40,
                    ),

                    const SizedBox(height: 12),

                    // Terms
                    RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                          fontFamily: 'Open Sauce',
                        ),
                        children: [
                          const TextSpan(text: "By continuing, you agree to our "),
                          TextSpan(
                            text: "Terms of Service",
                            style: const TextStyle(
                              color: Color(0xFFE9B416),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                final url = Uri.parse('https://example.com/terms');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                }
                              },
                          ),
                          const TextSpan(text: "\nand "),
                          TextSpan(
                            text: "Privacy policy",
                            style: const TextStyle(
                              color: Color(0xFFE9B416),
                              fontWeight: FontWeight.bold,
                              decoration: TextDecoration.underline,
                            ),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () async {
                                final url = Uri.parse('https://example.com/privacy');
                                if (await canLaunchUrl(url)) {
                                  await launchUrl(url, mode: LaunchMode.externalApplication);
                                }
                              },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 10,
                right: 16,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(context, '/home');
                  },
                  child: const Text(
                    "Skip",
                    style: TextStyle(
                      fontFamily: 'Open Sauce',
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ), // Chiude Scaffold
        ],
      ),
    );
  }

  Widget _buildSocialButton(String assetsPath, {IconData? backupIcon, VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        // ... (blur e color base rimangono)
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
          child: Container(
            width: 80, // Più grandi
            height: 56, // Più grandi
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12), // Risolve l'angolo tagliato
              border: Border.all(color: Colors.white.withOpacity(0.3)),
            ),
            child: Center(
              child: backupIcon != null
                  ? Icon(backupIcon, color: Colors.white, size: 30)
                  : Image.asset(assetsPath, width: 24, height: 24),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String hint,
    required TextEditingController controller,
    bool isPassword = false,
    FocusNode? focusNode,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: TextField(
          controller: controller,
          focusNode: focusNode,
          obscureText: isPassword ? _obscurePassword : false,
          style: const TextStyle(fontFamily: 'Open Sauce', color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(
              fontFamily: 'Open Sauce',
              color: Colors.white.withOpacity(0.6),
              fontSize: 16,
            ),
            filled: true,
            fillColor: Colors.black.withOpacity(0.2), // Trasparenza base + blur
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 20,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.5),
                width: 1.0,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.5),
                width: 1.0,
              ),
            ),
            suffixIcon:
                isPassword
                    ? IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.white.withOpacity(0.7),
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    )
                    : null,
          ),
        ),
      ),
    );
  }
}
