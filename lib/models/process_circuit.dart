class CircuitNode {
  final String tag;
  final String role;
  final int order;

  const CircuitNode({
    required this.tag,
    required this.role,
    required this.order,
  });

  static String normalizeRole(String value) {
    switch (value.trim().toLowerCase()) {
      case 'upstream':
      case 'ανάντη':
        return 'upstream';
      case 'downstream':
      case 'κατάντη':
        return 'downstream';
      case 'process':
      case 'διεργασία':
        return 'process';
      default:
        return 'process';
    }
  }

  Map<String, dynamic> toJson() => {
        'tag': tag,
        'role': normalizeRole(role),
        'order': order,
      };

  factory CircuitNode.fromJson(Map<String, dynamic> j) => CircuitNode(
        tag: j['tag'] ?? '',
        role: normalizeRole(j['role'] ?? ''),
        order: j['order'] ?? 0,
      );
}

class ProcessCircuit {
  final String id;
  String name, description, pidReference, source;
  List<CircuitNode> nodes;
  DateTime updatedAt;

  ProcessCircuit({
    required this.id,
    required this.name,
    this.description = '',
    this.pidReference = '',
    this.source = '',
    this.nodes = const [],
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? DateTime.now();

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'pidReference': pidReference,
        'source': source,
        'nodes': nodes.map((e) => e.toJson()).toList(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  factory ProcessCircuit.fromJson(Map<String, dynamic> j) => ProcessCircuit(
        id: j['id'] ?? '',
        name: j['name'] ?? '',
        description: j['description'] ?? '',
        pidReference: j['pidReference'] ?? '',
        source: j['source'] ?? '',
        nodes: ((j['nodes'] as List?) ?? [])
            .map((e) => CircuitNode.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        updatedAt: DateTime.tryParse(j['updatedAt'] ?? ''),
      );
}
