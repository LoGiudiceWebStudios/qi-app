import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'dart:convert';
import '../../core/theme/app_colors.dart';
import '../widgets/custom_top_bar.dart';
import 'qr_scanner_page.dart';
import '../../data/services/api_service.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final TextEditingController _codeController = TextEditingController();
  int? _userPoints;
  int? _userId;
  String? _userName;
  bool _isLoadingPoints = true;
  Future<List<dynamic>>? _rewardsFuture;

  @override
  void initState() {
    super.initState();
    _fetchProfile();
    _rewardsFuture = _fetchRewards();
  }

  Future<List<dynamic>> _fetchRewards() async {
    try {
      final response = await ApiService.dio.get('/rewards');
      if (response.statusCode == 200) {
        if (response.data is List) {
          return response.data;
        } else if (response.data['data'] is List) {
          return response.data['data'];
        }
      }
      return [];
    } catch (e) {
      debugPrint("Errore fetching rewards: $e");
      return [];
    }
  }

  Future<void> _fetchProfile() async {
    try {
      final response = await ApiService.dio.get('/profile');
      if (response.statusCode == 200) {
        setState(() {
          final data = response.data['data'] ?? response.data;
          _userPoints = data['punti'];
          _userId = data['id'];
          _userName = data['nome'];
          _isLoadingPoints = false;
        });
      }
    } catch (e) {
      print("Errore fetchProfile: $e");
      setState(() => _isLoadingPoints = false);
    }
  }

  @override
  void dispose() {
    _codeController.dispose();
    super.dispose();
  }

  void _redeemCode() {
    final code = _codeController.text.trim();
    if (code.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Inserisci un codice valido.')),
      );
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Codice "$code" inviato con successo.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFA),
      body: Column(
        children: [
          const CustomTopBar(
            title: 'QI CARD',
            backgroundColor: Color(0xFFE9B416),
            icon: Icons.qr_code_scanner,
            showStar: false,
            titleStyle: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontFamily: 'Open Sauce',
              fontWeight: FontWeight.w700,
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 120),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQiCard(),
                  const SizedBox(height: 18),
                  const Text(
                    'Raccogli i punti con i tuoi acquisti e utilizzali per sbloccare fantastici premi! Per ottenere punti, ti basta inquadrare il Qr Code dalla cassa.',
                    style: TextStyle(
                      fontSize: 14,
                      color: Color(0xFF374151),
                      height: 1.4,
                      fontFamily: 'Open Sauce',
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    height: 1.5,
                    width: double.infinity,
                    color: const Color(0xFFE5E7EB),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Inserisci Punti',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Open Sauce',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () async {
                        final result = await Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const QrScannerPage(),
                          ),
                        );
                        if (result == true) {
                          _fetchProfile();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE9B416),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Text(
                            'SCANSIONA',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              fontFamily: 'Open Sauce',
                              letterSpacing: 1.1,
                            ),
                          ),
                          SizedBox(width: 8),
                          Icon(
                            Icons.qr_code_scanner,
                            color: Colors.white,
                            size: 24,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Container(
                    height: 1.5,
                    width: double.infinity,
                    color: const Color(0xFFE5E7EB),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Guida',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Open Sauce',
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 18),
                  const _GuidaItem(
                    title: '1. Come funziona?',
                    content:
                        'Per raccogliere punti, recati in cassa. Una volta effettuato il pagamento, chiedi il codice per la riscossione dei punti: il cassiere ti mostrerà un codice QR. Ti basterà scansionarlo tramite l\'app per aggiungerli al tuo saldo e sbloccare i premi sottostanti!',
                    initiallyExpanded: true,
                  ),
                  const SizedBox(height: 14),
                  const _GuidaItem(
                    title: '2. Quanti punti ottengo?',
                    content: 'Otterrai 1 punto per ogni euro speso.',
                  ),
                  const SizedBox(height: 14),
                  const _GuidaItem(
                    title: '3. Come uso i punti?',
                    content:
                        'Scorri verso il basso nella sezione "Premi" per scegliere la ricompensa che preferisci. Quando avrai saldo sufficiente potrai riscuotere il tuo premio in cassa!',
                  ),
                  const SizedBox(height: 32),
                  Container(
                    height: 1.5,
                    width: double.infinity,
                    color: const Color(0xFFE5E7EB),
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Premi',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Open Sauce',
                      color: Colors.black,
                    ),
                  ),
                  _buildPremiSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPremiSection() {
    return FutureBuilder<List<dynamic>>(
      future: _rewardsFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }
        if (snapshot.hasError) {
          return const Text(
            'Errore nel caricamento dei premi.',
            style: TextStyle(fontFamily: 'Open Sauce'),
          );
        }
        final rewards = snapshot.data ?? [];
        if (rewards.isEmpty) {
          return const Text(
            'Nessun premio disponibile al momento.',
            style: TextStyle(fontFamily: 'Open Sauce'),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.only(top: 14),
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: rewards.length,
          separatorBuilder: (context, index) => const SizedBox(height: 14),
          itemBuilder: (context, index) {
            final reward = rewards[index];
            return Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFE5E7EB)),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x0A000000),
                    blurRadius: 10,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.topBarOffers.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Center(
                      child: Icon(
                        Icons.card_giftcard,
                        color: AppColors.topBarOffers,
                        size: 30,
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          reward['titolo'] ?? 'Premio',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Color(0xFFE9B416),
                            fontWeight: FontWeight.bold,
                            fontFamily: 'Open Sauce',
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          reward['descrizione'] ?? '',
                          style: const TextStyle(
                            fontSize: 13,
                            color: Color(0xFF6B7280),
                            fontFamily: 'Open Sauce',
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${reward['punti_richiesti'] ?? 0} Punti',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: const Color(0xFFE9B416),
                            fontFamily: 'Open Sauce',
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildQiCard() {
    return AspectRatio(
      aspectRatio: 359 / 219,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFE9B416),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Stack(
          children: [
            Positioned(
              right: -60,
              top: -50,
              bottom: -50,
              child: Container(
                width: 280,
                decoration: const BoxDecoration(
                  color: Color(0xFFFBEAD2),
                  shape: BoxShape.circle,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 50,
                              height: 50,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/icons/Logo.png',
                                  width: 50,
                                  height: 50,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'Qi Card',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Open Sauce',
                              ),
                            ),
                          ],
                        ),
                        const Spacer(),
                        RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontFamily: 'Open Sauce',
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                              height: 1.2,
                            ),
                            children: [
                              const TextSpan(text: 'Hai '),
                              TextSpan(
                                text:
                                    _isLoadingPoints
                                        ? '...'
                                        : '${_userPoints ?? 0}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 27,
                                ),
                              ),
                              const TextSpan(text: ' punti\ndisponibili'),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      Material(
                        color: Colors.transparent,
                        child: InkWell(
                          onTap: () async {
                            final result = await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QrScannerPage(),
                              ),
                            );
                            if (result == true) {
                              _fetchProfile();
                            }
                          },
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            width: 130,
                            height: 130,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child:
                                  _isLoadingPoints
                                      ? const CircularProgressIndicator()
                                      : QrImageView(
                                        data: jsonEncode({
                                          'action': 'user_info',
                                          'id': _userId ?? 0,
                                          'punti': _userPoints ?? 0,
                                          'name': _userName ?? 'Utente',
                                        }),
                                        version: QrVersions.auto,
                                        size: 110.0,
                                        padding: EdgeInsets.zero,
                                      ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _GuidaItem extends StatefulWidget {
  final String title;
  final String content;
  final bool initiallyExpanded;

  const _GuidaItem({
    required this.title,
    required this.content,
    this.initiallyExpanded = false,
  });

  @override
  State<_GuidaItem> createState() => _GuidaItemState();
}

class _GuidaItemState extends State<_GuidaItem> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 4,
            spreadRadius: 1,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: widget.initiallyExpanded,
          onExpansionChanged: (expanded) {
            setState(() {
              _isExpanded = expanded;
            });
          },
          title: Text(
            widget.title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              fontFamily: 'Open Sauce',
              color: Colors.black,
            ),
          ),
          iconColor: Colors.black,
          collapsedIconColor: Colors.black,
          childrenPadding: const EdgeInsets.only(
            left: 16,
            right: 16,
            bottom: 16,
            top: 0,
          ),
          children: [
            Text(
              widget.content,
              style: const TextStyle(
                fontSize: 15,
                color: Color(0xFF6B7280),
                height: 1.4,
                fontFamily: 'Open Sauce',
              ),
            ),
          ],
        ),
      ),
    );
  }
}
