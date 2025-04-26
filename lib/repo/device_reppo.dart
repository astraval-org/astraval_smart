// ignore_for_file: avoid_print

import 'package:firebase_database/firebase_database.dart';
import '../utils/map_converter.dart';

class DeviceRepo {
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // Fetch device data from Firebase Realtime Database
  Future<Map<String, dynamic>?> fetchDeviceData(String deviceId) async {
    try {
      final dbEvent = await _dbRef.child('devices/$deviceId').once();
      if (dbEvent.snapshot.exists) {
        final data = dbEvent.snapshot.value;
        return convertToMapStringDynamic(data);
      } else {
        print('No data available for device: $deviceId');
        return null;
      }
    } catch (e) {
      print('Error fetching device data: $e');
      return null;
    }
  }

  // Update device state in Firebase Realtime Database
  Future<void> updateDeviceState(String deviceId, bool state) async {
    try {
      await _dbRef.child('devices/$deviceId').update({'state': state});
      print('Device state updated successfully: $deviceId');
    } catch (e) {
      print('Error updating device state: $e');
    }
  }

  // Update node command in Firebase Realtime Database
  Future<void> updateNodeCmd(String deviceId, String nodeId, bool cmd) async {
    try {
      await _dbRef.child('devices/$deviceId/node/$nodeId').update({'cmd': cmd});
      print('Node cmd updated successfully: $deviceId/$nodeId');
    } catch (e) {
      print('Error updating node cmd: $e');
    }
  }

  // Listen to device data changes
  Stream<DatabaseEvent> listenToDevice(String deviceId) {
    return _dbRef.child('devices/$deviceId').onValue;
  }
}