import 'package:flutter/material.dart';

import '../../data/models/event_model.dart';

class EventCardWidget extends StatelessWidget {
  final Event event;
  final VoidCallback onTap;

  const EventCardWidget({super.key, required this.event, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final imageUrl = event.immagineUrl ?? '';

    return Container(
      margin: const EdgeInsets.only(bottom: 24.0),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 0,
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(24.0),
              ),
              child:
                  imageUrl.isEmpty
                      ? _buildPlaceholder()
                      : imageUrl.startsWith('assets/')
                      ? Image.asset(
                        imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => _buildPlaceholder(),
                      )
                      : Image.network(
                        imageUrl,
                        height: 200,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder:
                            (context, error, stackTrace) => _buildPlaceholder(),
                      ),
            ),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.titolo,
                    style: const TextStyle(
                      fontFamily: 'Open Sauce',
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1F2937),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    event.descrizione,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Open Sauce',
                      fontSize: 14,
                      color: Color(0xFF4B5563),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${_formatDate(event.dataEvento)} · ${event.oraEvento}'
                    '${event.luogo != null && event.luogo!.isNotEmpty ? ' · ${event.luogo}' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Open Sauce',
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime value) {
    const months = [
      'gen',
      'feb',
      'mar',
      'apr',
      'mag',
      'giu',
      'lug',
      'ago',
      'set',
      'ott',
      'nov',
      'dic',
    ];
    final month = months[value.month - 1];
    return '${value.day.toString().padLeft(2, '0')} $month ${value.year}';
  }

  Widget _buildPlaceholder() {
    return Container(
      height: 200,
      color: Colors.grey[300],
      alignment: Alignment.center,
      child: const Icon(
        Icons.image_not_supported,
        color: Colors.grey,
        size: 40,
      ),
    );
  }
}
