import 'package:flutter/material.dart';

import '../localization/app_language.dart';
import '../models/shift_handover.dart';
import '../theme/operon_theme.dart';
import '../widgets/common.dart';

class HandoverDetailScreen extends StatelessWidget {
  final ShiftHandover handover;
  const HandoverDetailScreen({super.key, required this.handover});

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    return Scaffold(
      appBar: AppBar(title: Text(t.handoverDetails)),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 30),
        children: [
          Card(
            margin: const EdgeInsets.all(16),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _line(t.outgoingOperator, handover.outgoingOperator),
                  _line(t.shift, handover.outgoingShift),
                  _line(t.preparedAt, _stamp(handover.createdAt)),
                  _line(t.incomingOperator, handover.incomingOperator ?? t.pending),
                  _line(
                    t.acceptedAtLabel,
                    handover.acceptedAt == null
                        ? t.awaitingAcceptance
                        : _stamp(handover.acceptedAt!),
                  ),
                ],
              ),
            ),
          ),
          _section(t.openActions, handover.openItems),
          _section(t.overdueAtHandover, handover.overdueItems),
          _section(t.carriedAtHandover, handover.carriedItems),
          _section(t.unavailableMaintenance, handover.maintenance),
          _section(t.watchItems, handover.watchItems),
          _section(t.timerReminders, handover.timers),
          _section(t.shiftEvents, handover.shiftEvents),
          SectionLabel(t.handoverNotesSection),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              handover.notes.trim().isEmpty ? '—' : handover.notes,
              style: const TextStyle(color: OperonTheme.muted),
            ),
          ),
        ],
      ),
    );
  }

  Widget _section(String title, List<String> items) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionLabel(title),
          if (items.isEmpty) const ListTile(title: Text('—')),
          ...items.map((item) => ListTile(
                leading: const Icon(Icons.chevron_right, color: OperonTheme.teal),
                title: Text(item),
              )),
        ],
      );

  Widget _line(String label, String value) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text.rich(
          TextSpan(children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.w800),
            ),
            TextSpan(text: value),
          ]),
        ),
      );

  String _stamp(DateTime value) {
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(value.day)}/${two(value.month)}/${value.year} '
        '${two(value.hour)}:${two(value.minute)}';
  }
}
