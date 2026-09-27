import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../localization/app_language.dart';
import '../models/models.dart';
import '../theme/operon_theme.dart';

enum _TimelineKind { state, log, action, watch, note, scan, audit }

class EquipmentTimelineScreen extends StatefulWidget {
  final AppStore store;
  final Equipment equipment;
  const EquipmentTimelineScreen({
    super.key,
    required this.store,
    required this.equipment,
  });

  @override
  State<EquipmentTimelineScreen> createState() => _EquipmentTimelineScreenState();
}

class _EquipmentTimelineScreenState extends State<EquipmentTimelineScreen> {
  _TimelineKind? filter;

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final all = _events(t);
    final events = filter == null ? all : all.where((e) => e.kind == filter).toList();

    return Scaffold(
      appBar: AppBar(title: Text('${widget.equipment.tag} · ${t.equipmentTimeline}')),
      body: Column(
        children: [
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                _chip(t.timelineAll, null),
                _chip(t.timelineStates, _TimelineKind.state),
                _chip(t.timelineLogs, _TimelineKind.log),
                _chip(t.timelineActions, _TimelineKind.action),
                _chip(t.timelineWatch, _TimelineKind.watch),
                _chip(t.timelineNotes, _TimelineKind.note),
                _chip(t.timelineScans, _TimelineKind.scan),
              ],
            ),
          ),
          Expanded(
            child: events.isEmpty
                ? Center(child: Text(t.noEquipmentActivity))
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: events.length,
                    itemBuilder: (_, i) => _TimelineCard(event: events[i]),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, _TimelineKind? value) => Padding(
        padding: const EdgeInsets.only(right: 8),
        child: ChoiceChip(
          label: Text(label),
          selected: filter == value,
          onSelected: (_) => setState(() => filter = value),
        ),
      );

  List<_EquipmentEvent> _events(OperonStrings t) {
    final tag = widget.equipment.tag;
    final store = widget.store;
    final result = <_EquipmentEvent>[];

    for (final x in store.logs.where((x) => x.equipmentTag == tag)) {
      result.add(_EquipmentEvent(
        at: x.createdAt,
        kind: _TimelineKind.log,
        title: t.logEvent,
        detail: x.text,
        source: x.source,
        icon: Icons.receipt_long,
      ));
    }

    for (final x in store.tasks.where((x) => x.equipmentTag == tag)) {
      result.add(_EquipmentEvent(
        at: x.createdAt,
        kind: _TimelineKind.action,
        title: t.actionEvent,
        detail: '${x.title} · ${x.state.name}',
        source: x.createdShiftId == null ? 'action' : 'shift ${x.createdShiftId}',
        icon: Icons.pending_actions,
      ));
    }

    for (final x in store.watch.where((x) => x.equipmentTag == tag)) {
      final created = store.auditEvents
          .where((a) => a.entityId == x.id && a.type == 'watch.created')
          .map((a) => a.createdAt)
          .firstOrNull;
      result.add(_EquipmentEvent(
        at: created ?? DateTime.fromMillisecondsSinceEpoch(0),
        kind: _TimelineKind.watch,
        title: t.watchEvent,
        detail: '${x.title}\n${x.detail}',
        source: x.active ? 'watch' : 'resolved',
        icon: Icons.visibility,
      ));
    }

    for (final x in store.notes.where((x) => x.equipmentTag == tag)) {
      result.add(_EquipmentEvent(
        at: x.createdAt,
        kind: _TimelineKind.note,
        title: t.noteEvent,
        detail: '${x.title}\n${x.body}',
        source: x.resolved ? 'resolved' : 'note',
        icon: Icons.note_alt_outlined,
      ));
    }

    for (final scan in store.scanRecords) {
      final entries = scan.entries.where(
        (e) => e.approved && e.equipmentTag == tag,
      );
      for (final entry in entries) {
        result.add(_EquipmentEvent(
          at: scan.reviewedAt ?? scan.createdAt,
          kind: _TimelineKind.scan,
          title: t.scanEvent,
          detail: entry.text,
          source: 'scan ${scan.id}',
          icon: Icons.document_scanner,
        ));
      }
    }

    for (final x in store.auditEvents.where((x) => x.equipmentTag == tag)) {
      if (x.type == 'log.created' ||
          x.type == 'action.created' ||
          x.type == 'watch.created' ||
          x.type == 'note.created') {
        continue;
      }
      final isState = x.type == 'equipment.state_changed';
      result.add(_EquipmentEvent(
        at: x.createdAt,
        kind: isState ? _TimelineKind.state : _TimelineKind.audit,
        title: isState ? t.stateChange : t.auditEvent,
        detail: x.summary,
        source: x.source,
        icon: isState ? Icons.swap_horiz : Icons.verified_user_outlined,
      ));
    }

    result.sort((a, b) => b.at.compareTo(a.at));
    return result;
  }
}

class _EquipmentEvent {
  final DateTime at;
  final _TimelineKind kind;
  final String title, detail, source;
  final IconData icon;
  const _EquipmentEvent({
    required this.at,
    required this.kind,
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
          title: Text(
            event.title,
            style: const TextStyle(fontWeight: FontWeight.w800),
          ),
          subtitle: Text(
            '${event.detail}\n${_stamp(event.at)} · ${event.source}',
          ),
          isThreeLine: true,
        ),
      );
}

String _stamp(DateTime value) {
  if (value.millisecondsSinceEpoch == 0) return '—';
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(value.day)}/${two(value.month)}/${value.year} '
      '${two(value.hour)}:${two(value.minute)}';
}
