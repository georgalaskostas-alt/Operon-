class OperatorTimer {
  final int id;
  final String title;
  final String? equipmentTag;
  final DateTime createdAt;
  DateTime dueAt;
  bool notificationSent;
  bool acknowledged;
  bool completed;
  DateTime? acknowledgedAt;
  DateTime? completedAt;
  int snoozeCount;

  OperatorTimer({
    required this.id,
    required this.title,
    this.equipmentTag,
    required this.createdAt,
    required this.dueAt,
    this.notificationSent = false,
    this.acknowledged = false,
    this.completed = false,
    this.acknowledgedAt,
    this.completedAt,
    this.snoozeCount = 0,
  });

  bool get due => !completed && DateTime.now().isAfter(dueAt);
  bool get active => !completed;

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'equipmentTag': equipmentTag,
    'createdAt': createdAt.toIso8601String(),
    'dueAt': dueAt.toIso8601String(),
    'notificationSent': notificationSent,
    'acknowledged': acknowledged,
    'completed': completed,
    'acknowledgedAt': acknowledgedAt?.toIso8601String(),
    'completedAt': completedAt?.toIso8601String(),
    'snoozeCount': snoozeCount,
  };

  factory OperatorTimer.fromJson(Map<String, dynamic> j) => OperatorTimer(
    id: j['id'],
    title: j['title'] ?? '',
    equipmentTag: j['equipmentTag'],
    createdAt: DateTime.parse(j['createdAt']),
    dueAt: DateTime.parse(j['dueAt']),
    notificationSent: j['notificationSent'] ?? j['acknowledged'] ?? false,
    acknowledged: j['completed'] == null ? false : (j['acknowledged'] ?? false),
    completed: j['completed'] ?? false,
    acknowledgedAt: j['acknowledgedAt'] == null ? null : DateTime.tryParse(j['acknowledgedAt']),
    completedAt: j['completedAt'] == null ? null : DateTime.tryParse(j['completedAt']),
    snoozeCount: j['snoozeCount'] ?? 0,
  );

  void acknowledge() {
    if (completed) return;
    acknowledged = true;
    acknowledgedAt = DateTime.now();
  }

  void snooze(Duration duration) {
    if (completed) return;
    dueAt = DateTime.now().add(duration);
    notificationSent = false;
    acknowledged = false;
    acknowledgedAt = null;
    snoozeCount++;
  }

  void complete() {
    if (completed) return;
    completed = true;
    completedAt = DateTime.now();
    acknowledged = true;
    acknowledgedAt ??= completedAt;
  }
}
