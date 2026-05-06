import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import '../../data/api/event_api.dart';
import '../../data/models/event_model.dart';
import '../widgets/custom_top_bar.dart';
import '../widgets/event_card_widget.dart';

class EventsPage extends StatefulWidget {
  const EventsPage({super.key});

  @override
  State<EventsPage> createState() => _EventsPageState();
}

class _EventsPageState extends State<EventsPage> {
  late Future<List<Event>> _eventsFuture;

  @override
  void initState() {
    super.initState();
    _eventsFuture = EventApi().fetchEvents();
  }

  void _retryFetch() {
    setState(() {
      _eventsFuture = EventApi().fetchEvents();
    });
  }

  void _showEventDetails(Event event) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.titolo,
                style: const TextStyle(
                  fontFamily: 'Open Sauce',
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                event.descrizione,
                style: const TextStyle(
                  fontFamily: 'Open Sauce',
                  fontSize: 14,
                  height: 1.5,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                '${event.oraEvento}${event.luogo != null && event.luogo!.isNotEmpty ? ' · ${event.luogo}' : ''}',
                style: const TextStyle(
                  fontFamily: 'Open Sauce',
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.topBarMenu,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text('Chiudi'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          const CustomTopBar(
            title: 'EVENTI',
            backgroundColor: AppColors.topBarMenu,
            icon: Icons.calendar_month_outlined,
            showStar: false,
            titleStyle: TextStyle(
              color: Colors.white,
              fontSize: 27,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Event>>(
              future: _eventsFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const _EventsLoadingState();
                }

                if (snapshot.hasError) {
                  return _EventsErrorState(
                    errorMessage: snapshot.error?.toString(),
                    onRetry: _retryFetch,
                  );
                }

                final events = snapshot.data ?? const <Event>[];
                if (events.isEmpty) {
                  return const _EventsEmptyState();
                }

                return ListView.separated(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 130),
                  itemCount: events.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 14),
                  itemBuilder: (context, index) {
                    final event = events[index];
                    return EventCardWidget(
                      event: event,
                      onTap: () => _showEventDetails(event),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _EventsLoadingState extends StatelessWidget {
  const _EventsLoadingState();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _EventsErrorState extends StatelessWidget {
  final String? errorMessage;
  final VoidCallback onRetry;

  const _EventsErrorState({required this.errorMessage, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Impossibile caricare gli eventi:\n$errorMessage',
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(onPressed: onRetry, child: const Text('Riprova')),
          ],
        ),
      ),
    );
  }
}

class _EventsEmptyState extends StatelessWidget {
  const _EventsEmptyState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Text(
          'Nessun evento disponibile',
          style: TextStyle(color: Colors.grey),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
