/*

import 'package:flutter/material.dart';
// Usiamo l'import relativo o il nome del pacchetto (se hai lasciato "name: frontend" nel pubspec)
import '../../data/services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  String _serverMessage = 'Premi il bottone per testare il server locale';
  bool _isLoading = false;

  void _testConnection() async {
    setState(() => _isLoading = true);

    final result = await _apiService.pingBackend();

    setState(() {
      _serverMessage = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QI App Dashboard'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.settings_input_antenna,
                  size: 80, color: Colors.blueAccent),
              const SizedBox(height: 24),
              Text(
                _serverMessage,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _testConnection,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.bolt),
                label: const Text('Ping Backend Go'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

*/
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 390,
          height: 1544,
          decoration: BoxDecoration(color: const Color(0xFFFBFBF5)),
          child: Stack(
            children: [
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  width: 390,
                  height: 422,
                  child: Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: Container(
                          width: 390,
                          height: 421.50,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Container(
                                  width: double.infinity,
                                  clipBehavior: Clip.antiAlias,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          "https://placehold.co/390x422"),
                                      fit: BoxFit.fill,
                                    ),
                                  ),
                                  child: Stack(),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 0,
                        top: 36,
                        child: Container(
                          width: 390,
                          height: 422,
                          child: Stack(
                            children: [
                              Positioned(
                                left: 26,
                                top: 20,
                                child: Container(
                                  width: 43,
                                  height: 43,
                                  decoration: BoxDecoration(
                                    image: DecorationImage(
                                      image: NetworkImage(
                                          "https://placehold.co/43x43"),
                                      fit: BoxFit.cover,
                                    ),
                                  ),
                                ),
                              ),
                              Positioned(
                                left: 75,
                                top: 21,
                                child: SizedBox(
                                  width: 186,
                                  height: 41,
                                  child: Text(
                                    'Qi - food & focus',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 20,
                                      fontFamily: 'Syne',
                                      fontWeight: FontWeight.w700,
                                      height: 3.60,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Positioned(
                        left: 24,
                        top: 292.50,
                        child: Container(
                          width: 342.68,
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Container(
                                width: 342,
                                height: 105,
                                decoration: ShapeDecoration(
                                  color: Colors.white,
                                  shape: RoundedRectangleBorder(
                                    side: BorderSide(
                                      width: 2,
                                      color: const Color(0xFFF59E0B),
                                    ),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  shadows: [
                                    BoxShadow(
                                      color: Color(0xFF000000),
                                      blurRadius: 0,
                                      offset: Offset(4, 4),
                                      spreadRadius: 0,
                                    )
                                  ],
                                ),
                                child: Stack(
                                  children: [
                                    Positioned(
                                      left: 19,
                                      top: 49,
                                      child: Container(
                                        width: 306,
                                        height: 43.50,
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Container(
                                              width: 166,
                                              height: double.infinity,
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 8),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: double.infinity,
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        SizedBox(
                                                          width: 106,
                                                          height: 28,
                                                          child: Text(
                                                            'Dove Siamo',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color: const Color(
                                                                  0xFF10B981),
                                                              fontSize: 15,
                                                              fontFamily:
                                                                  'Syne',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              height: 1.87,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 100,
                                                    height: 16,
                                                    child: Text(
                                                      'Via Luigi Enaudi',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: const Color(
                                                            0xFF6B7280),
                                                        fontSize: 12,
                                                        fontFamily: 'Syne',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 1.33,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                            Container(
                                              width: 172,
                                              height: double.infinity,
                                              padding: const EdgeInsets.only(
                                                  left: 12, right: 8),
                                              decoration: ShapeDecoration(
                                                shape: RoundedRectangleBorder(
                                                  side: BorderSide(
                                                    width: 2,
                                                    color:
                                                        const Color(0xFFF3F4F6),
                                                  ),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  Container(
                                                    width: double.infinity,
                                                    child: Column(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .center,
                                                      children: [
                                                        SizedBox(
                                                          width: 150,
                                                          height: 28,
                                                          child: Text(
                                                            'Prossimo evento',
                                                            textAlign: TextAlign
                                                                .center,
                                                            style: TextStyle(
                                                              color: const Color(
                                                                  0xFFF59E0B),
                                                              fontSize: 15,
                                                              fontFamily:
                                                                  'Syne',
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w700,
                                                              height: 1.87,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    width: 80.28,
                                                    height: 16,
                                                    child: Text(
                                                      'Karaoke Night',
                                                      textAlign:
                                                          TextAlign.center,
                                                      style: TextStyle(
                                                        color: const Color(
                                                            0xFF6B7280),
                                                        fontSize: 12,
                                                        fontFamily: 'Syne',
                                                        fontWeight:
                                                            FontWeight.w400,
                                                        height: 1.33,
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 1,
                                      top: 1.50,
                                      child: Container(
                                        width: 341,
                                        height: 42,
                                        decoration: ShapeDecoration(
                                          color: const Color(0xFFF59E0B),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.only(
                                              topLeft: Radius.circular(20),
                                              topRight: Radius.circular(20),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 108,
                                      top: 7.50,
                                      child: SizedBox(
                                        width: 69,
                                        height: 28,
                                        child: Text(
                                          'Aperto',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: const Color(0xFF090B0A),
                                            fontSize: 15,
                                            fontFamily: 'Syne',
                                            fontWeight: FontWeight.w700,
                                            height: 1.87,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 189,
                                      top: 13.50,
                                      child: SizedBox(
                                        width: 99,
                                        height: 16,
                                        child: Text(
                                          'Fino alle 02:00',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(
                                            color: const Color(0xFF6B7280),
                                            fontSize: 15,
                                            fontFamily: 'Syne',
                                            fontWeight: FontWeight.w400,
                                            height: 1.07,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Positioned(
                                      left: 67,
                                      top: 7.50,
                                      child: Container(
                                        width: 29,
                                        height: 29,
                                        decoration: BoxDecoration(
                                          image: DecorationImage(
                                            image: NetworkImage(
                                                "https://placehold.co/29x29"),
                                            fit: BoxFit.cover,
                                          ),
                                        ),
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
                ),
              ),
              Positioned(
                left: 0,
                top: 437,
                child: Container(
                  width: 390,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    spacing: 32,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 151.34,
                        child: Stack(
                          children: [
                            Positioned(
                              left: 8,
                              top: 0,
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 196,
                                    height: 32,
                                    child: Text(
                                      'Quick Action',
                                      style: TextStyle(
                                        color: const Color(0xFF1F2937),
                                        fontSize: 27,
                                        fontFamily: 'Syne',
                                        fontWeight: FontWeight.w500,
                                        height: 1.19,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Positioned(
                              left: 0,
                              top: 48,
                              child: Container(
                                width: 342,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  spacing: 9,
                                  children: [
                                    Container(
                                      width: 107,
                                      height: 97,
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            width: 2.50,
                                            color: const Color(0x4C10B981),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        shadows: [
                                          BoxShadow(
                                            color: Color(0x0C000000),
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                            spreadRadius: 0,
                                          )
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            left: 40.36,
                                            top: 18.74,
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 28.11,
                                            top: 48.24,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 51,
                                                  height: 28,
                                                  child: Text(
                                                    'Menu',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: const Color(
                                                          0xFF1F2937),
                                                      fontSize: 18,
                                                      fontFamily: 'Syne',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.56,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 107,
                                      height: 97,
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            width: 2.50,
                                            color: const Color(0x4CF59E0B),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        shadows: [
                                          BoxShadow(
                                            color: Color(0x0C000000),
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                            spreadRadius: 0,
                                          )
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            left: 38.98,
                                            top: 17.66,
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 23.72,
                                            top: 47,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 57,
                                                  height: 28,
                                                  child: Text(
                                                    'Offerte',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: const Color(
                                                          0xFF1F2937),
                                                      fontSize: 18,
                                                      fontFamily: 'Syne',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.56,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Container(
                                      width: 107,
                                      height: 97,
                                      decoration: ShapeDecoration(
                                        color: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                            width: 2.50,
                                            color: const Color(0x4CC084FC),
                                          ),
                                          borderRadius:
                                              BorderRadius.circular(20),
                                        ),
                                        shadows: [
                                          BoxShadow(
                                            color: Color(0x0C000000),
                                            blurRadius: 2,
                                            offset: Offset(0, 1),
                                            spreadRadius: 0,
                                          )
                                        ],
                                      ),
                                      child: Stack(
                                        children: [
                                          Positioned(
                                            left: 40.10,
                                            top: 17.67,
                                            child: Container(
                                              padding: const EdgeInsets.only(
                                                  bottom: 4),
                                              child: Column(
                                                mainAxisSize: MainAxisSize.min,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.start,
                                                children: [
                                                  Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [],
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                          Positioned(
                                            left: 21.59,
                                            top: 47,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SizedBox(
                                                  width: 60,
                                                  height: 28,
                                                  child: Text(
                                                    'Eventi',
                                                    textAlign: TextAlign.center,
                                                    style: TextStyle(
                                                      color: const Color(
                                                          0xFF1F2937),
                                                      fontSize: 18,
                                                      fontFamily: 'Syne',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                      height: 1.56,
                                                    ),
                                                  ),
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
                      ),
                      Container(
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 16,
                          children: [
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                spacing: 171.67,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 114,
                                        height: 36,
                                        child: Text(
                                          'Eventi',
                                          style: TextStyle(
                                            color: const Color(0xFF1F2937),
                                            fontSize: 27,
                                            fontFamily: 'Syne',
                                            fontWeight: FontWeight.w500,
                                            height: 1.33,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 76,
                                        height: 20,
                                        child: Text(
                                          'Vedi tutto',
                                          style: TextStyle(
                                            color: const Color(0xFF10B981),
                                            fontSize: 14,
                                            fontFamily: 'Syne',
                                            fontWeight: FontWeight.w700,
                                            height: 1.43,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 390,
                              height: 336,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(),
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 24,
                                    top: -0.34,
                                    child: Container(
                                      width: 366,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        spacing: 17,
                                        children: [
                                          Container(
                                            width: 236,
                                            height: 320,
                                            decoration: ShapeDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    "https://placehold.co/236x320"),
                                                fit: BoxFit.cover,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 2,
                                                  color: const Color(
                                                      0xFF10B981) /* Green */,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(32),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 236,
                                            height: 320,
                                            decoration: ShapeDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    "https://placehold.co/236x320"),
                                                fit: BoxFit.cover,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 2,
                                                  color: const Color(
                                                      0xFF10B981) /* Green */,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(32),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      Container(
                        width: double.infinity,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          spacing: 16,
                          children: [
                            Container(
                              width: double.infinity,
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 4),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                spacing: 171.67,
                                children: [
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 114,
                                        height: 36,
                                        child: Text(
                                          'Offerte ',
                                          style: TextStyle(
                                            color: const Color(0xFF1F2937),
                                            fontSize: 27,
                                            fontFamily: 'Syne',
                                            fontWeight: FontWeight.w500,
                                            height: 1.33,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  Column(
                                    mainAxisSize: MainAxisSize.min,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      SizedBox(
                                        width: 76,
                                        height: 20,
                                        child: Text(
                                          'Vedi tutto',
                                          style: TextStyle(
                                            color: const Color(0xFFF59E0B),
                                            fontSize: 14,
                                            fontFamily: 'Syne',
                                            fontWeight: FontWeight.w700,
                                            height: 1.43,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              width: 390,
                              height: 336,
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(),
                              child: Stack(
                                children: [
                                  Positioned(
                                    left: 24,
                                    top: -0.34,
                                    child: Container(
                                      width: 366,
                                      clipBehavior: Clip.antiAlias,
                                      decoration: BoxDecoration(),
                                      child: Row(
                                        mainAxisSize: MainAxisSize.min,
                                        mainAxisAlignment:
                                            MainAxisAlignment.start,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        spacing: 17,
                                        children: [
                                          Container(
                                            width: 236,
                                            height: 320,
                                            decoration: ShapeDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    "https://placehold.co/236x320"),
                                                fit: BoxFit.cover,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 2,
                                                  color: const Color(
                                                      0xFFF59E0B) /* Orange */,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(32),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            width: 236,
                                            height: 320,
                                            decoration: ShapeDecoration(
                                              image: DecorationImage(
                                                image: NetworkImage(
                                                    "https://placehold.co/236x320"),
                                                fit: BoxFit.cover,
                                              ),
                                              shape: RoundedRectangleBorder(
                                                side: BorderSide(
                                                  width: 2,
                                                  color: const Color(
                                                      0xFFF59E0B) /* Orange */,
                                                ),
                                                borderRadius:
                                                    BorderRadius.circular(32),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
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
        ),
      ],
    );
  }
}
