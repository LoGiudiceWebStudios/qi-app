import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../data/models/product.dart';
import '../../data/services/api_service.dart';
import '../widgets/custom_top_bar.dart';

class Model3DPage extends StatelessWidget {
  final Product product;

  const Model3DPage({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // Il file .glb per Android e il render 3D di base
    final modelUrl = product.model3dUrl != null && product.model3dUrl!.isNotEmpty
        ? Uri.encodeFull('${ApiService.serverUrl}${product.model3dUrl}')
        : '';
        
    // Il file .usdz specifico per AR su iOS
    final iosModelUrl = product.model3dIosUrl != null && product.model3dIosUrl!.isNotEmpty
        ? Uri.encodeFull('${ApiService.serverUrl}${product.model3dIosUrl}')
        : '';

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFA),
      body: Column(
        children: [
          CustomTopBar(
            title: product.name.toUpperCase(),
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
            child: modelUrl.isNotEmpty
                ? ModelViewer(
                    backgroundColor: const Color(0xFFFAFBFA),
                    src: modelUrl,
                    iosSrc: iosModelUrl.isNotEmpty ? iosModelUrl : null,
                    alt: "Modello 3D di ${product.name}",
                    ar: true, // Riattiviamo la Realtà Aumentata per usare la fotocamera
                    autoRotate: true,
                    cameraControls: true,
                    disableZoom: false,
                    cameraOrbit: "0deg 75deg 400%", // Zoom base corretto
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
          ),
        ],
      ),
    );
  }
}
