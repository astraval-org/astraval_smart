import 'package:astraval_smart/model/node.dart';
import '../utils/map_converter.dart';

class Device {
  final String id;
  final bool state;
  final Map<String, Node> nodes;

  Device({
    required this.id,
    required this.state,
    required this.nodes,
  });

  factory Device.fromJson(String id, Map<String, dynamic> json) {
    // Safely convert nested 'node' map
    final nodesJsonRaw = json['node'] ?? {};
    final nodesJson = convertToMapStringDynamic(nodesJsonRaw) ?? {};
    final nodes = nodesJson.map(
      (key, value) {
        // Ensure each node value is Map<String, dynamic>
        final nodeData = value is Map ? Map<String, dynamic>.from(value) : <String, dynamic>{};
        return MapEntry(key, Node.fromJson(nodeData));
      },
    );
    return Device(
      id: id,
      state: json['state'] is bool ? json['state'] as bool : false,
      nodes: nodes,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'state': state,
      'node': nodes.map((key, node) => MapEntry(key, node.toJson())),
    };
  }

  @override
  String toString() {
    return 'Device{id: $id, state: $state, nodes: $nodes}';
  }
}