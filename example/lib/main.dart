import 'dart:async';

import 'package:chiplet_ring_flutter_plugin/chiplet_ring_flutter_plugin.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final ChipletRingFlutterPlugin _chipletRing = ChipletRingFlutterPlugin();
  StreamSubscription<Map<String, dynamic>>? _subscription;
  String _status = "Nie połączono";

  @override
  void initState() {
    super.initState();
    _initializePlugin();
    _listenToEvents();
  }

  Future<void> _initializePlugin() async {
    try {
      await _chipletRing.initialize();
    } catch (e) {
      print('Błąd podczas inicjalizacji SDK: $e');
    }
  }

  void _listenToEvents() {
    _subscription = _chipletRing.eventStream.listen((event) {
      setState(() {
        _status = event.toString();
      });

      // Możesz dodać dodatkową logikę obsługi zdarzeń tutaj
      if (event['event'] == 'connected') {
        // Urządzenie połączone
        print('Urządzenie połączone');
      } else if (event['event'] == 'battery_level') {
        int battery = event['level'];
        // Aktualizuj poziom baterii w interfejsie
        print('Poziom baterii: $battery%');
      }
      // Obsługa innych zdarzeń...
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _connectToRing() async {
    String macAddress = "B2:20:11:00:00:C6"; // Przykładowy MAC
    try {
      await _chipletRing.connectToRing(macAddress);
    } catch (e) {
      print('Błąd podczas łączenia: $e');
    }
  }

  void _getBatteryLevel() async {
    try {
      await _chipletRing.getBatteryLevel();
    } catch (e) {
      print('Błąd podczas pobierania poziomu baterii: $e');
    }
  }

  // Dodaj inne metody wywołujące funkcje pluginu

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text("Chiplet Ring Flutter Plugin")),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Status: $_status',
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _connectToRing,
                child: const Text("Połącz z Ringiem"),
              ),
              ElevatedButton(
                onPressed: _getBatteryLevel,
                child: const Text("Pobierz Poziom Baterii"),
              ),
              // Dodaj inne przyciski
            ],
          ),
        ),
      ),
    );
  }
}
