import 'package:flutter/material.dart';

import '../../data/models/event_model.dart';
import '../../data/services/api_service.dart';

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
        borderRadius: BorderRadius.circular(32.0), // Bordi più arrotondati
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(32.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(12.0), // Lo spazio bianco attorno all'immagine
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24.0), // L'immagine adesso ha tutti e 4 i bordi arrotondati all'interno
                child:
                    imageUrl.isEmpty
                        ? _buildPlaceholder()
                        : imageUrl.startsWith('assets/')
                        ? Image.asset(
                            imageUrl,
                            height: 380, // Molto più alta per rispettare la proporzione rettangolare della foto
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => _buildPlaceholder(),
                          )
                        : Image.network(
                            imageUrl.startsWith('http')
                                ? imageUrl
                                : "${ApiService.serverUrl}${imageUrl.startsWith('/') ? '' : '/'}${imageUrl.replaceAll('\\', '/')}",
                            height: 380,
                            width: double.infinity,
                            fit: BoxFit.cover,
                            errorBuilder:
                                (context, error, stackTrace) => _buildPlaceholder(),
                          ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 4.0, 24.0, 26.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.titolo,
                    style: const TextStyle(
                      fontFamily: 'Open Sauce',
                      fontSize: 26, // Più grande come da foto
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
                      fontSize: 16,
                      height: 1.4,
                      color: Color(0xFF374151),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Lasciamo i metadati dell'evento (Data, Ora, Luogo) ma stilizzati bene
                  Text(
                    '${_formatDate(event.dataEvento)} · ${event.oraEvento}'
                    '${event.luogo != null && event.luogo!.isNotEmpty ? ' · ${event.luogo}' : ''}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: 'Open Sauce',
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFFA000), // Giallo/arancio per farsi notare
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
      height: 380,
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
