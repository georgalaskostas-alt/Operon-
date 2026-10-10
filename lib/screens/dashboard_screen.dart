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
  final VoidCallback? onQuickEntry;
  const DashboardScreen({super.key, required this.store, this.onQuickEntry});
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
        _industrialHero(c),
        _shiftCard(c),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
          child: Row(children: [
            Expanded(child: _tile(c, Icons.edit_note_rounded, t.pick('Entry', 'Καταχώριση'),
              widget.onQuickEntry ?? () => Navigator.push(c, MaterialPageRoute(
                builder: (_) => ActionsScreen(store: widget.store))))),
            const SizedBox(width: 10),
            Expanded(child: _tile(c, Icons.document_scanner_rounded, t.pick('Scan', 'Σάρωση'),
              () => Navigator.push(c, MaterialPageRoute(
                builder: (_) => ScanNotesScreen(store: widget.store))))),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 8),
          child: Row(children: [
            Expanded(child: _tile(c, Icons.precision_manufacturing_rounded, t.equipment,
              () => Navigator.push(c, MaterialPageRoute(
                builder: (_) => EquipmentScreen(store: widget.store))))),
            const SizedBox(width: 10),
            Expanded(child: _tile(c, Icons.handshake_rounded, t.handoverShort,
              () => Navigator.push(c, MaterialPageRoute(
                builder: (_) => HandoverScreen(store: widget.store))))),
          ]),
        ),
        if (due > 0)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Card(
              color: const Color(0xFF2C2630),
              child: ListTile(
                leading: const Icon(Icons.warning_amber_rounded, color: Color(0xFFFF7684)),
                title: Text(t.timersDue(due),
                  style: const TextStyle(fontWeight: FontWeight.w800)),
                subtitle: Text(t.openTimersAck),
                trailing: const Icon(Icons.chevron_right),
                onTap: () => Navigator.push(c, MaterialPageRoute(
                  builder: (_) => const TimersScreen())).then((_) => _timers()),
              ),
            ),
          ),
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
          child: Row(children: [
            _metric(t.open, open.length, Icons.pending_actions),
            const SizedBox(width: 8),
            _metric(t.unavailable, unavailable.length, Icons.build),
            const SizedBox(width: 8),
            _metric(t.timers, timers.where((e) => e.active).length, Icons.timer),
          ]),
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

  Widget _industrialHero(BuildContext c) {
    final t = c.tr;
    return Container(
      height: 225,
      margin: const EdgeInsets.fromLTRB(20, 14, 20, 12),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          begin: Alignment.topLeft, end: Alignment.bottomRight,
          colors: [Color(0xFF102F48), Color(0xFF06111D)]),
      ),
      child: Stack(children: [
        Positioned.fill(child: Image.asset('assets/images/operon_refinery_hero.jpg', fit: BoxFit.cover, alignment: Alignment.center)),
        Positioned.fill(child: DecoratedBox(decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter, end: Alignment.bottomCenter,
            colors: [const Color(0x4206111D), const Color(0xF006111D)])))),
        Padding(
          padding: const EdgeInsets.all(22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Text('O P E R O N', style: TextStyle(
              color: OperonTheme.teal, fontWeight: FontWeight.w900, letterSpacing: 2)),
            const Spacer(),
            Text(t.pick('Welcome to your shift', 'Καλώς ήρθες στη βάρδια'),
              style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w900)),
            const SizedBox(height: 5),
            Text(t.pick('Record • Monitor • Handover',
                'Καταχώριση • Παρακολούθηση • Παράδοση'),
              style: const TextStyle(color: Color(0xFFBED1DF), fontSize: 13)),
          ]),
        ),
      ]),
    );
  }

  Widget _tile(BuildContext c, IconData icon, String title, VoidCallback onTap) =>
    Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: SizedBox(
          height: 104,
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icon, size: 34, color: OperonTheme.teal),
            const SizedBox(height: 13),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: Text(title, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
            ),
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

