import 'package:flutter_test/flutter_test.dart';
import 'package:operon/enterprise/operations_workflow.dart';
import 'package:operon/enterprise/workflow_repository.dart';

void main() {
  test('a submission appears in the foreman queue', () {
    final repo = WorkflowRepository();
    repo.submit(id: '1', title: 'Inspect pump', createdBy: 'Operator');
    expect(repo.queueFor(OperonRole.foreman).length, 1);
    expect(repo.queueFor(OperonRole.coordinator), isEmpty);
  });

  test('approvals route to coordinator then management', () {
    final repo = WorkflowRepository();
    repo.submit(id: '1', title: 'Inspect pump', createdBy: 'Operator');
    repo.advance('1', WorkflowState.foremanReview, OperonRole.foreman, note: 'Checked', expectedRevision: 0);
    repo.advance('1', WorkflowState.coordinatorReview, OperonRole.foreman, note: 'Approved', expectedRevision: 1);
    expect(repo.queueFor(OperonRole.coordinator).length, 1);
    repo.advance('1', WorkflowState.managementReview, OperonRole.coordinator, note: 'Reviewed', expectedRevision: 2);
    expect(repo.queueFor(OperonRole.supervisor).length, 1);
    expect(repo.queueFor(OperonRole.unitEngineer).length, 1);
  });

  test('stale revision does not overwrite workflow state', () {
    final repo = WorkflowRepository();
    repo.submit(id: '1', title: 'Inspect pump', createdBy: 'Operator');
    repo.advance('1', WorkflowState.foremanReview, OperonRole.foreman, note: 'Received', expectedRevision: 0);
    expect(
      () => repo.advance('1', WorkflowState.coordinatorReview, OperonRole.foreman, note: 'Approved', expectedRevision: 0),
      throwsStateError,
    );
    expect(repo.find('1')!.history.length, 1);
  });

  test('duplicate submissions are rejected', () {
    final repo = WorkflowRepository();
    repo.submit(id: '1', title: 'Inspect pump', createdBy: 'Operator');
    expect(() => repo.submit(id: '1', title: 'Duplicate', createdBy: 'Operator'), throwsStateError);
  });
}
