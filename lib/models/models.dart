enum EquipmentState { running, standby, maintenance, outOfService, taggedOut }
enum Priority { normal, important, critical }
enum ActionState { open, inProgress, waiting, completed }

class Equipment {
  final String tag;
  final String name;
  final String area;
  EquipmentState state;
  String note;
  Equipment({required this.tag, required this.name, required this.area, this.state = EquipmentState.running, this.note = ''});
}

class LogEntry {
  final String id;
  final DateTime createdAt;
  final String text;
  final String? equipmentTag;
  final Priority priority;
  final String source;
  LogEntry({required this.id, required this.createdAt, required this.text, this.equipmentTag, this.priority = Priority.normal, this.source = 'manual'});
}

class WatchItem {
  final String id;
  final String title;
  final String detail;
  final String? equipmentTag;
  bool active;
  WatchItem({required this.id, required this.title, required this.detail, this.equipmentTag, this.active = true});
}

class OperatorTask {
  final String id;
  final String title;
  final String? equipmentTag;
  DateTime? dueAt;
  ActionState state;
  OperatorTask({required this.id, required this.title, this.equipmentTag, this.dueAt, this.state = ActionState.open});
}

class ProcedureItem {
  final String title;
  final String category;
  final String source;
  const ProcedureItem(this.title, this.category, this.source);
}
