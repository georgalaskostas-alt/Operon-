import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../localization/app_language.dart';
import '../models/models.dart';
import '../theme/operon_theme.dart';
import '../widgets/common.dart';
import 'handover_screen.dart';

class ShiftSessionScreen extends StatefulWidget {
  final AppStore store;
  const ShiftSessionScreen({super.key, required this.store});
  @override State<ShiftSessionScreen> createState() => _S();
}

class _S extends State<ShiftSessionScreen> {
  final operator = TextEditingController();
  ShiftType type = ShiftType.morning;

  @override
  Widget build(BuildContext c) {
    final s = widget.store.currentShift, t = c.tr;
    return Scaffold(
      appBar: AppBar(title: Text(t.shiftSession)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        if (s == null || !s.active) ...[
          Text(t.startShift, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Text(t.carriedInfo, style: const TextStyle(color: OperonTheme.muted)),
          const SizedBox(height: 18),
          TextField(controller: operator, onChanged: (_) => setState(() {}), decoration: InputDecoration(labelText: t.operatorName)),
          const SizedBox(height: 12),
          DropdownButtonFormField<ShiftType>(
            initialValue: type,
            items: ShiftType.values.map((e) => DropdownMenuItem(value: e, child: Text(e.name))).toList(),
            onChanged: (v) => setState(() => type = v ?? type),
            decoration: InputDecoration(labelText: t.shift),
          ),
          const SizedBox(height: 18),
          FilledButton.icon(
            onPressed: operator.text.trim().isEmpty ? null : () { widget.store.startShift(operator.text, type); setState(() {}); },
            icon: const Icon(Icons.play_arrow), label: Text(t.startShift),
          )
        ] else ...[
          _summary(s, t),
          if (widget.store.carriedTasks.isNotEmpty) ...[
            SectionLabel(t.carriedOver),
            ...widget.store.carriedTasks.map((e) => _task(e, '${t.carriedLabel} ×${e.carriedShifts}', e.overdue ? Colors.orange : OperonTheme.teal, t)),
          ],
          if (widget.store.overdueTasks.isNotEmpty) ...[
            SectionLabel(t.overdue),
            ...widget.store.overdueTasks.map((e) => _task(e, t.overdueLabel, Colors.orange, t)),
          ],
          if (widget.store.newShiftTasks.isNotEmpty) ...[
            SectionLabel(t.newThisShift),
            ...widget.store.newShiftTasks.map((e) => _task(e, t.newLabel, OperonTheme.teal, t)),
          ],
          SectionLabel(t.activityThisShift),
          ...widget.store.currentShiftLogs.map((e) => ListTile(
            leading: Text(hhmm(e.createdAt), style: const TextStyle(color: OperonTheme.muted)),
            title: Text(e.text), subtitle: e.equipmentTag == null ? null : Text(e.equipmentTag!),
          )),
          const SizedBox(height: 18),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(c, MaterialPageRoute(builder: (_) => HandoverScreen(store: widget.store))),
            icon: const Icon(Icons.handshake), label: Text(t.reviewHandover),
          ),
          const SizedBox(height: 8),
          FilledButton.icon(
            onPressed: () { widget.store.endShift(); setState(() {}); },
            icon: const Icon(Icons.stop_circle_outlined), label: Text(t.endShift),
          )
        ]
      ]),
    );
  }

  Widget _summary(ShiftSession s, OperonStrings t) => Card(
    child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('${s.type.name.toUpperCase()} SHIFT', style: const TextStyle(color: OperonTheme.teal, fontWeight: FontWeight.w800)),
      Text(s.operatorName, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)),
      const SizedBox(height: 6),
      Text('${t.started} ${hhmm(s.startedAt)} · ${widget.store.carriedTasks.length} ${t.carried} · ${widget.store.overdueTasks.length} ${t.overdue.toLowerCase()}',
        style: const TextStyle(color: OperonTheme.muted)),
    ])),
  );

  Widget _task(OperatorTask e, String badge, Color color, OperonStrings t) => Card(
    child: ListTile(title: Text(e.title), subtitle: Text(e.equipmentTag ?? t.general),
      trailing: Text(badge, style: TextStyle(color: color, fontSize: 10, fontWeight: FontWeight.w900))),
  );
}
