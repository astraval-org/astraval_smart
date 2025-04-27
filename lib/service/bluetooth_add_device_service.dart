import 'dart:async';
import 'dart:convert';
import 'package:astraval_smart/repo/bluetooth_add_device_repo.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:geolocator/geolocator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:astraval_smart/service/user_service.dart';
import 'dart:typed_data';

class BluetoothAddDeviceService {
  final BluetoothAddDeviceRepo _repo = BluetoothAddDeviceRepo();
  final UserService _userService = UserService();
  final FlutterBluetoothSerial _bluetooth = FlutterBluetoothSerial.instance;

  Future<List<BluetoothDevice>> scanForDevices() async {
    await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.location,
    ].request();

    await _ensureBluetoothEnabled();
    await _ensureLocationEnabled();
    return _startBluetoothScan();
  }

  Future<void> _ensureBluetoothEnabled() async {
    bool isEnabled = await _bluetooth.isEnabled ?? false;
    while (!isEnabled) {
      bool? enableResult = await _bluetooth.requestEnable();
      if (enableResult == true) {
        isEnabled = true;
      }
    }
  }

  Future<void> _ensureLocationEnabled() async {
    bool isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    while (!isLocationEnabled) {
      await Geolocator.requestPermission();
      isLocationEnabled = await Geolocator.isLocationServiceEnabled();
    }
  }

  Future<List<BluetoothDevice>> _startBluetoothScan() async {
    List<BluetoothDevice> devices = [];
    try {
      final stream = _bluetooth.startDiscovery();
      await for (BluetoothDiscoveryResult result in stream) {
        final device = result.device;
        if (!devices.any((d) => d.address == device.address) &&
            device.name != null &&
            device.name!.startsWith('IET')) {
          devices.add(device);
        }
      }
    } catch (e) {
      print('Error while scanning: $e');
    }
    return devices;
  }

  Future<bool> connectToDevice(BluetoothDevice device, String ssid, String password) async {
    try {
      final connection = await BluetoothConnection.toAddress(device.address);
      final credentials = '$ssid,$password';
      String deviceId = '';

      connection.output.add(utf8.encode('$credentials\n'));
      await connection.output.allSent;

      StringBuffer responseBuffer = StringBuffer();
      await for (Uint8List data in connection.input!) {
        responseBuffer.write(utf8.decode(data));
        if (responseBuffer.toString().contains('\n')) {
          deviceId = responseBuffer.toString().trim();
          connection.output.add(utf8.encode('END'));
          break;
        }
      }

      connection.close();

      // Normalize deviceId
      final normalizedDeviceId = deviceId.split(':').last;

      // Check if device is already associated with the user
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userData = await _userService.getUserData(userId);
      final userDevices = userData?.devices.keys.toList() ?? [];

      if (!userDevices.contains(normalizedDeviceId)) {
        await _repo.addDevice(device, deviceId);
      } else {
        print('Device $normalizedDeviceId already exists for user $userId');
      }

      return true;
    } catch (e) {
      print('Error connecting to device: $e');
      return false;
    }
  }
}