import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../data/timer_repository.dart';
import '../localization/app_language.dart';
import '../models/models.dart';
import '../models/operator_timer.dart';
import '../theme/operon_theme.dart';
import '../widgets/common.dart';
import 'actions_screen.dart';
import 'scan_notes_screen.dart';
import 'equipment_screen.dart';
import 'handover_screen.dart';
import 'shift_session_screen.dart';
import 'timers_screen.dart';

class DashboardScreen extends StatefulWidget {
  final AppStore store;
  const DashboardScreen({super.key, required this.store});
  @override
  State<DashboardScreen> createState() => _S();
}

class _S extends State<DashboardScreen> {
  List<OperatorTimer> timers = [];

  @override
  void initState() {
    super.initState();
    _timers();
  }

  Future<void> _timers() async {
    timers = await TimerRepository().load();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext c) {
    final t = c.tr;
    final open = widget.store.tasks
        .where((e) => e.state != ActionState.completed)
        .toList();
    final unavailable = widget.store.equipment
        .where((e) =>
            e.state == EquipmentState.maintenance ||
            e.state == EquipmentState.outOfService ||
            e.state == EquipmentState.taggedOut)
        .toList();
    final due = timers.where((e) => e.due).length;

    return RefreshIndicator(
      onRefresh: _timers,
      child: ListView(children: [
        OperonHeader(t.shiftControl, subtitle: t.attentionNow),
        _shiftCard(c),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(t.pick('What do you need to do?', 'Τι θέλεις να κάνεις;'),
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800)),
              const SizedBox(height: 12),
              _primaryAction(
                c,
                icon: Icons.edit_note_rounded,
                title: t.quickEntry,
                subtitle: t.pick('Record a shift observation', 'Κατάγραψε μια παρατήρηση βάρδιας'),
                onTap: () => Navigator.push(
                  c,
                  MaterialPageRoute(builder: (_) => ActionsScreen(store: widget.store)),
                ),
              ),
              const SizedBox(height: 10),
              Row(children: [
                Expanded(child: _compactAction(
                  c, icon: Icons.precision_manufacturing_rounded,
                  title: t.equipment,
                  onTap: () => Navigator.push(c, MaterialPageRoute(
                    builder: (_) => EquipmentScreen(store: widget.store)))),
                ),
                const SizedBox(width: 10),
                Expanded(child: _compactAction(
                  c, icon: Icons.document_scanner_rounded,
                  title: t.scanNotes,
                  onTap: () => Navigator.push(c, MaterialPageRoute(
                    builder: (_) => ScanNotesScreen(store: widget.store)))),
                ),
              ]),
              const SizedBox(height: 10),
              _primaryAction(
                c,
                icon: Icons.handshake_rounded,
                title: t.handoverShort,
                subtitle: t.pick('Prepare or review shift handover', 'Ετοίμασε ή έλεγξε την παράδοση βάρδιας'),
                onTap: () => Navigator.push(c, MaterialPageRoute(
                  builder: (_) => HandoverScreen(store: widget.store))),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(children: [
            _metric(t.open, open.length, Icons.pending_actions),
            const SizedBox(width: 8),
            _metric(t.unavailable, unavailable.length, Icons.build),
            const SizedBox(width: 8),
            _metric(t.timers, timers.where((e) => e.active).length, Icons.timer),
          ]),
        ),
        if (due > 0)
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.notifications_active,
                    color: Colors.orange),
                title: Text(t.timersDue(due),
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(t.openTimersAck),
                onTap: () => Navigator.push(
                  c,
                  MaterialPageRoute(builder: (_) => const TimersScreen()),
                ).then((_) => _timers()),
              ),
            ),
          ),
        SectionLabel(t.needsAttention),
        ...unavailable.map(
          (e) => ListTile(
            leading: const Icon(Icons.precision_manufacturing,
                color: OperonTheme.teal),
            title:
                Text(e.tag, style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle: Text(
                '${e.state.name} · ${e.note.isEmpty ? e.name : e.note}'),
          ),
        ),
        ...open.take(4).map(
              (e) => ListTile(
                leading: const Icon(Icons.pending_actions,
                    color: OperonTheme.teal),
                title: Text(e.title),
                subtitle: Text(e.equipmentTag ?? t.general),
              ),
            ),
        SectionLabel(t.watchlist),
        ...widget.store.watch.where((e) => e.active).take(4).map(
              (e) => ListTile(
                leading:
                    const Icon(Icons.visibility, color: OperonTheme.teal),
                title: Text(e.equipmentTag ?? e.title),
                subtitle: Text('${e.title} · ${e.detail}'),
              ),
            ),
        Padding(
          padding: const EdgeInsets.all(20),
          child: Row(children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: () => Navigator.push(
                  c,
                  MaterialPageRoute(
                      builder: (_) => ActionsScreen(store: widget.store)),
                ),
                icon: const Icon(Icons.pending_actions),
                label: Text(t.actions),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: FilledButton.icon(
                onPressed: () => Navigator.push(
                  c,
                  MaterialPageRoute(
                      builder: (_) => HandoverScreen(store: widget.store)),
                ),
                icon: const Icon(Icons.handshake),
                label: Text(t.handoverShort),
              ),
            ),
          ]),
        ),
        SectionLabel(t.recentLog),
        ...widget.store.logs.take(5).map(
              (e) => ListTile(
                leading: SizedBox(
                  width: 48,
                  child: Text(hhmm(e.createdAt),
                      style: const TextStyle(color: OperonTheme.muted)),
                ),
                title: Text(e.text),
                subtitle:
                    e.equipmentTag == null ? null : Text(e.equipmentTag!),
              ),
            ),
        const SizedBox(height: 100),
      ]),
    );
  }

  Widget _primaryAction(BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) => Card(
    margin: EdgeInsets.zero,
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(children: [
          Icon(icon, color: OperonTheme.teal, size: 30),
          const SizedBox(width: 16),
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800)),
              const SizedBox(height: 3),
              Text(subtitle, style: const TextStyle(color: OperonTheme.muted, fontSize: 13)),
            ],
          )),
          const Icon(Icons.chevron_right_rounded, color: OperonTheme.muted),
        ]),
      ),
    ),
  );

  Widget _compactAction(BuildContext context, {
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) => Card(
    margin: EdgeInsets.zero,
    child: InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 20),
        child: Column(children: [
          Icon(icon, color: OperonTheme.teal, size: 30),
          const SizedBox(height: 8),
          Text(title, textAlign: TextAlign.center,
            style: const TextStyle(fontWeight: FontWeight.w800)),
        ]),
      ),
    ),
  );

  Widget _shiftCard(BuildContext c) {
    final s = widget.store.currentShift;
    final t = c.tr;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 14),
      child: Card(
        child: ListTile(
          onTap: () => Navigator.push(
            c,
            MaterialPageRoute(
                builder: (_) => ShiftSessionScreen(store: widget.store)),
          ),
          leading: Icon(
            s?.active == true
                ? Icons.radio_button_checked
                : Icons.play_circle_outline,
            color: s?.active == true ? OperonTheme.teal : OperonTheme.muted,
          ),
          title: Text(
            s?.active == true
                ? '${s!.type.name.toUpperCase()} SHIFT · ${s.operatorName}'
                : t.noActiveShift,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(s?.active == true
              ? t.startedAt(hhmm(s!.startedAt))
              : t.startOperatorSession),
          trailing: const Icon(Icons.chevron_right),
        ),
      ),
    );
  }

  Widget _metric(String label, int value, IconData icon) => Expanded(
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: OperonTheme.panel,
            borderRadius: BorderRadius.circular(18),
          ),
          child:
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, color: OperonTheme.teal),
            const SizedBox(height: 8),
            Text('$value',
                style:
                    const TextStyle(fontSize: 23, fontWeight: FontWeight.w800)),
            Text(label,
                style:
                    const TextStyle(color: OperonTheme.muted, fontSize: 10)),
          ]),
        ),
      );
}
