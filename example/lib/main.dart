import 'dart:async';

import 'package:chiplet_ring_flutter_plugin/chiplet_ring_flutter_plugin.dart';
import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

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
  final List<Map<String, dynamic>> _scannedDevices = [];

  @override
  void initState() {
    super.initState();
    _requestPermissionsAndInitialize();
    _listenToEvents();
  }

  Future<void> _requestPermissionsAndInitialize() async {
    bool permissionsGranted = await _requestPermissions();
    if (permissionsGranted) {
      await _initializePlugin();
    } else {
      setState(() {
        _status = "Brak wymaganych uprawnień";
      });
    }
  }

  Future<bool> _requestPermissions() async {
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetooth,
      Permission.bluetoothConnect,
      Permission.bluetoothScan,
      Permission.locationWhenInUse, // wymagane dla skanowania BLE
    ].request();

    return statuses.values.every((status) => status.isGranted);
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

      if (event['event'] == 'scan_result') {
        // Dodajemy urządzenie do listy, jeśli jeszcze go tam nie ma
        Map<String, dynamic> device = {
          "name": event['name'] ?? "Nieznane urządzenie",
          "mac": event['mac']
        };

        if (!_scannedDevices.any((d) => d['mac'] == device['mac'])) {
          setState(() {
            _scannedDevices.add(device);
          });
        }
      } else if (event['event'] == 'connected') {
        print('Połączono z urządzeniem');
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _connectToSelectedDevice(String macAddress) async {
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
                onPressed: () {
                  setState(() {
                    _scannedDevices.clear();
                  });
                  _chipletRing.startScan();
                },
                child: const Text("Rozpocznij skanowanie"),
              ),
              const SizedBox(height: 20),
              _scannedDevices.isEmpty
                  ? const Text("Nie znaleziono urządzeń.")
                  : Expanded(
                      child: ListView.builder(
                        itemCount: _scannedDevices.length,
                        itemBuilder: (context, index) {
                          final device = _scannedDevices[index];
                          return ListTile(
                            title:
                                Text(device["name"] ?? "Nieznane urządzenie"),
                            subtitle: Text(device["mac"]),
                            onTap: () =>
                                _connectToSelectedDevice(device["mac"]),
                          );
                        },
                      ),
                    ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _getBatteryLevel,
                child: const Text("Pobierz Poziom Baterii"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
