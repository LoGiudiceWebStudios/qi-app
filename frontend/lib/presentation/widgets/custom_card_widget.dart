import 'package:flutter/material.dart';

class CustomCardWidget extends StatelessWidget {
  final Color borderColor;
  final String? imageUrl;

  const CustomCardWidget({
    super.key,
    required this.borderColor,
    this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 236, // Proporzioni card corrette da Figma
      height: 320,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.08), // Sfondo semi-trasparente tipo la grid dell'immagine
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: borderColor,
          width: 2.0,
        ),
      ),
      child: imageUrl != null && imageUrl!.isNotEmpty
          ? ClipRRect(
              borderRadius: BorderRadius.circular(22),
              child: Image.network(
                imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => const Center(
                  child: Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            )
          : null, // Rende il placeholder (chequered trasparent look dal container)
    );
  }
}
