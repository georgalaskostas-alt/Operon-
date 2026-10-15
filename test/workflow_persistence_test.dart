import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:operon/enterprise/operations_workflow.dart';
import 'package:operon/enterprise/workflow_local_storage.dart';
import 'package:operon/enterprise/workflow_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('tasks and audit history survive repository recreation', () async {
    SharedPreferences.setMockInitialValues({});
    final storage = WorkflowLocalStorage();
    final first = WorkflowRepository();
    first.submit(id: 'DEMO-1', title: 'Inspect P-101', createdBy: 'Operator');
    first.advance('DEMO-1', WorkflowState.foremanReview, OperonRole.foreman,
        note: 'Inspected', expectedRevision: 0);
    await storage.save(first);

    final reopened = WorkflowRepository();
    reopened.restore(await storage.load());
    final item = reopened.find('DEMO-1')!;
    expect(item.title, 'Inspect P-101');
    expect(item.state, WorkflowState.foremanReview);
    expect(item.history.single.note, 'Inspected');
    expect(reopened.queueFor(OperonRole.foreman).length, 1);
  });

  test('empty storage restores an empty queue', () async {
    SharedPreferences.setMockInitialValues({});
    final repository = WorkflowRepository();
    repository.restore(await WorkflowLocalStorage().load());
    expect(repository.items, isEmpty);
  });
}
