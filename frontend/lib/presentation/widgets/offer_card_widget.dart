import 'package:flutter/material.dart';

import '../../data/models/offer_model.dart';

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

    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.10),
            blurRadius: 26,
            offset: const Offset(0, 10),
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          ClipPath(
            clipper: SawToothClipper(),
            child: Container(
              height: 148,
              decoration: const BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
              ),
              child: Image.network(
                offer.imageUrl,
                fit: BoxFit.cover,
                errorBuilder:
                    (context, error, stackTrace) => Container(
                      color: Colors.grey[300],
                      alignment: Alignment.center,
                      child: const Icon(
                        Icons.image_not_supported,
                        color: Colors.grey,
                      ),
                    ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  style: const TextStyle(
                    fontFamily: 'Open Sauce',
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
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
                    fontSize: 14,
                    color: Color(0xFF4B5563),
                  ),
                ),
                if (termsText.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: onTermsTap,
                    child: Text(
                      termsText,
                      style: const TextStyle(
                        fontFamily: 'Open Sauce',
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFFD97706),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
          Divider(height: 1, thickness: 1, color: Colors.grey.withOpacity(0.1)),
          InkWell(
            onTap: onGetCodeTap,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(20.0),
            ),
            child: const Padding(
              padding: EdgeInsets.symmetric(vertical: 14.0),
              child: Center(
                child: Text(
                  'Get Code',
                  style: TextStyle(
                    fontFamily: 'Open Sauce',
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1F2937),
                  ),
                ),
              ),
            ),
          ),
        ],
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

class SawToothClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    final path = Path();
    path.lineTo(0, size.height);

    const double toothWidth = 10.0;
    final int numTeeth = (size.width / toothWidth).ceil();

    for (int i = 0; i < numTeeth; i++) {
      double x = (i * toothWidth) + (toothWidth / 2);
      double y = size.height - 6.0;
      path.lineTo(x, y);

      x = (i + 1) * toothWidth;
      y = size.height;
      path.lineTo(x, y);
    }

    path.lineTo(size.width, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(covariant CustomClipper<Path> oldClipper) => false;
}
