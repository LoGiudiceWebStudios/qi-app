import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/services/auth_api_service.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String code;
  
  const ResetPasswordScreen({super.key, required this.email, required this.code});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscure = true;

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              color: Colors.black.withOpacity(0.2),
            ),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              leading: IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 36),
                onPressed: () => Navigator.of(context).pop(),
              ),
              title: const Text(
                'New Password',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  fontFamily: 'Open Sauce',
                ),
              ),
              centerTitle: false,
              titleSpacing: 0,
            ),
            body: SafeArea(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Create your new password.",
                      style: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Open Sauce'),
                    ),
                    const SizedBox(height: 40),
                    _buildTextField("New Password", _passwordController),
                    const SizedBox(height: 16),
                    _buildTextField("Confirm Password", _confirmController),
                    const SizedBox(height: 40),
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : () async {
                          final pass = _passwordController.text.trim();
                          final confirm = _confirmController.text.trim();
                          if (pass != confirm) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le password non coincidono.')));
                            return;
                          }
                          if (pass.length < 8) {
                            ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('La password deve essere di almeno 8 caratteri.')));
                            return;
                          }
                          setState(() => _isLoading = true);
                          try {
                            bool success = await AuthApiService.resetPassword(email: widget.email, code: widget.code, newPassword: pass);
                            if (success && mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Password reimpostata.')));
                              Navigator.popUntil(context, ModalRoute.withName('/login'));
                            }
                          } catch (e) {
                             if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.toString().replaceAll('Exception: ', ''))));
                          } finally {
                            if (mounted) setState(() => _isLoading = false);
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE9B416),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(11.0)),
                        ),
                        child: _isLoading 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text("RESET PASSWORD", style: TextStyle(fontFamily: 'Open Sauce', color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField(String hint, TextEditingController controller) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: TextField(
          controller: controller,
          obscureText: _obscure,
          style: const TextStyle(fontFamily: 'Open Sauce', color: Colors.white),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(fontFamily: 'Open Sauce', color: Colors.white.withOpacity(0.6), fontSize: 16),
            filled: true,
            fillColor: Colors.black.withOpacity(0.2), 
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
            focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: Colors.white, width: 1.5)),
            enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withOpacity(0.5))),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.white.withOpacity(0.5))),
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_off : Icons.visibility, color: Colors.white.withOpacity(0.7)),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
        ),
      ),
    );
  }
}
