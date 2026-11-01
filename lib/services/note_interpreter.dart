import '../models/models.dart';

enum DraftKind { log, action, watch }

class ScanDraft {
  DraftKind kind;
  String text;
  String? tag;
  double tagConfidence;
  bool selected;
  bool operatorConfirmedTag;

  ScanDraft(
    this.kind,
    this.text, {
    this.tag,
    this.tagConfidence = 0,
    this.selected = true,
    this.operatorConfirmedTag = false,
  });
}

class _Match {
  final String? tag;
  final double confidence;
  const _Match(this.tag, this.confidence);
}

class NoteInterpreter {
  List<ScanDraft> interpret(String raw, List<Equipment> equipment) {
    final drafts = <ScanDraft>[];
    for (final source in raw.split(RegExp(r'[\n;]+'))) {
      final line = source.trim();
      if (line.isEmpty) continue;
      final m = _matchTag(line, equipment), low = line.toLowerCase();
      final kind = (low.contains('check') ||
              low.contains('έλεγχ') ||
              low.contains('να ') ||
              low.contains('pending') ||
              low.contains('εκκρεμ'))
          ? DraftKind.action
          : (low.contains('monitor') ||
                  low.contains('watch') ||
                  low.contains('παρακολ') ||
                  low.contains('πρόσεχε'))
              ? DraftKind.watch
              : DraftKind.log;
      drafts.add(
        ScanDraft(
          kind,
          line,
          tag: m.tag,
          tagConfidence: m.confidence,
        ),
      );
    }
    return drafts;
  }

  _Match _matchTag(String line, List<Equipment> equipment) {
    final tags = equipment
        .map((e) => e.tag)
        .where((tag) => tag.isNotEmpty)
        .toSet()
        .toList();
    if (tags.isEmpty) return const _Match(null, 0);

    final tokens = line
        .toUpperCase()
        .split(RegExp(r'[^A-Z0-9-]+'))
        .map(_norm)
        .where((token) => token.length >= 4)
        .toSet();

    final exact = tags
        .where((tag) => tokens.contains(_norm(tag)))
        .toList();
    if (exact.length == 1) return _Match(exact.single, 1);
    if (exact.length > 1) return const _Match(null, 0);

    final scores = <String, double>{};
    for (final tag in tags) {
      final normalizedTag = _norm(tag);
      if (normalizedTag.length < 4) continue;
      var best = 0.0;
      for (final token in tokens) {
        final length = token.length > normalizedTag.length
            ? token.length
            : normalizedTag.length;
        if ((token.length - normalizedTag.length).abs() > 1) continue;
        final distance = _lev(token, normalizedTag);
        final score = 1 - distance / length;
        if (score > best) best = score;
      }
      scores[tag] = best;
    }
    if (scores.isEmpty) return const _Match(null, 0);
    final sorted = scores.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final winner = sorted.first;
    if (winner.value < 0.85) return const _Match(null, 0);
    if (sorted.length > 1 && winner.value - sorted[1].value < 0.10) {
      return const _Match(null, 0);
    }
    return _Match(winner.key, winner.value);
  }

  String _norm(String s) =>
      s.toUpperCase().replaceAll(RegExp(r'[^A-Z0-9]'), '');

  int _lev(String a, String b) {
    final p = List<int>.generate(b.length + 1, (i) => i);
    for (var i = 1; i <= a.length; i++) {
      var prev = p[0];
      p[0] = i;
      for (var j = 1; j <= b.length; j++) {
        final old = p[j];
        p[j] = a[i - 1] == b[j - 1]
            ? prev
            : [prev, p[j], p[j - 1]].reduce((x, y) => x < y ? x : y) + 1;
        prev = old;
      }
    }
    return p[b.length];
  }
}
