import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../localization/app_language.dart';
import '../models/scan_record.dart';
import '../services/note_ocr_service.dart';
import '../services/note_interpreter.dart';
import '../theme/operon_theme.dart';

class ScanNotesScreen extends StatefulWidget {
  final AppStore store;
  const ScanNotesScreen({super.key, required this.store});
  @override
  State<ScanNotesScreen> createState() => _S();
}

class _S extends State<ScanNotesScreen> {
  final ocr = NoteOcrService(), interpreter = NoteInterpreter();
  String raw = '';
  List<ScanDraft> drafts = [];
  bool busy = false;
  String imagePath = '';
  DateTime? scannedAt;

  @override
  Widget build(BuildContext c) {
    final t = c.tr;
    return Scaffold(
      appBar: AppBar(title: Text(t.scanHandwrittenTitle)),
      body: ListView(padding: const EdgeInsets.all(16), children: [
        Card(
          child: ListTile(
            leading:
                const Icon(Icons.document_scanner, color: OperonTheme.teal),
            title: Text(t.ocrReview),
            subtitle: Text(t.ocrSafety),
          ),
        ),
        FilledButton.icon(
          onPressed: busy ? null : _scan,
          icon: const Icon(Icons.camera_alt),
          label: Text(busy ? t.reading : t.photographNote),
        ),
        if (raw.isNotEmpty) ...[
          const SizedBox(height: 16),
          TextField(
            controller: TextEditingController(text: raw),
            maxLines: 7,
            readOnly: true,
            decoration: InputDecoration(labelText: t.recognizedText),
          ),
          const SizedBox(height: 16),
          Text(t.proposedEntries,
              style:
                  const TextStyle(fontWeight: FontWeight.w800, fontSize: 18)),
          ...drafts.map(
            (d) => CheckboxListTile(
              value: d.selected,
              onChanged: (v) => setState(() => d.selected = v ?? false),
              title: Text(d.text),
              subtitle: Text(
                  '${d.kind.name.toUpperCase()} · ${d.tag ?? t.noMatchedTag}${d.tag != null && d.tagConfidence < .9 ? ' · ${t.checkTag} ${(d.tagConfidence * 100).round()}%' : ''}'),
            ),
          ),
          FilledButton.icon(
            onPressed: _commit,
            icon: const Icon(Icons.verified_user),
            label: Text(t.confirmSelected),
          )
        ]
      ]),
    );
  }

  Future<void> _scan() async {
    setState(() => busy = true);
    try {
      final r = await ocr.scan();
      if (r == null) return;
      setState(() {
        raw = r.text;
        imagePath = r.imagePath;
        scannedAt = DateTime.now();
        drafts = interpreter.interpret(raw, widget.store.equipment);
      });
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  void _commit() {
    final t = context.tr;
    final scanId = DateTime.now().microsecondsSinceEpoch.toString();
    final entries = <ScanEntryRecord>[];

    for (var i = 0; i < drafts.length; i++) {
      final d = drafts[i];
      String? entityId;
      if (d.selected) {
        switch (d.kind) {
          case DraftKind.log:
            entityId = widget.store.addScannedLog(
              d.text,
              tag: d.tag,
              scanId: scanId,
            );
          case DraftKind.action:
            entityId = widget.store.addScannedTask(
              d.text,
              tag: d.tag,
              scanId: scanId,
            );
          case DraftKind.watch:
            entityId = widget.store.addScannedWatch(
              t.scannedWatchItem,
              d.text,
              tag: d.tag,
              scanId: scanId,
            );
        }
      }
      entries.add(
        ScanEntryRecord(
          id: '${scanId}_$i',
          kind: ScanEntryKind.values.byName(d.kind.name),
          text: d.text,
          equipmentTag: d.tag,
          tagConfidence: d.tagConfidence,
          approved: d.selected,
          createdEntityId:
              entityId == null || entityId.isEmpty ? null : entityId,
        ),
      );
    }

    widget.store.saveScanRecord(
      ScanRecord(
        id: scanId,
        createdAt: scannedAt ?? DateTime.now(),
        imagePath: imagePath,
        rawText: raw,
        operatorName: widget.store.currentShift?.operatorName ?? 'Operator',
        shiftId: widget.store.currentShift?.id,
        entries: entries,
        reviewedAt: DateTime.now(),
      ),
    );
    Navigator.pop(context);
  }
}
