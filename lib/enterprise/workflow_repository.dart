import 'operations_workflow.dart';

/// Storage-neutral local workflow collection for prototyping.
/// Not a network repository or a substitute for server-side authorization.
class WorkflowRepository {
  final WorkflowEngine engine;
  final Map<String, WorkflowItem> _items = {};

  WorkflowRepository({this.engine = const WorkflowEngine()});

  List<WorkflowItem> get items {
    final result = _items.values.toList();
    result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return List.unmodifiable(result);
  }

  WorkflowItem? find(String id) => _items[id];

  void restore(Iterable<WorkflowItem> saved) {
    final restored = <String, WorkflowItem>{};
    for (final item in saved) {
      if (restored.containsKey(item.id)) throw StateError('Duplicate saved item id');
      restored[item.id] = item;
    }
    _items..clear()..addAll(restored);
  }

  WorkflowItem submit({
    required String id,
    required String title,
    required String createdBy,
    DateTime? createdAt,
  }) {
    if (id.trim().isEmpty || title.trim().isEmpty || createdBy.trim().isEmpty) {
      throw ArgumentError('Id, title and creator are required');
    }
    if (_items.containsKey(id)) {
      throw StateError('Duplicate item id');
    }
    final item = WorkflowItem(
      id: id.trim(),
      title: title.trim(),
      createdBy: createdBy.trim(),
      createdAt: createdAt ?? DateTime.now().toUtc(),
    );
    _items[item.id] = item;
    return item;
  }

  WorkflowItem advance(
    String id,
    WorkflowState next,
    OperonRole actor, {
    required String note,
    int? expectedRevision,
  }) {
    final current = _items[id];
    if (current == null) throw StateError('Item not found');
    if (expectedRevision != null && current.history.length != expectedRevision) {
      throw StateError('Workflow revision conflict');
    }
    final updated = engine.transition(current, next, actor, note: note);
    _items[id] = updated;
    return updated;
  }

  List<WorkflowItem> queueFor(OperonRole role) => List.unmodifiable(
    items.where((item) {
      switch (role) {
        case OperonRole.operator:
          return item.state == WorkflowState.returned;
        case OperonRole.foreman:
          return item.state == WorkflowState.submitted ||
              item.state == WorkflowState.foremanReview;
        case OperonRole.coordinator:
          return item.state == WorkflowState.coordinatorReview;
        case OperonRole.supervisor:
        case OperonRole.unitEngineer:
          return item.state == WorkflowState.managementReview;
      }
    }),
  );
}
