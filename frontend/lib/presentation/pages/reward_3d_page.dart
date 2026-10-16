import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../../data/services/api_service.dart';
import '../widgets/custom_top_bar.dart';

class Reward3DPage extends StatefulWidget {
  const Reward3DPage({
    super.key,
    required this.title,
    required this.model3dUrl,
  });

  final String title;
  final String model3dUrl;

  @override
  State<Reward3DPage> createState() => _Reward3DPageState();
}

class _Reward3DPageState extends State<Reward3DPage> {
  bool _isLoading = true;
  bool _hasError = false;

  String _absoluteModelUrl(String path) {
    final normalizedPath = path.startsWith('/') ? path : '/$path';
    return Uri.encodeFull('${ApiService.serverUrl}$normalizedPath');
  }

  @override
  Widget build(BuildContext context) {
    final modelUrl = _absoluteModelUrl(widget.model3dUrl);

    return Scaffold(
      backgroundColor: const Color(0xFFFAFBFA),
      body: Column(
        children: [
          CustomTopBar(
            title: widget.title.toUpperCase(),
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
              fontSize: 20,
              fontWeight: FontWeight.w800,
              fontFamily: 'Open Sauce',
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                ModelViewer(
                  backgroundColor: const Color(0xFFFAFBFA),
                  src: modelUrl,
                  alt: 'Modello 3D di ${widget.title}',
                  ar: false,
                  autoRotate: true,
                  cameraControls: true,
                  disableZoom: false,
                  cameraOrbit: 'auto auto auto',
                  javascriptChannels: {
                    JavascriptChannel(
                      'RewardModelStatus',
                      onMessageReceived: (message) {
                        if (!mounted) return;
                        setState(() {
                          _isLoading = false;
                          _hasError = message.message == 'error';
                        });
                      },
                    ),
                  },
                  relatedJs: '''
                    const rewardViewer = document.querySelector('model-viewer');
                    rewardViewer.addEventListener('load', () => RewardModelStatus.postMessage('loaded'));
                    rewardViewer.addEventListener('error', () => RewardModelStatus.postMessage('error'));
                    if (rewardViewer.loaded) RewardModelStatus.postMessage('loaded');
                  ''',
                ),
                if (_isLoading)
                  const Center(
                    child: CircularProgressIndicator(color: Color(0xFFE9B416)),
                  ),
                if (_hasError)
                  const Center(
                    child: Icon(
                      Icons.error_outline,
                      size: 40,
                      color: Colors.redAccent,
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
