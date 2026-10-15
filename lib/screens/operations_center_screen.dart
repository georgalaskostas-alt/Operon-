import 'package:flutter/material.dart';
import '../enterprise/operations_workflow.dart';
import '../enterprise/workflow_repository.dart';
import '../theme/operon_theme.dart';

/// Local demonstration only: role switching does not authenticate the user.
class OperationsCenterScreen extends StatefulWidget {
  const OperationsCenterScreen({super.key});

  @override
  State<OperationsCenterScreen> createState() => _OperationsCenterScreenState();
}

class _OperationsCenterScreenState extends State<OperationsCenterScreen> {
  final WorkflowRepository repository = WorkflowRepository();
  OperonRole role = OperonRole.operator;
  int sequence = 0;

  String roleName(OperonRole r) => switch (r) {
    OperonRole.operator => 'Operator / Χειριστής',
    OperonRole.foreman => 'Foreman / Εργοδηγός',
    OperonRole.coordinator => 'Coordinator / Συντονιστής',
    OperonRole.supervisor => 'Supervisor / Προϊστάμενος',
    OperonRole.unitEngineer => 'Unit Engineer / Μηχανικός',
  };

  String stateName(WorkflowState s) => switch (s) {
    WorkflowState.submitted => 'Submitted / Υποβλήθηκε',
    WorkflowState.foremanReview => 'Foreman review / Έλεγχος εργοδηγού',
    WorkflowState.coordinatorReview => 'Coordinator review / Έλεγχος συντονιστή',
    WorkflowState.managementReview => 'Management review / Έλεγχος διοίκησης',
    WorkflowState.completed => 'Completed / Ολοκληρώθηκε',
    WorkflowState.returned => 'Returned / Επιστράφηκε',
  };

  Future<void> addItem() async {
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New task / Νέα εκκρεμότητα'),
        content: TextField(controller: controller, autofocus: true,
          maxLines: 2, decoration: const InputDecoration(hintText: 'e.g. Inspect P-101')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Submit')),
        ],
      ),
    );
    // Dialog exit animation may still own the TextField for this frame.
    // Dispose only after the route has finished its reverse transition.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    controller.dispose();
    if (!mounted || title == null || title.isEmpty) return;
    setState(() {
      sequence++;
      repository.submit(id: 'DEMO-${DateTime.now().microsecondsSinceEpoch}-$sequence',
        title: title, createdBy: 'Demo Operator');
    });
  }

  Future<void> changeState(WorkflowItem item, WorkflowState next) async {
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(stateName(next)),
        content: TextField(controller: controller, autofocus: true,
          decoration: const InputDecoration(hintText: 'Required reason / Αιτιολογία')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(ctx, controller.text.trim()), child: const Text('Confirm')),
        ],
      ),
    );
    // Keep the controller alive until the dialog reverse animation ends.
    await Future<void>.delayed(const Duration(milliseconds: 350));
    controller.dispose();
    if (!mounted || note == null || note.isEmpty) return;
    try {
      setState(() => repository.advance(item.id, next, role,
        note: note, expectedRevision: item.history.length));
    } on StateError catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(e.message)));
    }
  }

  List<WorkflowState> nextStates(WorkflowItem item) => WorkflowState.values
      .where((state) => const WorkflowEngine().canTransition(item.state, state, role))
      .toList();

  @override
  Widget build(BuildContext context) {
    final queue = repository.queueFor(role);
    return Scaffold(
      appBar: AppBar(title: const Text('Operations Center')),
      floatingActionButton: role == OperonRole.operator
          ? FloatingActionButton.extended(onPressed: addItem,
              icon: const Icon(Icons.add), label: const Text('New task'))
          : null,
      body: ListView(padding: const EdgeInsets.fromLTRB(16, 12, 16, 100), children: [
        const Card(child: Padding(padding: EdgeInsets.all(14),
          child: Text('DEMO MODE — local only. Role switching is simulated. No shared data or real approvals.',
            style: TextStyle(color: OperonTheme.muted)))),
        const SizedBox(height: 10),
        DropdownButtonFormField<OperonRole>(
          initialValue: role,
          decoration: const InputDecoration(labelText: 'Demo role / Δοκιμαστικός ρόλος'),
          items: OperonRole.values.map((r) => DropdownMenuItem(
            value: r, child: Text(roleName(r)))).toList(),
          onChanged: (r) { if (r != null) setState(() => role = r); },
        ),
        const SizedBox(height: 18),
        Text('My queue / Εκκρεμότητες: ${queue.length}',
          style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 8),
        if (queue.isEmpty) const Card(child: Padding(padding: EdgeInsets.all(20),
          child: Text('No items for this role / Δεν υπάρχουν εκκρεμότητες'))),
        ...queue.map((item) => taskCard(item)),
        const SizedBox(height: 20),
        Text('All demo items / Όλες οι καταχωρίσεις',
          style: Theme.of(context).textTheme.titleMedium),
        ...repository.items.map((item) => taskCard(item, compact: true)),
      ]),
    );
  }

  Widget taskCard(WorkflowItem item, {bool compact = false}) {
    final actions = nextStates(item);
    return Card(child: Padding(padding: const EdgeInsets.all(14), child:
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(item.title, style: const TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 6),
        Text(stateName(item.state), style: const TextStyle(color: OperonTheme.teal)),
        Text('ID: ${item.id} · History: ${item.history.length}',
          style: const TextStyle(color: OperonTheme.muted, fontSize: 12)),
        if (!compact && actions.isNotEmpty) ...[
          const SizedBox(height: 10),
          Wrap(spacing: 8, runSpacing: 8, children: actions.map((next) =>
            OutlinedButton(onPressed: () => changeState(item, next),
              child: Text(stateName(next)))).toList()),
        ],
        if (!compact && item.history.isNotEmpty)
          ExpansionTile(title: const Text('Audit history / Ιστορικό'),
            tilePadding: EdgeInsets.zero,
            children: item.history.map((e) => ListTile(
              dense: true,
              title: Text('${roleName(e.actor)}: ${stateName(e.to)}'),
              subtitle: Text(e.note),
            )).toList()),
      ])));
  }
}
