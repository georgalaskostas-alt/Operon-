import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../localization/app_language.dart';
import '../models/models.dart';
import '../theme/operon_theme.dart';

class ActionsScreen extends StatefulWidget {
  final AppStore store;
  const ActionsScreen({super.key, required this.store});
  @override
  State<ActionsScreen> createState() => _ActionsScreenState();
}

class _ActionsScreenState extends State<ActionsScreen> {
  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    return Scaffold(
      appBar: AppBar(title: Text(t.pendingActions)),
      body: ListView(
        children: widget.store.tasks
            .map((task) => Card(
                  margin:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  child: ListTile(
                    leading: Icon(
                      task.state == ActionState.completed
                          ? Icons.check_circle
                          : Icons.pending_actions,
                      color: task.state == ActionState.completed
                          ? Colors.green
                          : OperonTheme.teal,
                    ),
                    title: Text(task.title),
                    subtitle:
                        Text('${task.equipmentTag ?? t.general} · ${task.state.name}'),
                    trailing: PopupMenuButton<ActionState>(
                      onSelected: (state) => setState(
                          () => widget.store.setTaskState(task, state)),
                      itemBuilder: (_) => ActionState.values
                          .map((state) => PopupMenuItem(
                              value: state, child: Text(state.name)))
                          .toList(),
                    ),
                  ),
                ))
            .toList(),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _add(context),
        child: const Icon(Icons.add_task),
      ),
    );
  }

  void _add(BuildContext context) {
    final t = context.tr;
    final action = TextEditingController(), tag = TextEditingController();
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.newAction),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          TextField(
              controller: action,
              decoration: InputDecoration(labelText: t.action)),
          const SizedBox(height: 8),
          TextField(
              controller: tag,
              decoration: InputDecoration(labelText: t.equipmentTagOptional)),
        ]),
        actions: [
          FilledButton(
            onPressed: () {
              widget.store.addTask(action.text,
                  tag: tag.text.trim().isEmpty
                      ? null
                      : tag.text.trim().toUpperCase());
              Navigator.pop(dialogContext);
              setState(() {});
            },
            child: Text(t.add),
          )
        ],
      ),
    );
  }
}
