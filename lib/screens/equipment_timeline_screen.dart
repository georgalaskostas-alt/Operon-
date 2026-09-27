import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../localization/app_language.dart';
import '../models/models.dart';
import '../theme/operon_theme.dart';

class EquipmentTimelineScreen extends StatelessWidget {
  final AppStore store;
  final Equipment equipment;
  const EquipmentTimelineScreen({
    super.key,
    required this.store,
    required this.equipment,
  });

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final events = _events(t);
    return Scaffold(
      appBar: AppBar(title: Text('${equipment.tag} · ${t.equipmentTimeline}')),
      body: events.isEmpty
          ? Center(child: Text(t.noEquipmentActivity))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: events.length,
              itemBuilder: (_, i) => _TimelineCard(event: events[i]),
            ),
    );
  }

  List<_EquipmentEvent> _events(OperonStrings t) {
    final tag = equipment.tag;
    final result = <_EquipmentEvent>[];

    for (final x in store.logs.where((x) => x.equipmentTag == tag)) {
      result.add(_EquipmentEvent(
        at: x.createdAt,
        title: t.logEvent,
        detail: x.text,
        source: x.source,
        icon: Icons.receipt_long,
      ));
    }
    for (final x in store.tasks.where((x) => x.equipmentTag == tag)) {
      result.add(_EquipmentEvent(
        at: x.createdAt,
        title: t.actionEvent,
        detail: '${x.title} · ${x.state.name}',
        source: x.createdShiftId == null ? 'action' : 'shift ${x.createdShiftId}',
        icon: Icons.pending_actions,
      ));
    }
    for (final x in store.notes.where((x) => x.equipmentTag == tag)) {
      result.add(_EquipmentEvent(
        at: x.createdAt,
        title: t.noteEvent,
        detail: '${x.title}\n${x.body}',
        source: x.resolved ? 'resolved' : 'note',
        icon: Icons.note_alt_outlined,
      ));
    }
    for (final x in store.auditEvents.where((x) => x.equipmentTag == tag)) {
      if (x.type == 'log.created' || x.type == 'action.created' || x.type == 'note.created') {
        continue;
      }
      result.add(_EquipmentEvent(
        at: x.createdAt,
        title: x.type == 'equipment.state_changed' ? t.stateChange : t.auditEvent,
        detail: x.summary,
        source: x.source,
        icon: x.type == 'equipment.state_changed'
            ? Icons.swap_horiz
            : Icons.verified_user_outlined,
      ));
    }

    result.sort((a, b) => b.at.compareTo(a.at));
    return result;
  }
}

class _EquipmentEvent {
  final DateTime at;
  final String title, detail, source;
  final IconData icon;
  const _EquipmentEvent({
    required this.at,
    required this.title,
    required this.detail,
    required this.source,
    required this.icon,
  });
}

class _TimelineCard extends StatelessWidget {
  final _EquipmentEvent event;
  const _TimelineCard({required this.event});

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          leading: Icon(event.icon, color: OperonTheme.teal),
          title: Text(event.title, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text('${event.detail}\n${_stamp(event.at)} · ${event.source}'),
          isThreeLine: true,
        ),
      );
}

String _stamp(DateTime value) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(value.day)}/${two(value.month)}/${value.year} '
      '${two(value.hour)}:${two(value.minute)}';
}
