import 'dart:async';
import 'package:flutter/material.dart';
import '../data/timer_repository.dart';
import '../localization/app_language.dart';
import '../models/operator_timer.dart';
import '../services/notification_service.dart';
import '../theme/operon_theme.dart';

class TimersScreen extends StatefulWidget {
  const TimersScreen({super.key});
  @override
  State<TimersScreen> createState() => _S();
}

class _S extends State<TimersScreen> {
  final timers = <OperatorTimer>[];
  Timer? tick;
  final repo = TimerRepository();

  @override
  void initState() {
    super.initState();
    _load();
    NotificationService.instance.requestPermissions();
    tick = Timer.periodic(const Duration(seconds: 1), (_) => _pulse());
  }

  @override
  void dispose() {
    tick?.cancel();
    super.dispose();
  }

  Future<void> _load() async {
    timers
      ..clear()
      ..addAll(await repo.load());
    for (final timer in timers.where((x) => x.active && !x.due)) {
      await NotificationService.instance.scheduleTimer(
        timer.id,
        timer.title,
        timer.equipmentTag,
        timer.dueAt,
      );
    }
    if (mounted) setState(() {});
  }

  Future<void> _save() => repo.save(timers);

  void _pulse() {
    var dirty = false;
    for (final t in timers.where((x) => x.due && !x.notificationSent)) {
      t.notificationSent = true;
      NotificationService.instance.showDue(t.id, t.title, t.equipmentTag);
      dirty = true;
    }
    if (dirty) _save();
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext c) {
    final tr = c.tr;
    final active = timers.where((x) => x.active).toList();
    final done = timers.where((x) => x.completed).toList();
    return Scaffold(
      appBar: AppBar(title: Text(tr.timersReminders)),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          if (active.isEmpty) ListTile(title: Text(tr.noActiveTimers)),
          ...active.map(_card),
          if (done.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(8, 20, 8, 6),
              child: Text(tr.completed,
                  style: const TextStyle(
                      color: OperonTheme.muted,
                      fontWeight: FontWeight.w800,
                      fontSize: 11)),
            ),
            ...done.take(10).map(
                  (timer) => ListTile(
                    leading: const Icon(Icons.check_circle,
                        color: OperonTheme.muted),
                    title: Text(timer.title),
                    subtitle: Text(timer.equipmentTag ?? tr.general),
                  ),
                )
          ]
        ],
      ),
      floatingActionButton:
          FloatingActionButton(onPressed: _add, child: const Icon(Icons.add_alarm)),
    );
  }

  Widget _card(OperatorTimer timer) {
    final tr = context.tr;
    final left = timer.dueAt.difference(DateTime.now());
    final status = timer.due
        ? (timer.acknowledged ? tr.dueAck : tr.dueNeedsAck)
        : '${left.inMinutes}m ${left.inSeconds % 60}s ${tr.remaining}';
    final snooze =
        timer.snoozeCount > 0 ? ' · ${tr.snoozed} ×${timer.snoozeCount}' : '';

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(children: [
          ListTile(
            leading: Icon(
              timer.due ? Icons.notifications_active : Icons.timer,
              color: timer.due ? Colors.orange : OperonTheme.teal,
            ),
            title: Text(timer.title,
                style: const TextStyle(fontWeight: FontWeight.w800)),
            subtitle:
                Text('${timer.equipmentTag ?? tr.general} · $status$snooze'),
          ),
          if (timer.due)
            Wrap(spacing: 6, children: [
              if (!timer.acknowledged)
                TextButton.icon(
                  onPressed: () {
                    timer.acknowledge();
                    NotificationService.instance.cancelTimer(timer.id);
                    _save();
                    setState(() {});
                  },
                  icon: const Icon(Icons.visibility),
                  label: Text(tr.acknowledge),
                ),
              TextButton(onPressed: () => _snooze(timer, 5), child: const Text('+5m')),
              TextButton(onPressed: () => _snooze(timer, 15), child: const Text('+15m')),
              FilledButton.icon(
                onPressed: () {
                  timer.complete();
                  NotificationService.instance.cancelTimer(timer.id);
                  _save();
                  setState(() {});
                },
                icon: const Icon(Icons.check),
                label: Text(tr.complete),
              )
            ])
        ]),
      ),
    );
  }

  void _snooze(OperatorTimer timer, int minutes) {
    timer.snooze(Duration(minutes: minutes));
    NotificationService.instance.scheduleTimer(
      timer.id,
      timer.title,
      timer.equipmentTag,
      timer.dueAt,
    );
    _save();
    setState(() {});
  }

  void _add() {
    final tr = context.tr;
    final name = TextEditingController(text: tr.check);
    final tag = TextEditingController();
    int minutes = 30;
    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (c, setDialogState) => AlertDialog(
          title: Text(tr.newOperatorTimer),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            TextField(
                controller: name,
                decoration: InputDecoration(labelText: tr.reminder)),
            const SizedBox(height: 8),
            TextField(
                controller: tag,
                decoration: InputDecoration(labelText: tr.equipmentTagOptional)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: [5, 10, 15, 30, 60]
                  .map((m) => ChoiceChip(
                        label: Text('${m}m'),
                        selected: minutes == m,
                        onSelected: (_) => setDialogState(() => minutes = m),
                      ))
                  .toList(),
            )
          ]),
          actions: [
            FilledButton(
              onPressed: () {
                final now = DateTime.now();
                final timer = OperatorTimer(
                  id: now.millisecondsSinceEpoch.remainder(2147483647),
                  title: name.text.trim().isEmpty ? tr.check : name.text.trim(),
                  equipmentTag: tag.text.trim().isEmpty
                      ? null
                      : tag.text.trim().toUpperCase(),
                  createdAt: now,
                  dueAt: now.add(Duration(minutes: minutes)),
                );
                timers.insert(0, timer);
                NotificationService.instance.scheduleTimer(
                  timer.id,
                  timer.title,
                  timer.equipmentTag,
                  timer.dueAt,
                );
                _save();
                Navigator.pop(c);
                setState(() {});
              },
              child: Text(tr.startTimer),
            )
          ],
        ),
      ),
    );
  }
}
