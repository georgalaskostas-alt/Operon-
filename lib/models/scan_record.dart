enum ScanEntryKind { log, action, watch }

class ScanEntryRecord {
  final String id;
  final ScanEntryKind kind;
  final String text;
  final String? equipmentTag;
  final double tagConfidence;
  final bool approved;
  final String? createdEntityId;

  const ScanEntryRecord({
    required this.id,
    required this.kind,
    required this.text,
    this.equipmentTag,
    this.tagConfidence = 0,
    required this.approved,
    this.createdEntityId,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'kind': kind.name,
        'text': text,
        'equipmentTag': equipmentTag,
        'tagConfidence': tagConfidence,
        'approved': approved,
        'createdEntityId': createdEntityId,
      };

  factory ScanEntryRecord.fromJson(Map<String, dynamic> j) => ScanEntryRecord(
        id: j['id'] ?? '',
        kind: ScanEntryKind.values.firstWhere(
          (e) => e.name == j['kind'],
          orElse: () => ScanEntryKind.log,
        ),
        text: j['text'] ?? '',
        equipmentTag: j['equipmentTag'],
        tagConfidence: (j['tagConfidence'] as num?)?.toDouble() ?? 0,
        approved: j['approved'] ?? false,
        createdEntityId: j['createdEntityId'],
      );
}

class ScanRecord {
  final String id;
  final DateTime createdAt;
  final String imagePath;
  final String rawText;
  final String operatorName;
  final String? shiftId;
  final List<ScanEntryRecord> entries;
  final DateTime? reviewedAt;

  const ScanRecord({
    required this.id,
    required this.createdAt,
    required this.imagePath,
    required this.rawText,
    required this.operatorName,
    this.shiftId,
    this.entries = const [],
    this.reviewedAt,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdAt': createdAt.toIso8601String(),
        'imagePath': imagePath,
        'rawText': rawText,
        'operatorName': operatorName,
        'shiftId': shiftId,
        'entries': entries.map((e) => e.toJson()).toList(),
        'reviewedAt': reviewedAt?.toIso8601String(),
      };

  factory ScanRecord.fromJson(Map<String, dynamic> j) => ScanRecord(
        id: j['id'] ?? '',
        createdAt: DateTime.tryParse(j['createdAt'] ?? '') ?? DateTime.now(),
        imagePath: j['imagePath'] ?? '',
        rawText: j['rawText'] ?? '',
        operatorName: j['operatorName'] ?? '',
        shiftId: j['shiftId'],
        entries: ((j['entries'] as List?) ?? [])
            .map((e) => ScanEntryRecord.fromJson(Map<String, dynamic>.from(e)))
            .toList(),
        reviewedAt: j['reviewedAt'] == null
            ? null
            : DateTime.tryParse(j['reviewedAt']),
      );
}
