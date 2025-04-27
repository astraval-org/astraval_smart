import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

class BluetoothAddDeviceRepo {
  final DatabaseReference _usersRef = FirebaseDatabase.instance.ref('users');
  final DatabaseReference _devicesRef = FirebaseDatabase.instance.ref('devices');

  Future<void> addDevice(BluetoothDevice device, String deviceId) async {
    try {
      // Normalize deviceId
      deviceId = deviceId.split(':').last;

      // Check if device already exists
      final deviceSnapshot = await _devicesRef.child(deviceId).get();
      if (deviceSnapshot.exists) {
        print('Device $deviceId already exists');
        return;
      }

      // Add device to devices database
      await _devicesRef.child(deviceId).set({
        'com': false,
        'name': device.name ?? 'Unknown Device',
        'status': false,
        'type': 'light',
      });

      // Add device to user's device list
      final userId = FirebaseAuth.instance.currentUser!.uid;
      final userDeviceRef = _usersRef.child(userId).child('deviceDetails');
      final userSnapshot = await userDeviceRef.get();

      if (userSnapshot.exists && userSnapshot.value is Map) {
        final deviceDetails = Map<String, dynamic>.from(userSnapshot.value as Map);
        final nextIndex = deviceDetails.keys
                .map((key) => int.tryParse(key.replaceAll('d', '')) ?? 0)
                .fold(0, (a, b) => a > b ? a : b) + 1;
        await userDeviceRef.update({'d$nextIndex': deviceId});
      } else {
        await userDeviceRef.set({'d1': deviceId});
      }

      print('Device $deviceId added successfully');
    } catch (e) {
      print('Error adding device: $e');
      rethrow;
    }
  }
}