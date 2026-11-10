/// Offline-testable workflow rules. Server authorization must enforce these rules
/// independently before OPERON can be used with real multi-user data.
enum OperonRole { operator, foreman, coordinator, supervisor, unitEngineer }
enum WorkflowState { submitted, foremanReview, coordinatorReview, managementReview, completed, returned }

class WorkflowEvent {
  final OperonRole actor;
  final WorkflowState from;
  final WorkflowState to;
  final String note;
  final DateTime at;
  const WorkflowEvent({required this.actor, required this.from, required this.to, required this.note, required this.at});
}

class WorkflowItem {
  final String id;
  final String title;
  final String createdBy;
  final DateTime createdAt;
  final WorkflowState state;
  final List<WorkflowEvent> history;
  const WorkflowItem({required this.id, required this.title, required this.createdBy, required this.createdAt, this.state = WorkflowState.submitted, this.history = const []});
  WorkflowItem copyWith({WorkflowState? state, List<WorkflowEvent>? history}) => WorkflowItem(id: id, title: title, createdBy: createdBy, createdAt: createdAt, state: state ?? this.state, history: history ?? this.history);
}

class WorkflowEngine {
  const WorkflowEngine();

  bool canTransition(WorkflowState from, WorkflowState to, OperonRole role) {
    switch (from) {
      case WorkflowState.submitted:
        return role == OperonRole.foreman && (to == WorkflowState.foremanReview || to == WorkflowState.returned);
      case WorkflowState.foremanReview:
        return role == OperonRole.foreman && (to == WorkflowState.coordinatorReview || to == WorkflowState.returned);
      case WorkflowState.coordinatorReview:
        return role == OperonRole.coordinator && (to == WorkflowState.managementReview || to == WorkflowState.returned);
      case WorkflowState.managementReview:
        return (role == OperonRole.supervisor || role == OperonRole.unitEngineer) && (to == WorkflowState.completed || to == WorkflowState.returned);
      case WorkflowState.returned:
        return role == OperonRole.operator && to == WorkflowState.submitted;
      case WorkflowState.completed:
        return false;
    }
  }

  WorkflowItem transition(WorkflowItem item, WorkflowState to, OperonRole role, {required String note, DateTime? at}) {
    if (!canTransition(item.state, to, role)) {
      throw StateError('Transition not allowed: ${item.state.name} -> ${to.name} for ${role.name}');
    }
    if (note.trim().isEmpty) throw ArgumentError('An audit note is required');
    final event = WorkflowEvent(actor: role, from: item.state, to: to, note: note.trim(), at: at ?? DateTime.now().toUtc());
    return item.copyWith(state: to, history: List.unmodifiable([...item.history, event]));
  }
}
