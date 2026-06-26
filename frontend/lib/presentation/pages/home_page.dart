import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../widgets/custom_card_widget.dart';
import '../../data/api/home_api.dart';
import '../../data/models/home_data.dart';
import '../widgets/floating_nav_bar.dart';
import '../manager/nav_provider.dart';
import '../../core/services/notification_service.dart';
import '../../data/services/secure_storage_service.dart';
import 'events_page.dart';
import 'offer_page.dart';
import 'scan_page.dart';
import 'menu_page.dart';
import 'profile_page.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../data/services/api_service.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  // Colori come richiesto
  final Color greenColor = const Color(0xFF008F30);
  final Color yellowColor = const Color(0xFFE9B416);
  final Color purpleColor = const Color(
    0xFFc084fc,
  ); // Preso dal mockup originale

  // Future per caricare dati Home combinando tutto e gestendo orari
  late Future<HomeData> _homeDataFuture;

  @override
  void initState() {
    super.initState();
    _homeDataFuture = HomeApi().fetchHomeData();
    
    // Richiedi i permessi per le notifiche solo dopo essere arrivati in Home (ovvero dopo il login)
    NotificationService.initialize();
  }

  void _showLoginRequiredMessage() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Il login è necessario per accedere a questa sezione.'),
        duration: Duration(seconds: 2),
      ),
    );
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    final selectedIndex = ref.watch(bottomNavIndexProvider);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFA),
      extendBody: true,
      body: IndexedStack(
        index: selectedIndex,
        children: [
          selectedIndex == 0 ? _buildHomeTab(context) : const SizedBox.shrink(),
          selectedIndex == 1 ? const OfferPage() : const SizedBox.shrink(),
          selectedIndex == 2 ? const ScanPage() : const SizedBox.shrink(),
          selectedIndex == 3 ? const MenuPage() : const SizedBox.shrink(),
          selectedIndex == 4 ? const ProfilePage() : const SizedBox.shrink(),
        ],
      ),
      bottomNavigationBar: SafeArea(
        top: false,
        child: FloatingNavBar(
          currentIndex: selectedIndex,
          onTap: (index) async {
              if (index == 0) {
                setState(() {
                  _homeDataFuture = HomeApi().fetchHomeData();
                });
                ref.read(bottomNavIndexProvider.notifier).setIndex(index);
              } else if (index == 3) {
                // Menu can be accessed without login
                ref.read(bottomNavIndexProvider.notifier).setIndex(index);
              } else {
                final token = await SecureStorageService.getToken();
                if (token == null) {
                  _showLoginRequiredMessage();
                } else {
                  ref.read(bottomNavIndexProvider.notifier).setIndex(index);
                }
              }
            },
        ),
      ),
    );
  }

  Widget _buildHomeTab(BuildContext context) {
    return FutureBuilder<HomeData>(
      future: _homeDataFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Errore: ${snapshot.error}', style: const TextStyle(color: Colors.red)));
        } else if (!snapshot.hasData) {
          return const Center(child: Text('Nessun dato'));
        }

        final homeData = snapshot.data!;

        return SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // TOP SECTION: Header con Immagine e Card Fluttuante
              _buildTopHeader(context, homeData),

              const SizedBox(height: 32),

          // QUICK ACTION
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Quick Action',
                  style: TextStyle(
                    fontFamily: 'Open Sauce',
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _buildQuickActionButton(
                      'Menu',
                      Icons.restaurant_menu_rounded,
                      greenColor,
                      onTap: () async {
                        // Menu can be accessed without login
                        ref.read(bottomNavIndexProvider.notifier).setIndex(3);
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildQuickActionButton(
                      'Offerte',
                      Icons.local_offer_outlined,
                      yellowColor,
                      onTap: () async {
                        final token = await SecureStorageService.getToken();
                        if (token == null) {
                          _showLoginRequiredMessage();
                        } else {
                          ref.read(bottomNavIndexProvider.notifier).setIndex(1);
                        }
                      },
                    ),
                    const SizedBox(width: 12),
                    _buildQuickActionButton(
                      'Eventi',
                      Icons.calendar_month_outlined,
                      purpleColor,
                      onTap: () async {
                        final token = await SecureStorageService.getToken();
                        if (token == null) {
                          _showLoginRequiredMessage();
                        } else {
                          Navigator.of(context).push(
                            MaterialPageRoute(builder: (_) => const EventsPage()),
                          );
                        }
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 36),

          // EVENTI COLLEGATI AL BACKEND
          if (homeData.events.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Nessun evento in programma',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            _buildHorizontalSection(
              title: 'Eventi',
              actionText: 'Vedi tutto',
              actionColor: greenColor,
              itemsCount: homeData.events.length,
              itemBuilder: (context, index) {
                final event = homeData.events[index];
                return CustomCardWidget(
                  borderColor: greenColor,
                  imageUrl:
                      (event.imageUrl.isNotEmpty)
                          ? (event.imageUrl.startsWith('http') 
                              ? event.imageUrl 
                              : "${ApiService.serverUrl}${event.imageUrl.startsWith('/') ? '' : '/'}${event.imageUrl.replaceAll('\\', '/')}")
                          : null,
                );
              },
            ),

          const SizedBox(height: 36),

          // OFFERTE
          if (homeData.offers.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 24.0),
                child: Text(
                  'Nessuna offerta in corso',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            _buildHorizontalSection(
              title: 'Offerte',
              actionText: 'Vedi tutto',
              actionColor: yellowColor,
              itemsCount: homeData.offers.length,
              itemBuilder: (context, index) {
                final offer = homeData.offers[index];
                return CustomCardWidget(
                  borderColor: yellowColor,
                  imageUrl:
                      (offer.imageUrl.isNotEmpty)
                          ? (offer.imageUrl.startsWith('http')
                              ? offer.imageUrl
                              : "${ApiService.serverUrl}${offer.imageUrl.startsWith('/') ? '' : '/'}${offer.imageUrl.replaceAll('\\', '/')}")
                          : null,
                );
              },
            ),

          const SizedBox(height: 120),
        ],
      ),
    );
    },
    );
  }

  Widget _buildTopHeader(BuildContext context, HomeData homeData) {
    // Altezza aggiornata in modo che la card sia tutta dentro l'immagine
    return SizedBox(
      height: 400,
      child: Stack(
        children: [
          // Sfondo con immagine burger
          Container(
            height: 400,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/DeliciousBurger.png'),
                fit: BoxFit.cover,
              ),
            ),
          ),

          // Sfumatura nera in testa per dare visibilità al Logo
          Container(
            height: 120,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.black.withOpacity(0.6), Colors.transparent],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),

          // Header testuale / Logo in alto a sinistra
          Positioned(
            top: 56,
            left: 24,
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Image.asset(
                      'assets/icons/Logo.png',
                      width: 40,
                      height: 40,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                const Text(
                  'Qi - food & focus',
                  style: TextStyle(
                    fontFamily: 'Open Sauce',
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),

          // ont ("Aperto" / "Dove Siamo" / "Prossimo Evento")
          Positioned(
            bottom:
                24, // Sola alzata rispetto a bottom: 0 per rimanere interamente dentro l'immagine
            left: 24,
            right: 24,
            child: Container(
              height: 130,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    spreadRadius: 0,
                    blurRadius: 15,
                    offset: const Offset(0, 8),
                  ),
                  // Bordo come nell'immagine, o solo ombra. Dall'immagine sembra avere un sottile giallo intorno.
                  BoxShadow(
                    color: yellowColor.withOpacity(0.5),
                    spreadRadius: 1,
                  ),
                ],
              ),
              child: Column(
                children: [
                  // Prima metà superiore gialla (Header Card)
                  Container(
                    height: 66,
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    decoration: BoxDecoration(
                      color: yellowColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Riga Locale
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              width: 18,
                              height: 18,
                              decoration: const BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Image.asset(
                                  'assets/icons/Logo.png',
                                  width: 24,
                                  height: 24,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Pallino verde / rosso
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: homeData.isOpen ? greenColor : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              homeData.isOpen ? 'Locale Aperto' : 'Locale Chiuso',
                              style: const TextStyle(
                                fontFamily: 'Open Sauce',
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Pallino grigio
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              homeData.isOpen
                                  ? 'Fino alle ${homeData.closingTime}'
                                  : 'Apre alle ${homeData.openingTime}',
                              style: const TextStyle(
                                fontFamily: 'Open Sauce',
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        // Riga Cucina
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.restaurant, size: 14, color: Colors.black54),
                            const SizedBox(width: 6),
                            // Pallino verde / rosso per cucina
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                color: homeData.isKitchenOpen ? greenColor : Colors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              homeData.isKitchenOpen ? 'Cucina Aperta' : 'Cucina Chiusa',
                              style: const TextStyle(
                                fontFamily: 'Open Sauce',
                                fontWeight: FontWeight.w700,
                                fontSize: 13,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(width: 8),
                            // Pallino grigio per cucina
                            Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: Colors.grey,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              homeData.isKitchenOpen
                                  ? 'Fino alle ${homeData.kitchenClosingTime}'
                                  : 'Apre alle ${homeData.kitchenOpeningTime}',
                              style: const TextStyle(
                                fontFamily: 'Open Sauce',
                                color: Colors.black54,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  // Seconda metà per (Dove Siamo / Evento)
                  Expanded(
                    child: Row(
                      children: [
                        // Left
                        Expanded(
                          child: GestureDetector(
                            onTap: () async {
                              final query = Uri.encodeComponent('Via Luigi Einaudi, 18, 95024 Acireale CT');
                              final url = Uri.parse('https://www.google.com/maps/search/?api=1&query=$query');
                              if (await canLaunchUrl(url)) {
                                await launchUrl(url, mode: LaunchMode.externalApplication);
                              }
                            },
                            child: Container(
                              color: Colors.transparent, // Necessario per ricevere il tap su tutta l'area
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    'Dove Siamo',
                                    style: TextStyle(
                                      fontFamily: 'Open Sauce',
                                      color: greenColor,
                                      fontWeight: FontWeight.w700,
                                      fontSize: 13,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  const Text(
                                    'Via Luigi Einaudi, 18',
                                    style: TextStyle(
                                      fontFamily: 'Open Sauce',
                                      color: Colors.black54,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),

                        // Linea Divisoria
                        Container(
                          width: 1,
                          height: 36,
                          color: Colors.grey[200],
                        ),

                        // Right
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Prossimo evento',
                                style: TextStyle(
                                  fontFamily: 'Open Sauce',
                                  color: yellowColor,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                homeData.nextEvent.isNotEmpty
                                    ? homeData.nextEvent
                                    : (homeData.events.isNotEmpty
                                        ? homeData.events.first.title
                                        : 'Nessun evento'),
                                style: const TextStyle(
                                  fontFamily: 'Open Sauce',
                                  color: Colors.black54,
                                  fontSize: 12,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton(
    String title,
    IconData icon,
    Color color, {
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            height: 100,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withOpacity(0.5), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.05),
                  spreadRadius: 0,
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, color: color, size: 30),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Open Sauce',
                    color: Color(0xFF1F2937),
                    fontWeight: FontWeight.w500,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalSection({
    required String title,
    required String actionText,
    required Color actionColor,
    required int itemsCount,
    required IndexedWidgetBuilder itemBuilder,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontFamily: 'Open Sauce',
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  final token = await SecureStorageService.getToken();
                  if (token == null) {
                    _showLoginRequiredMessage();
                  } else {
                    if (title == 'Eventi') {
                      Navigator.of(context).push(MaterialPageRoute(builder: (_) => const EventsPage()));
                    } else if (title == 'Offerte') {
                      ref.read(bottomNavIndexProvider.notifier).setIndex(1);
                    }
                  }
                },
                child: Text(
                  actionText,
                  style: TextStyle(
                    fontFamily: 'Open Sauce',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: actionColor,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: 320, // Altezza listview proporzionale alle card più grandi
          child: ListView.separated(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            scrollDirection: Axis.horizontal,
            itemCount: itemsCount,
            separatorBuilder: (context, index) => const SizedBox(width: 12),
            itemBuilder: itemBuilder,
          ),
        ),
      ],
    );
  }
}


