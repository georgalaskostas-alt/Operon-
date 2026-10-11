import 'package:flutter/material.dart';
import '../theme/operon_theme.dart';

class OperonHeader extends StatelessWidget {
  final String title;
  final String? subtitle;
  const OperonHeader(this.title, {super.key, this.subtitle});
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Text('OPERON', style: TextStyle(color: OperonTheme.teal, letterSpacing: 3, fontWeight: FontWeight.w800, fontSize: 11)),
      const SizedBox(height: 6),
      Text(title, style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w800)),
      if (subtitle != null) Text(subtitle!, style: const TextStyle(color: OperonTheme.muted)),
    ]),
  );
}

class SectionLabel extends StatelessWidget {
  final String text;
  const SectionLabel(this.text, {super.key});
  @override Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
    child: Text(text.toUpperCase(), style: const TextStyle(color: OperonTheme.muted, letterSpacing: 1.4, fontSize: 11, fontWeight: FontWeight.w800)),
  );
}

String hhmm(DateTime d) => '${d.hour.toString().padLeft(2,'0')}:${d.minute.toString().padLeft(2,'0')}';
