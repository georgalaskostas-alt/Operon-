import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../localization/app_language.dart';
import '../models/procedure_models.dart';
import '../theme/operon_theme.dart';

class ProcedureRunScreen extends StatefulWidget {
  final AppStore store;
  final ControlledProcedure procedure;
  final ProcedureRun run;
  const ProcedureRunScreen({super.key, required this.store, required this.procedure, required this.run});
  @override State<ProcedureRunScreen> createState() => _S();
}

class _S extends State<ProcedureRunScreen> {
  @override
  Widget build(BuildContext c) {
    final r = widget.run, p = widget.procedure, t = c.tr;
    return Scaffold(
      appBar: AppBar(title: Text(p.title)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(child: ListTile(
          leading: const Icon(Icons.verified_user, color: OperonTheme.teal),
          title: Text('${p.source} · v${p.version}'),
          subtitle: Text(t.operatorConfirmSafety),
        )),
        LinearProgressIndicator(value: p.steps.isEmpty ? 0 : r.completedSteps / p.steps.length),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Text('${r.completedSteps}/${p.steps.length} ${t.confirmed} · ${r.state.name}',
            style: const TextStyle(color: OperonTheme.muted)),
        ),
        ...p.steps.asMap().entries.map((e) {
          final step = e.value;
          final record = r.records.firstWhere((x) => x.stepId == step.id);
          return Card(child: CheckboxListTile(
            value: record.confirmed,
            onChanged: r.state == ProcedureRunState.completed ? null : (v) {
              if (step.safetyCritical && v == true) {
                _confirmCritical(step);
              } else {
                widget.store.setProcedureStep(r, step.id, v ?? false);
                setState(() {});
              }
            },
            title: Text('${e.key + 1}. ${step.title}', style: const TextStyle(fontWeight: FontWeight.w700)),
            subtitle: Text(step.safetyCritical
              ? t.safetyCritical
              : record.confirmedAt == null
                ? t.notConfirmed
                : '${t.confirmedAt} ${TimeOfDay.fromDateTime(record.confirmedAt!).format(c)}'),
            secondary: Icon(step.safetyCritical ? Icons.shield_outlined : Icons.checklist,
              color: step.safetyCritical ? Colors.orange : OperonTheme.teal),
          ));
        }),
        if (r.state != ProcedureRunState.completed)
          Wrap(spacing: 8, children: [
            OutlinedButton.icon(
              onPressed: () {
                widget.store.setProcedureRunState(r, r.state == ProcedureRunState.paused ? ProcedureRunState.active : ProcedureRunState.paused);
                setState(() {});
              },
              icon: Icon(r.state == ProcedureRunState.paused ? Icons.play_arrow : Icons.pause),
              label: Text(r.state == ProcedureRunState.paused ? t.resume : t.pause),
            ),
            FilledButton.icon(
              onPressed: r.completedSteps == p.steps.length ? () {
                widget.store.setProcedureRunState(r, ProcedureRunState.completed);
                setState(() {});
              } : null,
              icon: const Icon(Icons.task_alt), label: Text(t.completeRun),
            )
          ])
      ]),
    );
  }

  void _confirmCritical(ProcedureStep s) {
    final t = context.tr;
    showDialog(
      context: context,
      builder: (c) => AlertDialog(
        title: Text(t.explicitConfirmation),
        content: Text(t.criticalConfirmation(s.title)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(c), child: Text(t.cancel)),
          FilledButton(onPressed: () {
            widget.store.setProcedureStep(widget.run, s.id, true);
            Navigator.pop(c);
            setState(() {});
          }, child: Text(t.iConfirm)),
        ],
      ),
    );
  }
}
