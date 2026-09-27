class ShiftHandover {
  final String id, outgoingOperator;
  final DateTime createdAt;
  final String outgoingShift;
  final List<String> openItems, maintenance, watchItems, timers;
  final List<String> overdueItems, carriedItems, shiftEvents;
  final String notes;
  String? incomingOperator;
  DateTime? acceptedAt;

  ShiftHandover({
    required this.id,
    required this.createdAt,
    required this.outgoingOperator,
    required this.outgoingShift,
    required this.openItems,
    required this.maintenance,
    required this.watchItems,
    required this.timers,
    this.overdueItems = const [],
    this.carriedItems = const [],
    this.shiftEvents = const [],
    this.notes = '',
    this.incomingOperator,
    this.acceptedAt,
  });

  bool get accepted => acceptedAt != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'outgoingOperator': outgoingOperator,
        'outgoingShift': outgoingShift,
        'openItems': openItems,
        'maintenance': maintenance,
        'watchItems': watchItems,
        'timers': timers,
        'overdueItems': overdueItems,
        'carriedItems': carriedItems,
        'shiftEvents': shiftEvents,
        'notes': notes,
        'incomingOperator': incomingOperator,
        'acceptedAt': acceptedAt?.toIso8601String(),
      };

  factory ShiftHandover.fromJson(Map<String, dynamic> j) => ShiftHandover(
        id: j['id'] ?? '',
        createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
        outgoingOperator: j['outgoingOperator'] ?? '',
        outgoingShift: j['outgoingShift'] ?? '',
        openItems: List<String>.from(j['openItems'] ?? []),
        maintenance: List<String>.from(j['maintenance'] ?? []),
        watchItems: List<String>.from(j['watchItems'] ?? []),
        timers: List<String>.from(j['timers'] ?? []),
        overdueItems: List<String>.from(j['overdueItems'] ?? []),
        carriedItems: List<String>.from(j['carriedItems'] ?? []),
        shiftEvents: List<String>.from(j['shiftEvents'] ?? []),
        notes: j['notes'] ?? '',
        incomingOperator: j['incomingOperator'],
        acceptedAt:
            j['acceptedAt'] == null ? null : DateTime.tryParse(j['acceptedAt']),
      );
}
