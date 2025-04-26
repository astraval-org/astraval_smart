import 'package:astraval_smart/model/device.dart';
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

  @override
  void initState() {
    super.initState();
    userID = AuthManage().getUserID();
    print('Current userID: $userID');
    _fetchUserData();
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
                      itemCount: devices.length,
                      itemBuilder: (context, index) {
                        final deviceId = devices.keys.elementAt(index);
                        final device = devices[deviceId]!;
                        print('Rendering device: $deviceId');
                        return RepaintBoundary(
                          child: ExpansionTile(
                            title: Text(
                              'Device $deviceId (${device.state ? 'Online' : 'Offline'})',
                              style: TextStyle(
                                color: device.state ? Colors.green : Colors.red,
                              ),
                            ),
                            children: device.nodes.isEmpty
                                ? [
                                    const ListTile(
                                      title: Text("No nodes available"),
                                    )
                                  ]
                                : [
                                    ListView.builder(
                                      shrinkWrap: true,
                                      physics:
                                          const NeverScrollableScrollPhysics(),
                                      itemCount: device.nodes.length,
                                      itemBuilder: (context, nodeIndex) {
                                        final nodeId = device.nodes.keys
                                            .elementAt(nodeIndex);
                                        final node = device.nodes[nodeId]!;
                                        final isToggling =
                                            node.cmd != node.status;
                                        return ListTile(
                                          title: Text(node.name),
                                          subtitle: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text('Type: ${node.type}'),
                                              Text(
                                                  'Status: ${node.status ? 'ON' : 'OFF'}'),
                                            ],
                                          ),
                                          trailing: isToggling
                                              ? const SizedBox(
                                                  width: 24,
                                                  height: 24,
                                                  child:
                                                      CircularProgressIndicator(
                                                          strokeWidth: 2),
                                                )
                                              : Switch(
                                                  value: node.status,
                                                  onChanged: (value) async {
                                                    if (mounted) {
                                                      await Future.delayed(
                                                          const Duration(
                                                              milliseconds:
                                                                  200));
                                                      await deviceService
                                                          .updateNodeCmd(
                                                              deviceId,
                                                              nodeId,
                                                              value);
                                                      print(
                                                          'Toggled $deviceId/$nodeId to cmd: $value');
                                                    }
                                                  },
                                                ),
                                        );
                                      },
                                    ),
                                  ],
                          ),
                        );
                      },
                    ),
    );
  }
}
