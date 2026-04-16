import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../data/api/auth_api.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;
  bool _savePassword = false;

  bool _isLoading = false;

  final Color orangeColor = const Color(0xFFF59E0B);

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
      final res = await AuthApi().login(email, pass);
      // Login Successo (Salva il token JWT, Naviga)
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(), // Chiude la tastiera toccando sul bianco
      child: Stack(
        children: [
          // Sfondo dietro allo Scaffold, così non si ridimensiona con la tastiera
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover, // Usa cover per riempire tutto lo schermo in modo uniforme
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent, // Permette di vedere lo sfondo dietro
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Column(
                  children: [
                    const SizedBox(height: 40),
                  
                  // LOGO
                  Image.asset(
                    'assets/icons/Logo.png',
                    width: 212,
                    height: 212,
                    fit: BoxFit.contain,
                  ),
                  
                  const SizedBox(height: 30),
                  
                  // Social Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildSocialButton('', backupIcon: Icons.g_mobiledata), // Cambia poi col logo png/svg corretto di google
                      const SizedBox(width: 24),
                      _buildSocialButton('', backupIcon: Icons.apple),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  const Text("Or", style: TextStyle(color: Colors.white, fontSize: 16)),
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
                                borderRadius: BorderRadius.circular(4), // Quadrato arrotondato
                                border: Border.all(color: Colors.white, width: 1.5),
                              ),
                              child: _savePassword
                                  ? const Icon(Icons.check, size: 14, color: Colors.white)
                                  : null,
                            ),
                            const SizedBox(width: 8),
                            const Text("Save Password", style: TextStyle(fontFamily: 'Open Sauce', color: Colors.white, fontSize: 13)),
                          ],
                        ),
                      ),
                      TextButton(
                        onPressed: () {},
                        child: const Text("Forgot password?", style: TextStyle(fontFamily: 'Open Sauce', color: Colors.white70)),
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
                      child: _isLoading
                          ? const SizedBox(
                              height: 24,
                              width: 24,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                            )
                          : const Text("ACCEDI", style: TextStyle(fontFamily: 'Open Sauce', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                    ),
                  ),
                  
                  const SizedBox(height: 16), // Più vicino al signup
                  
                  // Sign Up
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? ", style: TextStyle(fontFamily: 'Open Sauce', color: Colors.white70)),
                      GestureDetector(
                        onTap: () {},
                        child: const Text("Sign Up", style: TextStyle(fontFamily: 'Open Sauce', color: Colors.white, fontWeight: FontWeight.bold)),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 12),
                  
                  // Linea di divisione
                  Divider(color: Colors.white.withOpacity(0.3), thickness: 1, indent: 40, endIndent: 40),
                  
                  const SizedBox(height: 12),
                  
                  // Terms
                  Text(
                    "By continuing, you agree to our Terms of Service\nand Privacy policy",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12),
                  )
                ],
              ),
            ),
          ),
          ), // Chiude Scaffold
        ],
      ),
    );
  }

  Widget _buildSocialButton(String assetsPath, {IconData? backupIcon}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
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
                ? Icon(backupIcon, color: Colors.white, size: 32) // Icona ingrandita a 32
                : Image.asset(assetsPath, width: 28, height: 28),
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
            hintStyle: TextStyle(fontFamily: 'Open Sauce', color: Colors.white.withOpacity(0.6), fontSize: 16),
            filled: true,
            fillColor: Colors.black.withOpacity(0.2), // Trasparenza base + blur
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.white, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.0),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.white.withOpacity(0.5), width: 1.0),
            ),
            suffixIcon: isPassword
                ? IconButton(
                    icon: Icon(
                      _obscurePassword ? Icons.visibility_off : Icons.visibility,
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
