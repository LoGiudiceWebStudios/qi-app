import 'dart:ui';
import 'package:flutter/material.dart';
import '../../data/services/auth_api_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _nameController = TextEditingController();
  String _email = '';
  int _punti = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    try {
      final profile = await AuthApiService.getProfile();
      if (mounted) {
        setState(() {
          final nome = profile['nome'] ?? '';
          final cognome = profile['cognome'] ?? '';
          _nameController.text = "$nome $cognome".trim();
          _email = profile['email'] ?? '';
          _punti = profile['punti'] ?? 0;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Stack(
        children: [
          // Sfondo condiviso
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          Scaffold(
            backgroundColor: Colors.transparent,
            appBar: AppBar(
              backgroundColor: Colors.transparent,
              elevation: 0,
              automaticallyImplyLeading: false,
              title: const Text(
                'Account Settings',
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
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 20.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Full Name",
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontFamily: 'Open Sauce',
                      ),
                    ),
                    const SizedBox(height: 6),
                    _buildTextField(controller: _nameController),
                    const SizedBox(height: 18),

                    // Email section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Email Address:",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Open Sauce',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _email.isNotEmpty ? _email : "...",
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.7),
                                fontSize: 14,
                                fontFamily: 'Open Sauce',
                                decoration: TextDecoration.underline,
                                decorationColor: Colors.white.withOpacity(0.7),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox.shrink(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Divider(color: Colors.white.withOpacity(0.2), thickness: 1),
                    const SizedBox(height: 14),

                    // Password section
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              "Password:",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontFamily: 'Open Sauce',
                              ),
                            ),
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                Text(
                                  "******************",
                                  style: TextStyle(
                                    color: Colors.white.withOpacity(0.7),
                                    fontSize: 14,
                                    fontFamily: 'Open Sauce',
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Icon(
                                  Icons.chevron_right,
                                  color: Colors.white.withOpacity(0.7),
                                  size: 18,
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox.shrink(),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Divider(color: Colors.white.withOpacity(0.2), thickness: 1),
                    const SizedBox(height: 20),

                    // Saldo Punti Card
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(16),
                        color: Colors.white.withOpacity(
                          0.9,
                        ), // Semi-trasparente per fondersi un po'
                      ),
                      child: Column(
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 12,
                              horizontal: 20,
                            ),
                            decoration: const BoxDecoration(
                              color: Color(0xFFF59E0B),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(16),
                                topRight: Radius.circular(16),
                              ),
                            ),
                            child: const Text(
                              "Saldo Punti",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Open Sauce',
                              ),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            child: Column(
                              children: [
                                const Text(
                                  "HAI UN TOTALE DI",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Open Sauce',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  _punti.toString(),
                                  style: TextStyle(
                                    color: Color(0xFFF59E0B),
                                    fontSize: 52,
                                    fontWeight: FontWeight.w900,
                                    height: 1.0,
                                    fontFamily: 'Open Sauce',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                const Text(
                                  "PUNTI",
                                  style: TextStyle(
                                    color: Colors.black,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Open Sauce',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Logout + Elimina account
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () async {
                            await AuthApiService.logout();
                            if (context.mounted) {
                              Navigator.pushReplacementNamed(context, '/login');
                            }
                          },
                          child: Row(
                            children: const [
                              Text(
                                "logout",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontFamily: 'Open Sauce',
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.white,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.exit_to_app,
                                color: Colors.white,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 18),
                        GestureDetector(
                          onTap: () async {
                            final shouldDelete = await showDialog<bool>(
                              context: context,
                              builder: (dialogContext) {
                                return AlertDialog(
                                  title: const Text('Elimina account'),
                                  content: const Text('Sei sicuro? Questa azione non puo essere annullata.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(dialogContext).pop(false),
                                      child: const Text('Annulla'),
                                    ),
                                    TextButton(
                                      onPressed: () => Navigator.of(dialogContext).pop(true),
                                      child: const Text('Elimina', style: TextStyle(color: Colors.red)),
                                    ),
                                  ],
                                );
                              },
                            );

                            if (shouldDelete != true) return;

                            setState(() => _isLoading = true);
                            try {
                              await AuthApiService.deleteAccount();
                              if (context.mounted) {
                                Navigator.pushReplacementNamed(context, '/login');
                              }
                            } catch (e) {
                              if (context.mounted) {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Errore eliminazione account')),
                                );
                              }
                            } finally {
                              if (mounted) setState(() => _isLoading = false);
                            }
                          },
                          child: Row(
                            children: const [
                              Text(
                                "elimina account",
                                style: TextStyle(
                                  color: Colors.redAccent,
                                  fontSize: 14,
                                  fontFamily: 'Open Sauce',
                                  fontWeight: FontWeight.w600,
                                  decoration: TextDecoration.underline,
                                  decorationColor: Colors.redAccent,
                                ),
                              ),
                              SizedBox(width: 8),
                              Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                                size: 18,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(height: 25),

                    // SALVA button
                    SizedBox(
                      width: double.infinity,
                      height: 60,
                      child: ElevatedButton(
                        onPressed: () async {
                           // Splittiamo il nome dal cognome in modo basic dal controller (opzionale o avanzato a seconda)
                           final nameParts = _nameController.text.trim().split(' ');
                           final nome = nameParts.isNotEmpty ? nameParts.first : '';
                           final cognome = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';
                           
                           setState(() => _isLoading = true);
                           try {
                             await AuthApiService.updateProfile(nome: nome, cognome: cognome);
                             if (context.mounted) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text('Profilo aggiornato!')),
                               );
                             }
                           } catch (e) {
                             if (context.mounted) {
                               ScaffoldMessenger.of(context).showSnackBar(
                                 const SnackBar(content: Text('Errore aggiornamento')),
                               );
                             }
                           } finally {
                             if (mounted) setState(() => _isLoading = false);
                           }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFF59E0B),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(11.0),
                          ),
                        ),
                        child: const Text(
                          "SALVA",
                          style: TextStyle(
                            fontFamily: 'Open Sauce',
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            letterSpacing: 1.2,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 60), // Ridotto lo spazio finale per la bottom bar
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({required TextEditingController controller}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5.0, sigmaY: 5.0),
        child: TextField(
          controller: controller,
          style: const TextStyle(
            fontFamily: 'Open Sauce',
            color: Colors.white,
            fontSize: 16,
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.black.withOpacity(0.2),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Colors.white, width: 1.5),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.3),
                width: 1.0,
              ),
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide(
                color: Colors.white.withOpacity(0.3),
                width: 1.0,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
