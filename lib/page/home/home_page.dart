import 'dart:async';
import 'package:astraval_smart/model/device.dart';
import 'package:astraval_smart/model/node.dart';
import 'package:astraval_smart/model/user_data.dart';
import 'package:astraval_smart/service/device_service.dart';
import 'package:astraval_smart/service/user_service.dart';
import 'package:flutter/material.dart';

import '/authmanagement/auth_manage.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String userID = "";
  UserData? userData;
  Map<String, Device> devices = {};
  UserService userService = UserService();
  DeviceService deviceService = DeviceService();
  Map<String, Timer> _toggleTimers = {}; // Track timers for each node

  @override
  void initState() {
    super.initState();
    userID = AuthManage().getUserID();
    print('Current userID: $userID');
    _fetchUserData();
  }

  @override
  void dispose() {
    // Cancel all timers to prevent memory leaks
    _toggleTimers.forEach((_, timer) => timer.cancel());
    super.dispose();
  }

  Future<void> _fetchUserData() async {
    try {
      userData = await userService.getUserData(userID);
      print('UserData: $userData');
      if (mounted) {
        setState(() {});
        if (userData != null) {
          if (userData!.devices.isNotEmpty) {
            _fetchDevices();
          } else {
            print('No devices subscribed for user: $userID');
          }
        } else {
          print('User data not found for user: $userID');
        }
      }
    } catch (e) {
      print('Error fetching user data: $e');
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _fetchDevices() async {
    for (var deviceId in userData!.devices.keys) {
      deviceService.listenToDevice(deviceId).listen(
        (device) {
          if (mounted) {
            setState(() {
              devices[deviceId] = device;
              print('Updated device: $deviceId - ${devices[deviceId]}');
            });
          }
        },
        onError: (e) {
          print('Error listening to device $deviceId: $e');
          if (mounted) {
            setState(() {
              devices[deviceId] = Device(id: deviceId, state: false, nodes: {});
            });
          }
        },
      );
    }
  }

  Future<void> _handleToggle(
      String deviceId, String nodeId, bool cmdValue) async {
    await deviceService.updateNodeCmd(deviceId, nodeId, cmdValue);
    print('Toggled $deviceId/$nodeId to cmd: $cmdValue');

    // Cancel any existing timer for this node
    _toggleTimers['$deviceId/$nodeId']?.cancel();

    // Start a 5-second timer
    _toggleTimers['$deviceId/$nodeId'] = Timer(const Duration(seconds: 5), () {
      if (mounted) {
        final device = devices[deviceId];
        final node = device?.nodes[nodeId];
        if (node != null && node.cmd != node.status) {
          print(
              'Timeout: $deviceId/$nodeId cmd (${node.cmd}) != status (${node.status})');
          // Reset cmd to match status
          deviceService.updateNodeCmd(deviceId, nodeId, node.status);
          // Set device state to false (offline)
          deviceService.updateDeviceState(deviceId, false);
          print('Reset cmd to ${node.status} and set $deviceId state to false');
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    print('Building HomePage with devices: ${devices.keys.toList()}');
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Page"),
        centerTitle: true,
      ),
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : userData!.devices.isEmpty
              ? const Center(
                  child: Text(
                    "No devices subscribed. Please add a device.",
                    textAlign: TextAlign.center,
                  ),
                )
              : devices.isEmpty
                  ? Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text("Loading devices..."),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                devices.clear(); // Reset to trigger reload
                              });
                              _fetchDevices();
                            },
                            child: const Text("Retry"),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.all(8),
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        final deviceId = devices.keys.elementAt(index);
                        final device = devices[deviceId]!;
                        final deviceNodes = device.nodes.entries
                            .map((nodeEntry) => {
                                  'deviceId': deviceId,
                                  'nodeId': nodeEntry.key,
                                  'node': nodeEntry.value
                                })
                            .toList();

                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Device header
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 8),
                              child: Row(
                                children: [
                                  Text(
                                    'Device $deviceId',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    device.state ? 'Online' : 'Offline',
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: device.state
                                          ? Colors.green
                                          : Colors.red,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // GridView for device nodes
                            deviceNodes.isEmpty
                                ? const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text("No nodes available"),
                                  )
                                : GridView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    gridDelegate:
                                        const SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      crossAxisSpacing: 12,
                                      mainAxisSpacing: 12,
                                      childAspectRatio: 1,
                                    ),
                                    itemCount: deviceNodes.length,
                                    itemBuilder: (context, nodeIndex) {
                                      final nodeData = deviceNodes[nodeIndex];
                                      final nodeId =
                                          nodeData['nodeId'] as String;
                                      final node = nodeData['node'] as Node;
                                      final isToggling =
                                          node.cmd != node.status;
                                      final isOffline = !device.state;

                                      return NodeCard(
                                        deviceId: deviceId,
                                        nodeId: nodeId,
                                        node: node,
                                        isToggling: isToggling,
                                        isOffline: isOffline,
                                        onToggle: (cmdValue) {
                                          _handleToggle(
                                              deviceId, nodeId, cmdValue);
                                        },
                                      );
                                    },
                                  ),
                          ],
                        );
                      },
                    ),
    );
  }
}

class NodeCard extends StatelessWidget {
  final String deviceId;
  final String nodeId;
  final Node node;
  final bool isToggling;
  final bool isOffline;
  final void Function(bool) onToggle;

  const NodeCard({
    super.key,
    required this.deviceId,
    required this.nodeId,
    required this.node,
    required this.isToggling,
    required this.isOffline,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    // Determine icon based on node.type
    IconData typeIcon;
    switch (node.type.toLowerCase()) {
      case 'light':
        typeIcon = node.status ? Icons.lightbulb : Icons.lightbulb_outline;
        break;
      case 'fan':
        typeIcon = node.status ? Icons.wind_power : Icons.wind_power_outlined;
        break;
      default:
        typeIcon =
            node.status ? Icons.device_unknown : Icons.device_unknown_outlined;
    }

    return Card(
      elevation: 4,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          // Apply blur overlay for offline nodes
          boxShadow: isOffline
              ? [
                  BoxShadow(
                    color: Colors.grey.withOpacity(0.5),
                    spreadRadius: 0,
                    blurRadius: 0,
                    offset: const Offset(0, 0),
                  ),
                ]
              : [],
        ),
        padding: const EdgeInsets.all(8),
        child: Stack(
          children: [
            // Node name centered
            Center(
              child: Text(
                node.name,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            // Top-left: Type icon (light/fan)
            Positioned(
              top: 0,
              left: 0,
              child: Icon(
                typeIcon,
                size: 30,
                color: node.status ? Colors.yellow : Colors.grey,
              ),
            ),
            // Top-right: WiFi/Offline icon
            Positioned(
              top: 0,
              right: 0,
              child: Icon(
                isOffline ? Icons.wifi_off : Icons.wifi,
                size: 30,
                color: isOffline ? Colors.red : Colors.green,
              ),
            ),
            // Bottom-right: Switch or loading indicator
            Positioned(
              bottom: 0,
              right: 0,
              child: isToggling
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Switch(
                      value: node.status,
                      onChanged: isOffline ? null : onToggle,
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
