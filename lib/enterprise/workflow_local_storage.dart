import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import 'operations_workflow.dart';
import 'workflow_repository.dart';

/// Device-local demo persistence. Not secure storage or multi-user sync.
class WorkflowLocalStorage {
  static const key = 'operon.enterprise.workflow.demo.v1';

  Future<List<WorkflowItem>> load() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(key);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded.map((value) {
      final row = Map<String, dynamic>.from(value as Map);
      final events = (row['history'] as List<dynamic>).map((entry) {
        final e = Map<String, dynamic>.from(entry as Map);
        return WorkflowEvent(
          actor: OperonRole.values.byName(e['actor'] as String),
          from: WorkflowState.values.byName(e['from'] as String),
          to: WorkflowState.values.byName(e['to'] as String),
          note: e['note'] as String,
          at: DateTime.parse(e['at'] as String),
        );
      }).toList(growable: false);
      return WorkflowItem(
        id: row['id'] as String,
        title: row['title'] as String,
        createdBy: row['createdBy'] as String,
        createdAt: DateTime.parse(row['createdAt'] as String),
        state: WorkflowState.values.byName(row['state'] as String),
        history: List.unmodifiable(events),
      );
    }).toList(growable: false);
  }

  Future<void> save(WorkflowRepository repository) async {
    final prefs = await SharedPreferences.getInstance();
    final rows = repository.items.map((item) => {
      'id': item.id,
      'title': item.title,
      'createdBy': item.createdBy,
      'createdAt': item.createdAt.toIso8601String(),
      'state': item.state.name,
      'history': item.history.map((e) => {
        'actor': e.actor.name,
        'from': e.from.name,
        'to': e.to.name,
        'note': e.note,
        'at': e.at.toIso8601String(),
      }).toList(),
    }).toList();
    final saved = await prefs.setString(key, jsonEncode(rows));
    if (!saved) throw StateError('Could not save workflow demo');
  }
}
