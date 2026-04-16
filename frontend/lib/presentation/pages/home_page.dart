import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../widgets/custom_card_widget.dart';
import '../../data/api/event_api.dart';
import '../../data/models/event_model.dart';

import '../../data/services/api_service.dart';

// Modelli Dati fittizi per offerta, la parte EventModel la rimuoviamo perché la leggiamo dal backend

class OfferModel {
  final String id;
  final String title;
  final String? imageUrl;
  OfferModel({required this.id, required this.title, this.imageUrl});
}

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Colori come richiesto
  final Color greenColor = const Color(0xFF008F30);
  final Color yellowColor = const Color(0xFFE9B416);
  final Color purpleColor = const Color(0xFFc084fc); // Preso dal mockup originale
  
  // Future per caricare gli eventi dal Backend
  late Future<List<Event>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = EventApi().fetchEvents();
  }

  final List<OfferModel> offers = [
    OfferModel(id: '1', title: 'Offerta 1'),
    OfferModel(id: '2', title: 'Offerta 2'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFA), // Sfondo chiaro
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // TOP SECTION: Header con Immagine e Card Fluttuante
            _buildTopHeader(context),
            
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
                      _buildQuickActionButton('Menu', Icons.restaurant_menu_rounded, greenColor),
                      const SizedBox(width: 12),
                      _buildQuickActionButton('Offerte', Icons.local_offer_outlined, yellowColor),
                      const SizedBox(width: 12),
                      _buildQuickActionButton('Eventi', Icons.calendar_month_outlined, purpleColor),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 36),

            // EVENTI COLLEGATI AL BACKEND
            FutureBuilder<List<Event>>(
              future: _eventsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text('Impossibile caricare gli eventi: ${snapshot.error}', style: const TextStyle(color: Colors.red)),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return const Center(
                    child: Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24.0),
                      child: Text('Nessun evento in programma', style: TextStyle(color: Colors.grey)),
                    ),
                  );
                }

                // Dati ricevuti con successo!
                final events = snapshot.data!;

                return _buildHorizontalSection(
                  title: 'Eventi',
                  actionText: 'Vedi tutto',
                  actionColor: greenColor,
                  itemsCount: events.length,
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return CustomCardWidget(
                      // CustomCardWidget probabilmente andrà adattato per ricevere anche il titolo ecc.
                      // Per ora passiamo l'immagine se esiste o null. Se il backend invia un URL relativo aggiungiamo la base
                      borderColor: greenColor,
                      imageUrl: (event.immagineUrl != null && event.immagineUrl!.isNotEmpty) 
                                ? "${ApiService.serverUrl}${event.immagineUrl!.startsWith('/') ? '' : '/'}${event.immagineUrl!.replaceAll('\\', '/')}" 
                                : null,
                    );
                  },
                );
              },
            ),

            const SizedBox(height: 36),

            // OFFERTE
            _buildHorizontalSection(
              title: 'Offerte',
              actionText: 'Vedi tutto',
              actionColor: yellowColor,
              itemsCount: offers.length,
              itemBuilder: (context, index) {
                return CustomCardWidget(
                  borderColor: yellowColor,
                  imageUrl: offers[index].imageUrl,
                );
              },
            ),

            const SizedBox(height: 36),
          ],
        ),
      ),
    );
  }

  Widget _buildTopHeader(BuildContext context) {
    // Altezza aggiornata in modo che la card sia tutta dentro l'immagine
    return SizedBox(
      height: 380,
      child: Stack(
        children: [
          // Sfondo con immagine burger
          Container(
            height: 380,
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
                    child: SvgPicture.asset(
                      'assets/icons/Logo.svg', // Se è un SVG vero
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                      // Fallback in caso SVG dia errore
                      placeholderBuilder: (context) => const Text('Q', style: TextStyle(fontWeight: FontWeight.bold, fontFamily: 'Open Sauce', fontSize: 18)),
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
            bottom: 24, // Sola alzata rispetto a bottom: 0 per rimanere interamente dentro l'immagine
            left: 24,
            right: 24,
            child: Container(
              height: 110,
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
                  )
                ],
              ),
              child: Column(
                children: [
                  // Prima metà superiore gialla (Header Card)
                  Container(
                    height: 46,
                    decoration: BoxDecoration(
                      color: yellowColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(24),
                        topRight: Radius.circular(24),
                      ),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 22,
                          height: 22,
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                          child: const Center(child: Text('Q', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, fontFamily: 'Open Sauce'))),
                        ),
                        const SizedBox(width: 8),
                        // Pallino verde
                        Container(width: 8, height: 8, decoration: BoxDecoration(color: greenColor, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        const Text(
                          'Aperto',
                          style: TextStyle(
                            fontFamily: 'Open Sauce',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Pallino grigio
                        Container(width: 8, height: 8, decoration: const BoxDecoration(color: Colors.grey, shape: BoxShape.circle)),
                        const SizedBox(width: 6),
                        const Text(
                          'Fino alle 02:00',
                          style: TextStyle(
                            fontFamily: 'Open Sauce',
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
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
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Dove Siamo',
                                style: TextStyle(fontFamily: 'Open Sauce', color: greenColor, fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Via Luigi Enaudi',
                                style: TextStyle(fontFamily: 'Open Sauce', color: Colors.black54, fontSize: 12),
                              ),
                            ],
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
                                style: TextStyle(fontFamily: 'Open Sauce', color: yellowColor, fontWeight: FontWeight.w700, fontSize: 13),
                              ),
                              const SizedBox(height: 2),
                              const Text(
                                'Karaoke Night',
                                style: TextStyle(fontFamily: 'Open Sauce', color: Colors.black54, fontSize: 12),
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

  Widget _buildQuickActionButton(String title, IconData icon, Color color) {
    return Expanded(
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: color.withOpacity(0.5), // Bordo semi trasparente colorato
            width: 1.5,
          ),
          boxShadow: [
             BoxShadow(color: Colors.grey.withOpacity(0.05), spreadRadius: 0, blurRadius: 10, offset: const Offset(0, 4)),
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
              Text(
                actionText,
                style: TextStyle(
                  fontFamily: 'Open Sauce',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: actionColor,
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

