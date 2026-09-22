import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../models/models.dart';
import '../theme/operon_theme.dart';

class ActionsScreen extends StatefulWidget {
  final AppStore store;
  const ActionsScreen({super.key, required this.store});
  @override State<ActionsScreen> createState() => _ActionsScreenState();
}
class _ActionsScreenState extends State<ActionsScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Pending actions')),
    body: ListView(
      children: widget.store.tasks.map((task) => Card(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        child: ListTile(
          leading: Icon(task.state == ActionState.completed ? Icons.check_circle : Icons.pending_actions,color: task.state == ActionState.completed ? Colors.green : OperonTheme.teal),
          title: Text(task.title),
          subtitle: Text('${task.equipmentTag ?? 'General'} · ${task.state.name}'),
          trailing: PopupMenuButton<ActionState>(
            onSelected: (state) => setState(() => widget.store.setTaskState(task, state)),
            itemBuilder: (_) => ActionState.values.map((state) => PopupMenuItem(value: state, child: Text(state.name))).toList(),
          ),
        ),
      )).toList(),
    ),
    floatingActionButton: FloatingActionButton(onPressed: () => _add(context), child: const Icon(Icons.add_task)),
  );

  void _add(BuildContext context) {
    final action = TextEditingController(), tag = TextEditingController();
    showDialog(context: context,builder: (dialogContext) => AlertDialog(
      title: const Text('New action'),
      content: Column(mainAxisSize: MainAxisSize.min,children: [
        TextField(controller: action, decoration: const InputDecoration(labelText: 'Action')),
        const SizedBox(height: 8),
        TextField(controller: tag, decoration: const InputDecoration(labelText: 'Equipment tag (optional)')),
      ]),
      actions: [FilledButton(onPressed: () {
        widget.store.addTask(action.text, tag: tag.text.trim().isEmpty ? null : tag.text.trim().toUpperCase());
        Navigator.pop(dialogContext);
        setState(() {});
      }, child: const Text('Add'))],
    ));
  }
}
