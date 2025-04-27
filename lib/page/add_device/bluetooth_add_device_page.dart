import 'dart:async';
import 'package:astraval_smart/service/bluetooth_add_device_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:astraval_smart/main.dart';

class BluetoothAddDevicePage extends StatefulWidget {
  const BluetoothAddDevicePage({super.key});

  @override
  State<BluetoothAddDevicePage> createState() => _BluetoothAddDevicePageState();
}

class _BluetoothAddDevicePageState extends State<BluetoothAddDevicePage> {
  final BluetoothAddDeviceService _service = BluetoothAddDeviceService();
  List<BluetoothDevice> devices = [];
  bool isScanning = false;
  int scanTime = 13;
  bool? connectionResult;

  @override
  void initState() {
    super.initState();
    _startDeviceScan();
  }

  void _startDeviceScan() async {
    setState(() {
      devices.clear();
      isScanning = true;
      scanTime = 13;
    });

    Timer.periodic(const Duration(seconds: 1), (timer) {
      if (scanTime > 0) {
        setState(() => scanTime--);
      } else {
        timer.cancel();
      }
    });

    final scannedDevices = await _service.scanForDevices();
    setState(() {
      devices = scannedDevices;
      isScanning = false;
    });
  }

  void _showConnectionDialog(BluetoothDevice device) {
    final globalContext = navigatorKey.currentContext;
    if (globalContext == null || !globalContext.mounted) return;

    showDialog(
      context: globalContext,
      builder: (dialogContext) => AlertDialog(
        title: Text(
            connectionResult! ? 'Connection Successful' : 'Connection Failed'),
        content: Text(connectionResult!
            ? 'Connected to ${device.name}'
            : 'Failed to connect to ${device.name}'),
        actions: [
          TextButton(
            onPressed: () {
              if (dialogContext.mounted) {
                Navigator.of(dialogContext).pop();
              }
              if (globalContext.mounted) {
                Navigator.of(globalContext).pushNamedAndRemoveUntil(
                  '/home',
                  (route) => false,
                );
              }
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showWifiDialog(BluetoothDevice device) {
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) {
          TextEditingController ssidController = TextEditingController();
          TextEditingController passwordController = TextEditingController();
          String? ssidError;
          String? passwordError;

          return AlertDialog(
            title: const Text('Enter Wi-Fi Credentials'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: ssidController,
                  decoration: InputDecoration(
                    labelText: 'SSID',
                    errorText: ssidError,
                  ),
                ),
                TextField(
                  controller: passwordController,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    errorText: passwordError,
                  ),
                  obscureText: true,
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(dialogContext).pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () async {
                  String ssid = ssidController.text.trim();
                  String password = passwordController.text.trim();

                  setState(() {
                    ssidError = ssid.isEmpty ? 'SSID cannot be empty' : null;
                    passwordError =
                        password.isEmpty ? 'Password cannot be empty' : null;
                  });

                  if (ssid.isNotEmpty && password.isNotEmpty) {
                    Navigator.of(dialogContext).pop();
                    connectionResult =
                        await _service.connectToDevice(device, ssid, password);
                    if (mounted) {
                      _showConnectionDialog(device);
                    }
                  }
                },
                child: const Text('Connect'),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildDeviceCard(BluetoothDevice device) {
    return Card(
      elevation: 4.0,
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
      child: ListTile(
        leading: const Icon(Icons.bluetooth),
        title: Text(
          device.name ?? 'Unknown Device',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        onTap: () => _showWifiDialog(device),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Add Bluetooth Device')),
      body: isScanning
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(),
                  const SizedBox(height: 10),
                  Text('Scanning... $scanTime s'),
                ],
              ),
            )
          : ListView.builder(
              itemCount: devices.length,
              itemBuilder: (context, index) => _buildDeviceCard(devices[index]),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _startDeviceScan,
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
