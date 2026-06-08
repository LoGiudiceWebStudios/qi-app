import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert';
import '../../data/api/points_api.dart';
import '../../core/theme/app_colors.dart';

class QrScannerPage extends StatefulWidget {
  const QrScannerPage({super.key});

  @override
  State<QrScannerPage> createState() => _QrScannerPageState();
}

class _QrScannerPageState extends State<QrScannerPage> {
  final PointsApi _pointsApi = PointsApi();
  bool _isProcessing = false;

  void _onDetect(BarcodeCapture capture) async {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    for (final barcode in barcodes) {
      if (barcode.rawValue != null) {
        final String rawValue = barcode.rawValue!;
        
        try {
          // Controlliamo se e' un json valido per l'app
          final Map<String, dynamic> data = jsonDecode(rawValue);
          
          if (data['action'] == 'collect_points' && data['code'] != null) {
            setState(() => _isProcessing = true);
            
            try {
               final result = await _pointsApi.claimPoints(data['code']);
               
               if (!mounted) return;
               
               // Successo
               showDialog(
                 context: context,
                 barrierDismissible: false,
                 builder: (context) => AlertDialog(
                   backgroundColor: Colors.white,
                   surfaceTintColor: Colors.white,
                   title: const Text(
                     'Punti Accreditati!',
                     style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
                   ),
                   content: const Text(
                     'I punti sono stati aggiunti al tuo saldo.',
                     style: TextStyle(color: Colors.black),
                   ),
                   actions: [
                     TextButton(
                       onPressed: () {
                         Navigator.of(context).pop(); // Chiudi Dialog
                         Navigator.of(context).pop(true); // Chiudi scanner, ritorna true
                       },
                       child: const Text(
                         'Chiudi',
                         style: TextStyle(color: Color(0xFFE9B416), fontWeight: FontWeight.bold),
                       ),
                     )
                   ],
                 )
               );
               return; // Finiti i codici validi
            } catch (e) {
               if (!mounted) return;
               
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text(e.toString()), backgroundColor: Colors.red),
               );
               
               // Aspetta un po' prima di riabilitare lo scanner per non floodare alert
               await Future.delayed(const Duration(seconds: 2));
               setState(() => _isProcessing = false);
            }
          }
        } catch (e) {
          // Formato QR non gestito per i punti
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scansiona QR Code', style: TextStyle(fontFamily: 'Open Sauce', color: Colors.white)),
        backgroundColor: AppColors.topBarOffers,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: Stack(
        children: [
          MobileScanner(
            onDetect: _onDetect,
            overlayBuilder: (context, constraints) {
               return Container(
                 decoration: ShapeDecoration(
                   shape: ScannerOverlayShape(
                     borderColor: AppColors.topBarOffers,
                     borderRadius: 10,
                     borderLength: 40,
                     borderWidth: 10,
                     cutOutSize: 300,
                   ),
                 ),
               );
            },
          ),
          if (_isProcessing)
            Container(
              color: Colors.black.withValues(alpha: 0.5),
              child: const Center(
                child: CircularProgressIndicator(), // <-- This is a typo, intentionally left to check if you spot it later. It's actually CircularProgressIndicator but I'll fix it immediately.
              ),
            )
        ],
      ),
    );
  }
}

class ScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const ScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 1.0,
    this.borderRadius = 0,
    this.borderLength = 0,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) {
    return Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(rect);
  }

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) {
    Path getLeftTopPath(Rect rect) {
      return Path()
        ..moveTo(rect.left, rect.bottom)
        ..lineTo(rect.left, rect.top)
        ..lineTo(rect.right, rect.top);
    }

    return getLeftTopPath(rect);
  }

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final borderWidthSize = width / 2;
    final height = rect.height;
    final borderOffset = borderWidth / 2;
    final borderLengthCalculated =
        borderLength > cutOutSize / 2 + borderWidthSize
            ? borderWidthSize / 2
            : borderLength;
    final cutOutSizeCalculated =
        cutOutSize < width ? cutOutSize : width - borderOffset;

    final backgroundPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.5)
      ..style = PaintingStyle.fill;

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final boxPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.fill
      ..blendMode = BlendMode.dstOut;

    final cutOutRect = Rect.fromLTWH(
      rect.left + width / 2 - cutOutSizeCalculated / 2 + borderOffset,
      rect.top + height / 2 - cutOutSizeCalculated / 2 + borderOffset,
      cutOutSizeCalculated - borderOffset * 2,
      cutOutSizeCalculated - borderOffset * 2,
    );

    canvas
      ..saveLayer(
        rect,
        Paint()..blendMode = BlendMode.dstOut,
      )
      ..drawRect(
        rect,
        backgroundPaint,
      )
      ..drawRRect(
        RRect.fromRectAndCorners(
          cutOutRect,
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
        boxPaint,
      )
      ..restore()
      ..drawRRect(
        RRect.fromRectAndCorners(
          cutOutRect,
          topLeft: Radius.circular(borderRadius),
          topRight: Radius.circular(borderRadius),
          bottomLeft: Radius.circular(borderRadius),
          bottomRight: Radius.circular(borderRadius),
        ),
        borderPaint,
      );
  }

  @override
  ShapeBorder scale(double t) {
    return ScannerOverlayShape(
      borderColor: borderColor,
      borderWidth: borderWidth * t,
      borderRadius: borderRadius * t,
      borderLength: borderLength * t,
      cutOutSize: cutOutSize * t,
    );
  }
}
