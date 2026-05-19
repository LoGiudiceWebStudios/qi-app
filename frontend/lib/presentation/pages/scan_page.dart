import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../core/theme/app_colors.dart';
import '../widgets/custom_top_bar.dart';

class ScanPage extends StatefulWidget {
  const ScanPage({super.key});

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> {
  final TextEditingController _codeController = TextEditingController();

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
            title: 'SCAN',
            backgroundColor: AppColors.topBarOffers,
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
                    'Ogni 100 punti corrispondono ad uno sconto del 10% sul tuo acquisto. Per riscuotere i punti ti basta mostrare il Qr Code in cassa.',
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
                      onPressed: () {},
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFF19E15),
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
                        'Per raccogliere i punti del tuo ultimo acquisto recati in cassa ed un volta effettuato il pagamento chiedi il codice per la riscossione dei punti, il cassiere ti mostrera un codice qr e a te bastera scansionarlo direttamente dall\'app tramite la funzione che trovi nella barra di navigazione',
                    initiallyExpanded: true,
                  ),
                  const SizedBox(height: 14),
                  const _GuidaItem(
                    title: '2. Quanti punti ottengo?',
                    content: 'Otterrai 1 punto per ogni euro speso.',
                  ),
                  const SizedBox(height: 14),
                  const _GuidaItem(
                    title: '3. Come vedo il saldo dei miei punti?',
                    content:
                        'Puoi vedere il saldo dei tuoi punti aggiornato in tempo reale direttamente in questa pagina, all\'interno della tua Qi Card in alto.',
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQiCard() {
    return AspectRatio(
      aspectRatio: 359 / 219,
      child: Container(
        width: double.infinity,
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: const Color(0xFFF19E15),
          borderRadius: BorderRadius.circular(24),
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
                                child: SvgPicture.asset(
                                  'assets/icons/Logo.svg',
                                  width: 28,
                                  height: 28,
                                  fit: BoxFit.contain,
                                  placeholderBuilder:
                                      (context) => const Text(
                                        'Q',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 20,
                                          color: Colors.black,
                                        ),
                                      ),
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
                          text: const TextSpan(
                            style: TextStyle(
                              fontFamily: 'Open Sauce',
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: Colors.black,
                              height: 1.2,
                            ),
                            children: [
                              TextSpan(text: 'Hai '),
                              TextSpan(
                                text: '150',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 27,
                                ),
                              ),
                              TextSpan(text: ' punti\ndisponibili'),
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
                      Container(
                        width: 130,
                        height: 130,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.qr_code_2,
                            size: 110,
                            color: Colors.black,
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
