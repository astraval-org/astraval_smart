class UserData {
  final String name;
  final Map<String, String> devices;

  UserData({
    required this.name,
    required this.devices,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    final devicesJson = json['devices'] as Map<String, dynamic>? ?? {};
    return UserData(
      name: json['name'] as String? ?? 'Unknown',
      devices: devicesJson.map(
        (k, e) => MapEntry(k, e as String? ?? ''),
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'devices': devices.map((k, e) => MapEntry(k, e)),
    };
  }

  @override
  String toString() {
    return 'UserData{name: $name, devices: $devices}';
  }
}
