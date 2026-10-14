import 'package:flutter_test/flutter_test.dart';
import 'package:operon/enterprise/operations_workflow.dart';

void main() {
  const engine = WorkflowEngine();
  WorkflowItem item() => WorkflowItem(id: 'demo-1', title: 'Inspect P-101', createdBy: 'demo-operator', createdAt: DateTime.utc(2026));

  test('operator cannot approve their own submission', () {
    expect(() => engine.transition(item(), WorkflowState.coordinatorReview, OperonRole.operator, note: 'approve'), throwsStateError);
  });

  test('review chain keeps a complete immutable audit history', () {
    final first = engine.transition(item(), WorkflowState.foremanReview, OperonRole.foreman, note: 'Received');
    final second = engine.transition(first, WorkflowState.coordinatorReview, OperonRole.foreman, note: 'Checked');
    final third = engine.transition(second, WorkflowState.managementReview, OperonRole.coordinator, note: 'Reviewed');
    final last = engine.transition(third, WorkflowState.completed, OperonRole.supervisor, note: 'Closed');
    expect(last.state, WorkflowState.completed);
    expect(last.history.length, 4);
    expect(first.history.length, 1);
    expect(() => engine.transition(last, WorkflowState.submitted, OperonRole.operator, note: 'Reopen'), throwsStateError);
  });

  test('returned item may be resubmitted by operator', () {
    final returned = engine.transition(item(), WorkflowState.returned, OperonRole.foreman, note: 'Need clarification');
    final resubmitted = engine.transition(returned, WorkflowState.submitted, OperonRole.operator, note: 'Clarified');
    expect(resubmitted.history.length, 2);
  });

  test('empty audit note is rejected', () {
    expect(() => engine.transition(item(), WorkflowState.foremanReview, OperonRole.foreman, note: ' '), throwsArgumentError);
  });

  test('coordinator cannot bypass foreman', () {
    expect(engine.canTransition(WorkflowState.submitted, WorkflowState.managementReview, OperonRole.coordinator), isFalse);
  });
}
