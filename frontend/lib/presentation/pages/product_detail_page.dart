import 'dart:io' show Platform;
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'package:quick_look/quick_look.dart';
import 'package:dio/dio.dart';
import '../../data/models/product.dart';
import '../../data/services/api_service.dart';
import '../widgets/custom_top_bar.dart';
import 'model_3d_page.dart';

class ProductDetailPage extends StatelessWidget {
  final Product product;

  const ProductDetailPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFA),
      body: Column(
        children: [
          CustomTopBar(
            title: product.name.toUpperCase(),
            backgroundColor: const Color(0xFF008F30),
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 24,
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            showStar: false,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              fontFamily: 'Open Sauce',
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Immagine centrale 300x300
                  if (product.imageUrl.isNotEmpty)
                    Image.network(
                      '${ApiService.serverUrl}${product.imageUrl}',
                      height: 300,
                      width: 300,
                      fit: BoxFit.contain,
                      errorBuilder:
                          (context, error, stackTrace) => const Icon(
                            Icons.fastfood,
                            size: 150,
                            color: Colors.grey,
                          ),
                    )
                  else
                    const Icon(Icons.fastfood, size: 150, color: Colors.grey),

                  const SizedBox(height: 32),

                  // Titolo del prodotto
                  Text(
                    product.name,
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w800,
                      fontFamily: 'Open Sauce',
                      color: Color(0xFF1E293B),
                    ),
                    textAlign: TextAlign.center,
                  ),

                  const SizedBox(height: 24),

                  // Pulsante unificato per aprire direttamente la Realtà Aumentata (sia Android che iOS)
                  if ((Platform.isIOS &&
                          product.model3dIosUrl != null &&
                          product.model3dIosUrl!.isNotEmpty) ||
                      (Platform.isAndroid &&
                          product.model3dUrl != null &&
                          product.model3dUrl!.isNotEmpty))
                    InkWell(
                      onTap: () async {
                        if (Platform.isIOS) {
                          // Su iOS usiamo il sistema nativo QuickLook:
                          // Scarichiamo il file .usdz in locale e poi lo apriamo
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Row(
                                children: [
                                  SizedBox(
                                    width: 24,
                                    height: 24,
                                    child: CircularProgressIndicator(
                                      color: Color(0xFFE9B416),
                                      strokeWidth: 2.5,
                                    ),
                                  ),
                                  SizedBox(width: 16),
                                  Expanded(
                                    child: Text(
                                      'Caricamento Modello 3D...\nAttendere prego.',
                                      style: TextStyle(
                                        color: Color(0xFFE9B416),
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Open Sauce',
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              duration: Duration(seconds: 15),
                              backgroundColor: Colors.black87,
                            ),
                          );

                          try {
                            final arUrl = Uri.encodeFull(
                              '${ApiService.serverUrl}${product.model3dIosUrl}',
                            );
                            final tempDir = await getTemporaryDirectory();
                            // Creiamo un file temporaneo con estensione obblicatoria .usdz per il sistema iOS
                            final filePath =
                                '${tempDir.path}/${product.id}_model.usdz';

                            await Dio().download(arUrl, filePath);

                            // Apre nativamente iOS AR Quick Look PRIMA di nascondere il popup
                            await QuickLook.openURL(filePath);

                            if (context.mounted) {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            }
                          } catch (e) {
                            debugPrint('Errore download o avvio AR iOS: $e');
                            if (context.mounted) {
                              ScaffoldMessenger.of(context).hideCurrentSnackBar();
                            }
                          }
                        } else {
                          // Su Android va dritto all'intent SceneViewer in AR_only
                          final modelUrl = Uri.encodeFull(
                            '${ApiService.serverUrl}${product.model3dUrl}',
                          );
                          final arUrl = Uri.parse(
                            'https://arvr.google.com/scene-viewer/1.0?file=$modelUrl&mode=ar_only',
                          );
                          if (await canLaunchUrl(arUrl)) {
                            await launchUrl(
                              arUrl,
                              mode: LaunchMode.externalApplication,
                            );
                          }
                        }
                      },
                      borderRadius: BorderRadius.circular(50),
                      child: Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(vertical: 18),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(50),
                          border: Border.all(
                            color: const Color(0xFFF3F4F6),
                            width: 1.0,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 2,
                              spreadRadius: 0,
                              offset: const Offset(0, 0),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: const [
                            Icon(
                              Icons.view_in_ar,
                              color: Color(0xFFE9B416),
                              size: 24,
                            ),
                            SizedBox(width: 12),
                            Text(
                              'Vedi nel tuo tavolo',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w700,
                                fontFamily: 'Open Sauce',
                                color: Color(0xFFE9B416),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                  const SizedBox(height: 36),

                  // Sezione Descrizione lunga
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'Descrizione',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        fontFamily: 'Open Sauce',
                        color: Color(0xFF1E293B),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      product.description.isNotEmpty
                          ? product.description
                          : 'Nessuna descrizione disponibile per questo prodotto.',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w500,
                        fontFamily: 'Open Sauce',
                        color: Color(0xFF64748B),
                        height: 1.5,
                      ),
                    ),
                  ),

                  const SizedBox(height: 36),

                  // Sezione Prezzo qui in basso
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Row(
                      children: [
                        const Text(
                          'Prezzo: ',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            fontFamily: 'Open Sauce',
                            color: Color(0xFF1E293B),
                          ),
                        ),
                        Text(
                          '€${product.price.toStringAsFixed(2)}',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            fontFamily: 'Open Sauce',
                            color: Color(0xFFE9B416),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
