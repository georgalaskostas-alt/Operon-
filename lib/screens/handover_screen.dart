import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../data/timer_repository.dart';
import '../localization/app_language.dart';
import '../models/models.dart';
import '../models/operator_timer.dart';
import '../models/shift_handover.dart';
import '../theme/operon_theme.dart';
import '../widgets/common.dart';
import 'handover_detail_screen.dart';

class HandoverScreen extends StatefulWidget {
  final AppStore store;
  const HandoverScreen({super.key, required this.store});
  @override
  State<HandoverScreen> createState() => _S();
}

class _S extends State<HandoverScreen> {
  List<OperatorTimer> timers = [];
  final notes = TextEditingController(), incoming = TextEditingController();

  @override
  void initState() {
    super.initState();
    TimerRepository().load().then((x) {
      if (mounted) setState(() => timers = x);
    });
  }

  @override
  Widget build(BuildContext c) {
    final t = c.tr;
    final open = widget.store.tasks
        .where((x) => x.state != ActionState.completed)
        .toList();
    final maint = widget.store.equipment
        .where((x) =>
            x.state == EquipmentState.maintenance ||
            x.state == EquipmentState.outOfService ||
            x.state == EquipmentState.taggedOut)
        .toList();
    final watch = widget.store.watch.where((x) => x.active).toList();
    final activeTimers = timers.where((x) => x.active).toList();
    final pending = widget.store.pendingHandover;
    final now = DateTime.now();
    final overdue = open.where((x) => x.dueAt != null && x.dueAt!.isBefore(now)).toList();
    final carried = open.where((x) => x.carriedShifts > 0).toList();
    final shiftId = widget.store.currentShift?.id;
    final shiftEvents = shiftId == null
        ? const <String>[]
        : widget.store.auditEvents
            .where((x) => x.shiftId == shiftId && x.type != 'log.created')
            .take(20)
            .map((x) => x.summary)
            .toList();

    return Scaffold(
      appBar: AppBar(title: Text(t.shiftHandover)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 30),
        children: [
          if (pending != null)
            Card(
              margin: const EdgeInsets.all(16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(t.waitingAcceptance,
                          style: const TextStyle(
                              color: OperonTheme.teal,
                              fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(
                          '${pending.outgoingOperator} · ${pending.outgoingShift}'),
                      const SizedBox(height: 12),
                      TextField(
                          controller: incoming,
                          decoration:
                              InputDecoration(labelText: t.incomingOperator)),
                      const SizedBox(height: 10),
                      FilledButton.icon(
                        onPressed: () => _accept(pending),
                        icon: const Icon(Icons.verified),
                        label: Text(t.acceptHandover),
                      )
                    ]),
              ),
            ),
          SectionLabel(t.openActions),
          ...open.map((e) => ListTile(
              title: Text(e.title),
              subtitle: Text(e.equipmentTag ?? t.general))),
          SectionLabel(t.unavailableMaintenance),
          ...maint.map((e) => ListTile(
              title: Text(e.tag),
              subtitle: Text('${e.name} · ${e.state.name}'))),
          SectionLabel(t.watchItems),
          ...watch.map((e) => ListTile(
              title: Text(e.equipmentTag ?? e.title),
              subtitle: Text('${e.title} · ${e.detail}'))),
          SectionLabel(t.overdueAtHandover),
          if (overdue.isEmpty) const ListTile(title: Text('—')),
          ...overdue.map((e) => ListTile(
              leading: const Icon(Icons.warning_amber, color: Colors.orange),
              title: Text(e.title),
              subtitle: Text(e.equipmentTag ?? t.general))),
          SectionLabel(t.carriedAtHandover),
          if (carried.isEmpty) const ListTile(title: Text('—')),
          ...carried.map((e) => ListTile(
              leading: const Icon(Icons.redo, color: OperonTheme.teal),
              title: Text(e.title),
              subtitle: Text('${e.equipmentTag ?? t.general} · ${e.carriedShifts} ${t.carried}'))),
          SectionLabel(t.shiftEvents),
          if (shiftEvents.isEmpty) ListTile(title: Text(t.noShiftEvents)),
          ...shiftEvents.map((e) => ListTile(
              leading: const Icon(Icons.history, color: OperonTheme.teal),
              title: Text(e))),
          SectionLabel(t.timerReminders),
          if (activeTimers.isEmpty) ListTile(title: Text(t.noActiveTimers)),
          ...activeTimers.map((e) => ListTile(
              title: Text(e.title),
              subtitle: Text(
                  '${e.equipmentTag ?? t.general} · ${t.due} ${hhmm(e.dueAt)} · ${e.acknowledged ? t.acknowledged : t.needsAcknowledgement}'))),
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: notes,
              maxLines: 3,
              decoration: InputDecoration(labelText: t.handoverNotes),
            ),
          ),
          if (widget.store.currentShift?.active == true && pending == null)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: FilledButton.icon(
                onPressed: () => _prepare(open, maint, watch, activeTimers, overdue, carried, shiftEvents),
                icon: const Icon(Icons.handshake),
                label: Text(t.prepareHandover),
              ),
            ),
          SectionLabel(t.handoverHistory),
          ...widget.store.handovers.take(8).map(
                (h) => ListTile(
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => HandoverDetailScreen(handover: h),
                    ),
                  ),
                  leading: Icon(h.accepted ? Icons.verified : Icons.schedule,
                      color: h.accepted ? OperonTheme.teal : Colors.orange),
                  title: Text(
                      '${h.outgoingOperator} → ${h.incomingOperator ?? t.pending}'),
                  subtitle: Text(
                    '${h.outgoingShift} · ${h.accepted ? '${t.accepted} ${hhmm(h.acceptedAt!)}' : t.awaitingAcceptance}',
                  ),
                  trailing: const Icon(Icons.chevron_right),
                ),
              )
        ],
      ),
    );
  }

  void _prepare(List<OperatorTask> open, List<Equipment> maint,
      List<WatchItem> watch, List<OperatorTimer> ts, List<OperatorTask> overdue,
      List<OperatorTask> carried, List<String> shiftEvents) {
    final s = widget.store.currentShift!;
    final t = context.tr;
    widget.store.saveHandover(
      ShiftHandover(
        id: DateTime.now().microsecondsSinceEpoch.toString(),
        createdAt: DateTime.now(),
        outgoingOperator: s.operatorName,
        outgoingShift: s.type.name,
        openItems:
            open.map((e) => '${e.equipmentTag ?? t.general} · ${e.title}').toList(),
        maintenance:
            maint.map((e) => '${e.tag} · ${e.state.name}').toList(),
        watchItems: watch
            .map((e) => '${e.equipmentTag ?? t.general} · ${e.detail}')
            .toList(),
        timers:
            ts.map((e) => '${e.equipmentTag ?? t.general} · ${e.title}').toList(),
        overdueItems:
            overdue.map((e) => '${e.equipmentTag ?? t.general} · ${e.title}').toList(),
        carriedItems:
            carried.map((e) => '${e.equipmentTag ?? t.general} · ${e.title}').toList(),
        shiftEvents: shiftEvents,
        notes: notes.text.trim(),
      ),
    );
    setState(() {});
  }

  Future<void> _accept(ShiftHandover h) async {
    if (incoming.text.trim().isEmpty) return;
    final t = context.tr;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(t.handoverAcknowledgement),
        content: Text(
          t.pick(
            'Confirm that you reviewed the recorded handover snapshot and are accepting receipt. This records your acknowledgement only; it does not verify plant state or field conditions.',
            'Επιβεβαίωσε ότι έλεγξες το καταγεγραμμένο στιγμιότυπο παράδοσης και αποδέχεσαι την παραλαβή. Καταγράφεται μόνο η επιβεβαίωσή σου· δεν επαληθεύεται η κατάσταση της μονάδας ή οι συνθήκες πεδίου.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(t.cancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(t.confirmHandoverAcceptance),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    final statement = t.pick(
      'Incoming operator reviewed the recorded handover snapshot and acknowledged receipt.',
      'Ο παραλαμβάνων χειριστής έλεγξε το καταγεγραμμένο στιγμιότυπο παράδοσης και επιβεβαίωσε την παραλαβή.',
    );
    widget.store.acceptHandover(
      h,
      incoming.text,
      acknowledgement: statement,
    );
    setState(() {});
  }
}
