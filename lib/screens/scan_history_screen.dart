import 'dart:io';

import 'package:flutter/material.dart';

import '../data/app_store.dart';
import '../localization/app_language.dart';
import '../models/scan_record.dart';
import '../theme/operon_theme.dart';

class ScanHistoryScreen extends StatelessWidget {
  final AppStore store;
  const ScanHistoryScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    return Scaffold(
      appBar: AppBar(title: Text(t.scanHistory)),
      body: store.scanRecords.isEmpty
          ? Center(child: Text(t.noScanHistory))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: store.scanRecords.length,
              itemBuilder: (c, i) {
                final scan = store.scanRecords[i];
                final approved = scan.entries.where((e) => e.approved).length;
                return Card(
                  child: ListTile(
                    onTap: () => Navigator.push(
                      c,
                      MaterialPageRoute(
                        builder: (_) => ScanHistoryDetailScreen(scan: scan),
                      ),
                    ),
                    leading: const Icon(
                      Icons.document_scanner,
                      color: OperonTheme.teal,
                    ),
                    title: Text(
                      scan.operatorName.isEmpty
                          ? t.unknownOperator
                          : scan.operatorName,
                      style: const TextStyle(fontWeight: FontWeight.w800),
                    ),
                    subtitle: Text(
                      '${_stamp(scan.createdAt)} · $approved/${scan.entries.length} ${t.approvedEntries}',
                    ),
                    trailing: const Icon(Icons.chevron_right),
                  ),
                );
              },
            ),
    );
  }
}

class ScanHistoryDetailScreen extends StatelessWidget {
  final ScanRecord scan;
  const ScanHistoryDetailScreen({super.key, required this.scan});

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final imageFile = scan.imagePath.isEmpty ? null : File(scan.imagePath);
    final imageExists = imageFile?.existsSync() ?? false;

    return Scaffold(
      appBar: AppBar(title: Text(t.scanDetails)),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock_clock, color: OperonTheme.teal),
              title: Text(t.readOnlyHistory),
              subtitle: Text(
                '${_stamp(scan.createdAt)} · ${scan.operatorName.isEmpty ? t.unknownOperator : scan.operatorName}',
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(t.originalPhoto,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          if (imageExists)
            ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(
                imageFile!,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _missingPhoto(t),
              ),
            )
          else
            _missingPhoto(t),
          const SizedBox(height: 18),
          Text(t.rawOcrText,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SelectableText(
                scan.rawText.isEmpty ? t.noRecognizedText : scan.rawText,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(t.reviewedEntries,
              style:
                  const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
          const SizedBox(height: 8),
          ...scan.entries.map((e) => _entryCard(t, e)),
          const SizedBox(height: 18),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: DefaultTextStyle(
                style: const TextStyle(color: OperonTheme.muted),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${t.scanId}: ${scan.id}'),
                    Text('${t.shiftId}: ${scan.shiftId ?? '—'}'),
                    Text(
                      '${t.reviewedAt}: ${scan.reviewedAt == null ? '—' : _stamp(scan.reviewedAt!)}',
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _entryCard(OperonStrings t, ScanEntryRecord e) {
    final status = e.approved ? t.approved : t.rejected;
    final statusColor = e.approved ? OperonTheme.teal : Colors.orange;
    return Card(
      child: ListTile(
        leading: Icon(
          e.approved ? Icons.check_circle : Icons.cancel_outlined,
          color: statusColor,
        ),
        title: Text(e.text),
        subtitle: Text(
          '${_kindLabel(t, e.kind)} · ${e.equipmentTag ?? t.noEquipmentTag}\n'
          '${t.tagConfidence}: ${(e.tagConfidence * 100).round()}% · '
          '${e.createdEntityId == null ? t.noLinkedRecord : '${t.linkedRecord}: ${e.createdEntityId}'}',
        ),
        isThreeLine: true,
        trailing: Text(
          status,
          style: TextStyle(
            color: statusColor,
            fontSize: 10,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }

  Widget _missingPhoto(OperonStrings t) => Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              const Icon(Icons.broken_image_outlined, color: Colors.orange),
              const SizedBox(width: 12),
              Expanded(child: Text(t.originalPhotoUnavailable)),
            ],
          ),
        ),
      );
}

String _kindLabel(OperonStrings t, ScanEntryKind kind) {
  switch (kind) {
    case ScanEntryKind.log:
      return t.logEntry;
    case ScanEntryKind.action:
      return t.actionEntry;
    case ScanEntryKind.watch:
      return t.watchEntry;
  }
}

String _stamp(DateTime value) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${two(value.day)}/${two(value.month)}/${value.year} '
      '${two(value.hour)}:${two(value.minute)}';
}
