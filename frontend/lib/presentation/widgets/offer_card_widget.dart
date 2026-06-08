import 'package:flutter/material.dart';
import '../../data/models/offer_model.dart';
import '../../data/services/api_service.dart';

class OfferCardWidget extends StatelessWidget {
  final OfferModel offer;
  final VoidCallback onGetCodeTap;
  final VoidCallback onTermsTap;

  const OfferCardWidget({
    super.key,
    required this.offer,
    required this.onGetCodeTap,
    required this.onTermsTap,
  });

  @override
  Widget build(BuildContext context) {
    final termsText = offer.termsText?.trim() ?? '';
    const double cutoutY = 175.0; // Altezza esatta a cui creare i semicerchi

    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipPath(
        clipper: TicketClipper(cutoutY: cutoutY),
        child: Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Immagine con zig zag a denti quadrati al fondo
              SizedBox(
                height: cutoutY,
                child: Stack(
                  children: [
                    Positioned.fill(
                      child: Image.network(
                        offer.imageUrl.startsWith('http')
                            ? offer.imageUrl
                            : "${ApiService.serverUrl}${offer.imageUrl.startsWith('/') ? '' : '/'}${offer.imageUrl.replaceAll('\\', '/')}",
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) => Container(
                          color: Colors.grey[300],
                          alignment: Alignment.center,
                          child: const Icon(Icons.image_not_supported, color: Colors.grey),
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      height: 5, // Abbassato da 12 a 5
                      child: ClipPath(
                        clipper: SquareTeethClipper(toothWidth: 10.0),
                        child: Container(color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              // Parte Testuale
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20.0, 16.0, 20.0, 16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween, // Distribuisce spazi separando le righe
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            offer.title,
                            style: const TextStyle(
                              fontFamily: 'Open Sauce',
                              fontSize: 22,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF1F2937),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            offer.description,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Open Sauce',
                              fontSize: 16,
                              color: Color(0xFF374151),
                            ),
                          ),
                        ],
                      ),
                      if (termsText.isNotEmpty)
                        GestureDetector(
                          onTap: onTermsTap,
                          child: Text(
                            termsText.startsWith('*') ? termsText : '*$termsText',
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontFamily: 'Open Sauce',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFFE9B416),
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              const Divider(height: 1, thickness: 1, color: Color(0xFFE5E7EB)),
              InkWell(
                onTap: onGetCodeTap,
                child: SizedBox(
                  height: 56,
                  child: Center(
                    child: const Text(
                      'Get Code',
                      style: TextStyle(
                        fontFamily: 'Open Sauce',
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF1F2937),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class TicketOfferCard extends OfferCardWidget {
  const TicketOfferCard({
    super.key,
    required super.offer,
    required VoidCallback onTapAction,
    VoidCallback? onTapTerms,
  }) : super(onGetCodeTap: onTapAction, onTermsTap: onTapTerms ?? _noop);

  static void _noop() {}
}

class TicketClipper extends CustomClipper<Path> {
  final double cutoutY;
  final double cutoutRadius;
  final double cornerRadius;

  TicketClipper({
    required this.cutoutY,
    this.cutoutRadius = 18.0,
    this.cornerRadius = 24.0,
  });

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, cornerRadius);
    path.quadraticBezierTo(0, 0, cornerRadius, 0);
    path.lineTo(size.width - cornerRadius, 0);
    path.quadraticBezierTo(size.width, 0, size.width, cornerRadius);
    
    // Semicerchio destro
    path.lineTo(size.width, cutoutY - cutoutRadius);
    path.arcToPoint(
      Offset(size.width, cutoutY + cutoutRadius),
      radius: Radius.circular(cutoutRadius),
      clockwise: false,
    );
    
    path.lineTo(size.width, size.height - cornerRadius);
    path.quadraticBezierTo(size.width, size.height, size.width - cornerRadius, size.height);
    
    path.lineTo(cornerRadius, size.height);
    path.quadraticBezierTo(0, size.height, 0, size.height - cornerRadius);
    
    // Semicerchio sinistro
    path.lineTo(0, cutoutY + cutoutRadius);
    path.arcToPoint(
      Offset(0, cutoutY - cutoutRadius),
      radius: Radius.circular(cutoutRadius),
      clockwise: false,
    );
    
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => true;
}

class SquareTeethClipper extends CustomClipper<Path> {
  final double toothWidth;

  SquareTeethClipper({this.toothWidth = 14.0});

  @override
  Path getClip(Size size) {
    Path path = Path();
    double h = size.height;
    
    path.moveTo(0, h);
    path.lineTo(0, 0);
    
    int numTeeth = (size.width / (toothWidth * 2)).ceil();
    for (int i = 0; i < numTeeth; i++) {
      double x = i * toothWidth * 2;
      path.lineTo(x + toothWidth, 0);
      path.lineTo(x + toothWidth, h);
      
      if (i < numTeeth - 1) {
        path.lineTo(x + toothWidth * 2, h);
        path.lineTo(x + toothWidth * 2, 0);
      } else {
        path.lineTo(size.width, h);
      }
    }
    path.lineTo(size.width, h);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
