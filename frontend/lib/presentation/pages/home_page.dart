import 'package:flutter/material.dart';
// Usiamo l'import relativo o il nome del pacchetto (se hai lasciato "name: frontend" nel pubspec)
import '../../data/services/api_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ApiService _apiService = ApiService();
  String _serverMessage = 'Premi il bottone per testare il server locale';
  bool _isLoading = false;

  void _testConnection() async {
    setState(() => _isLoading = true);

    final result = await _apiService.pingBackend();

    setState(() {
      _serverMessage = result;
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QI App Dashboard'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.settings_input_antenna,
                  size: 80, color: Colors.blueAccent),
              const SizedBox(height: 24),
              Text(
                _serverMessage,
                textAlign: TextAlign.center,
                style:
                    const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 32),
              ElevatedButton.icon(
                onPressed: _isLoading ? null : _testConnection,
                icon: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Icon(Icons.bolt),
                label: const Text('Ping Backend Go'),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
