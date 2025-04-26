// ignore_for_file: avoid_print

import 'package:astraval_smart/repo/device_reppo.dart';

import '../model/device.dart';
import '../utils/map_converter.dart';

class DeviceService {
  final deviceRepo = DeviceRepo();

  // Get device data
  Future<Device?> getDevice(String deviceId) async {
    try {
      final deviceData = await deviceRepo.fetchDeviceData(deviceId);
      if (deviceData != null) {
        return Device.fromJson(deviceId, deviceData);
      } else {
        print("Device data not found for deviceId: $deviceId");
        return null;
      }
    } catch (e) {
      print('Error getting device data: $e');
      return null;
    }
  }

  // Update device state
  Future<void> updateDeviceState(String deviceId, bool state) async {
    try {
      await deviceRepo.updateDeviceState(deviceId, state);
    } catch (e) {
      print('Error updating device state: $e');
    }
  }

  // Update node command
  Future<void> updateNodeCmd(String deviceId, String nodeId, bool cmd) async {
    try {
      await deviceRepo.updateNodeCmd(deviceId, nodeId, cmd);
    } catch (e) {
      print('Error updating node cmd: $e');
    }
  }

  // Listen to device changes
  Stream<Device> listenToDevice(String deviceId) {
    return deviceRepo.listenToDevice(deviceId).map((event) {
      final rawData = event.snapshot.value;
      if (rawData == null) {
        print('No data for device: $deviceId');
        return Device(id: deviceId, state: false, nodes:{} );
      }
      final data = convertToMapStringDynamic(rawData);
      print("device service: $data");
      try {
        final device = Device.fromJson(deviceId, data);
        print("Device created: $device");
        return device;
      } catch (e) {
        print('Error parsing device $deviceId: $e');
        return Device(id: deviceId, state: false, nodes: {});
      }
    }).handleError((e) {
      print('Stream error for device $deviceId: $e');
      return Device(id: deviceId, state: false, nodes: {});
    });
  }
}