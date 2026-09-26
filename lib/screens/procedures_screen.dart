import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../localization/app_language.dart';
import '../models/procedure_models.dart';
import '../theme/operon_theme.dart';
import 'procedure_run_screen.dart';

class ProceduresScreen extends StatefulWidget {
  final AppStore store;
  const ProceduresScreen({super.key, required this.store});
  @override
  State<ProceduresScreen> createState() => _S();
}

class _S extends State<ProceduresScreen> {
  @override
  Widget build(BuildContext c) {
    final t = c.tr;
    return Scaffold(
      appBar: AppBar(title: Text(t.proceduresChecklists)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 30),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(t.procedureSafety,
                style: const TextStyle(color: OperonTheme.muted)),
          ),
          ...widget.store.controlledProcedures.map(
            (p) => Card(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
              child: ListTile(
                onTap: () => _open(p),
                leading:
                    const Icon(Icons.fact_check, color: OperonTheme.teal),
                title: Text(p.title,
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text('${p.category} · v${p.version}\n${p.source}'),
                isThreeLine: true,
                trailing: const Icon(Icons.play_circle_outline),
              ),
            ),
          ),
          if (widget.store.procedureRuns.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Text(t.runHistory,
                  style: const TextStyle(
                      color: OperonTheme.muted,
                      fontSize: 11,
                      fontWeight: FontWeight.w900)),
            ),
            ...widget.store.procedureRuns.take(12).map(
                  (r) => ListTile(
                    onTap: () => _openHistory(r),
                    leading: Icon(
                      r.state == ProcedureRunState.completed
                          ? Icons.check_circle
                          : Icons.history,
                      color: r.state == ProcedureRunState.completed
                          ? OperonTheme.teal
                          : Colors.orange,
                    ),
                    title: Text(r.procedureTitle),
                    subtitle: Text(
                      'v${r.version} · ${r.operatorName} · ${t.procedureState(r.state.name)}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                )
          ]
        ],
      ),
    );
  }

  void _openHistory(ProcedureRun r) {
    final p = widget.store.controlledProcedures.firstWhere(
      (x) => x.id == r.procedureId,
      orElse: () => ControlledProcedure(
        id: r.procedureId,
        title: r.procedureTitle,
        category: '',
        source: r.source,
        version: r.version,
        steps: r.records
            .map(
              (x) => ProcedureStep(
                id: x.stepId,
                title: x.stepTitle.isEmpty ? x.stepId : x.stepTitle,
                safetyCritical: x.safetyCritical,
              ),
            )
            .toList(),
      ),
    );
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ProcedureRunScreen(store: widget.store, procedure: p, run: r),
      ),
    ).then((_) => setState(() {}));
  }

  void _open(ControlledProcedure p) {
    final active = widget.store.procedureRuns.where((r) =>
        r.procedureId == p.id &&
        (r.state == ProcedureRunState.active ||
            r.state == ProcedureRunState.paused));
    final r =
        active.isNotEmpty ? active.first : widget.store.startProcedure(p);
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ProcedureRunScreen(store: widget.store, procedure: p, run: r),
      ),
    ).then((_) => setState(() {}));
  }
}
