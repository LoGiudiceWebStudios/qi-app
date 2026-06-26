import 'dart:io';
import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../data/models/product.dart';
import '../../data/services/api_service.dart';
import '../widgets/custom_top_bar.dart';

class Model3DPage extends StatefulWidget {
  final Product product;

  const Model3DPage({super.key, required this.product});

  @override
  State<Model3DPage> createState() => _Model3DPageState();
}

class _Model3DPageState extends State<Model3DPage> {

  @override
  void initState() {
    super.initState();
    // Tenta di avviare immediatamente la fotocamera AR all'apertura
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _tryAutoLaunchAR();
    });
  }

  Future<void> _tryAutoLaunchAR() async {
    final modelUrl = widget.product.model3dUrl != null && widget.product.model3dUrl!.isNotEmpty
        ? Uri.encodeFull('${ApiService.serverUrl}${widget.product.model3dUrl}')
        : '';
    final iosModelUrl = widget.product.model3dIosUrl != null && widget.product.model3dIosUrl!.isNotEmpty
        ? Uri.encodeFull('${ApiService.serverUrl}${widget.product.model3dIosUrl}')
        : '';

    try {
      if (Platform.isAndroid && modelUrl.isNotEmpty) {
        // Su Android uso l'intent ufficiale di SceneViewer per forzare l'AR immediato senza browser
        final intentUrl = 'intent://arvr.google.com/scene-viewer/1.0?file=$modelUrl&mode=ar_only#Intent;scheme=https;package=com.google.ar.core;action=android.intent.action.VIEW;end;';
        await launchUrl(Uri.parse(intentUrl), mode: LaunchMode.externalApplication);
      }
      // NOTA: Su iOS abbiamo rimosso il lancio forzato URL per evitare l'apertura di Safari/Chrome vuoto.
      // Apple, per sicurezza, vieta a WebAR di lanciare la fotocamera senza l'interazione umana, 
      // quindi l'utente dovrà cliccare il tastino del cubetto a schermo nell'app, il che è istantaneo e bellissimo.
    } catch (e) {
      debugPrint('Impossibile forzare AR nativo: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Il file .glb per Android e il render 3D di base
    final modelUrl = widget.product.model3dUrl != null && widget.product.model3dUrl!.isNotEmpty
        ? Uri.encodeFull('${ApiService.serverUrl}${widget.product.model3dUrl}')
        : '';
        
    // Il file .usdz specifico per AR su iOS
    final iosModelUrl = widget.product.model3dIosUrl != null && widget.product.model3dIosUrl!.isNotEmpty
        ? Uri.encodeFull('${ApiService.serverUrl}${widget.product.model3dIosUrl}')
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFA),
      body: Column(
        children: [
          CustomTopBar(
            title: widget.product.name.toUpperCase(),
            backgroundColor: const Color(0xFF008F30),
            leading: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white, size: 24),
              onPressed: () => Navigator.of(context).pop(),
            ),
            showStar: false,
            titleStyle: const TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontFamily: 'Open Sauce',
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                modelUrl.isNotEmpty
                    ? ModelViewer(
                        backgroundColor: const Color(0xFFFAFBFA),
                        src: modelUrl,
                        iosSrc: iosModelUrl.isNotEmpty ? iosModelUrl : null,
                        alt: "Modello 3D di ${widget.product.name}",
                        ar: true, // Riattiviamo la Realtà Aumentata per usare la fotocamera
                        arModes: const ['quick-look', 'scene-viewer', 'webxr'],
                        arScale: ArScale.auto,
                        arPlacement: ArPlacement.floor,
                        autoRotate: true,
                        cameraControls: true,
                        disableZoom: false,
                        cameraOrbit: "auto auto auto", // Zoom base corretto automatico
                      )
                    : const Center(
                        child: Text(
                          'Modello 3D non disponibile per questo prodotto.',
                          style: TextStyle(
                            fontFamily: 'Open Sauce',
                            fontSize: 16,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                
                // Aiuto testuale per gli utenti iOS
                if (Platform.isIOS && iosModelUrl.isNotEmpty)
                  Positioned(
                    bottom: 30,
                    left: 20,
                    right: 80, // lascia un margine a destra per far cliccare il cubetto AR
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.75),
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4)),
                        ],
                      ),
                      child: const Text(
                        "Tocca l'icona del cubo qui a destra per posizionare il panino sul tuo tavolo! 👉",
                        style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600, fontFamily: 'Open Sauce'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
