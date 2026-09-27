import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../localization/app_language.dart';
import '../models/scan_record.dart';
import '../services/note_ocr_service.dart';
import '../services/note_interpreter.dart';
import '../theme/operon_theme.dart';
import 'scan_history_screen.dart';

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
        if (widget.store.scanRecords.isNotEmpty) ...[
          const SizedBox(height: 8),
          OutlinedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ScanHistoryScreen(store: widget.store),
              ),
            ),
            icon: const Icon(Icons.history),
            label: Text(t.scanHistory),
          ),
        ],
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
            (d) => Card(
              child: Column(
                children: [
                  CheckboxListTile(
                    value: d.selected,
                    onChanged: (v) =>
                        setState(() => d.selected = v ?? false),
                    title: Text(d.text),
                    subtitle: Text(
                      '${_kindLabel(t, d.kind)} · ${d.tag ?? t.noMatchedTag}',
                    ),
                    secondary: d.tagConfidence < .9
                        ? const Icon(Icons.warning_amber, color: Colors.orange)
                        : const Icon(Icons.verified, color: OperonTheme.teal),
                  ),
                  if (d.tagConfidence < .9)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
                      child: Row(
                        children: [
                          const Icon(Icons.warning_amber,
                              size: 16, color: Colors.orange),
                          const SizedBox(width: 6),
                          Expanded(
                            child: Text(
                              '${t.lowConfidence} · ${d.tag == null ? t.operatorReviewRequired : '${t.checkTag} ${(d.tagConfidence * 100).round()}%'}',
                              style: const TextStyle(
                                color: Colors.orange,
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton.icon(
                      onPressed: () => _reviewDraft(d),
                      icon: const Icon(Icons.tune),
                      label: Text(t.reviewEntry),
                    ),
                  ),
                ],
              ),
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

  String _kindLabel(OperonStrings t, DraftKind kind) {
    switch (kind) {
      case DraftKind.log:
        return t.logEntry;
      case DraftKind.action:
        return t.actionEntry;
      case DraftKind.watch:
        return t.watchEntry;
    }
  }

  Future<void> _reviewDraft(ScanDraft draft) async {
    final t = context.tr;
    final textController = TextEditingController(text: draft.text);
    var kind = draft.kind;
    var tag = draft.tag ?? '';

    await showDialog<void>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (c, setDialogState) => AlertDialog(
          title: Text(t.reviewEntry),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: textController,
                  minLines: 2,
                  maxLines: 5,
                  decoration: InputDecoration(labelText: t.entryText),
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<DraftKind>(
                  initialValue: kind,
                  decoration: InputDecoration(labelText: t.entryType),
                  items: DraftKind.values
                      .map(
                        (x) => DropdownMenuItem(
                          value: x,
                          child: Text(_kindLabel(t, x)),
                        ),
                      )
                      .toList(),
                  onChanged: (v) {
                    if (v != null) setDialogState(() => kind = v);
                  },
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: tag,
                  decoration: InputDecoration(labelText: t.equipmentTag),
                  items: [
                    DropdownMenuItem(
                      value: '',
                      child: Text(t.noEquipmentTag),
                    ),
                    ...widget.store.equipment.map(
                      (e) => DropdownMenuItem(
                        value: e.tag,
                        child: Text('${e.tag} · ${e.name}'),
                      ),
                    ),
                  ],
                  onChanged: (v) =>
                      setDialogState(() => tag = v ?? ''),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(c),
              child: Text(t.cancel),
            ),
            FilledButton(
              onPressed: textController.text.trim().isEmpty
                  ? null
                  : () {
                      setState(() {
                        draft.text = textController.text.trim();
                        draft.kind = kind;
                        draft.tag = tag.isEmpty ? null : tag;
                        draft.tagConfidence = tag.isEmpty ? 0 : 1;
                      });
                      Navigator.pop(c);
                    },
              child: Text(t.updateEntry),
            ),
          ],
        ),
      ),
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
