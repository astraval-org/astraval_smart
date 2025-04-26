class Node {
  final bool cmd;
  final String name;
  final bool status;
  final String type;

  Node({
    required this.cmd,
    required this.name,
    required this.status,
    required this.type,
  });

  factory Node.fromJson(Map<String, dynamic> json) {
    return Node(
      cmd: json['cmd'] is bool ? json['cmd'] as bool : false,
      name: json['name'] is String ? json['name'] as String : '',
      status: json['status'] is bool ? json['status'] as bool : false,
      type: json['type'] is String ? json['type'] as String : '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'cmd': cmd,
      'name': name,
      'status': status,
      'type': type,
    };
  }

  @override
  String toString() {
    return 'Node{cmd: $cmd, name: $name, status: $status, type: $type}';
  }
}