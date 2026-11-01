import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../localization/app_language.dart';
import '../services/operon_assistant.dart';
import '../theme/operon_theme.dart';

class AiScreen extends StatefulWidget {
  final AppStore store;
  const AiScreen({super.key, required this.store});
  @override
  State<AiScreen> createState() => _S();
}

class _S extends State<AiScreen> {
  final q = TextEditingController();
  AssistantAnswer? answer;

  @override
  Widget build(BuildContext c) {
    final t = c.tr;
    return Scaffold(
      appBar: AppBar(title: Text(t.assistant)),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          Card(
            child: ListTile(
              leading: const Icon(Icons.lock, color: OperonTheme.teal),
              title: Text(t.groundedPrivate),
              subtitle: Text(t.assistantSafety),
            ),
          ),
          Wrap(
            spacing: 8,
            children: [t.shiftQuestion, 'P-2101A', t.overdueActions]
                .map((x) => ActionChip(
                    label: Text(x),
                    onPressed: () {
                      q.text = x;
                      _ask();
                    }))
                .toList(),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: q,
            onSubmitted: (_) => _ask(),
            decoration: InputDecoration(hintText: t.askHint),
          ),
          const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: _ask,
            icon: const Icon(Icons.auto_awesome),
            label: Text(t.askOperon),
          ),
          const SizedBox(height: 16),
          if (answer != null)
            Expanded(
              child: ListView(children: [
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: SelectableText(answer!.text),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 6),
                  child: Text(t.sourcesUsed,
                      style: const TextStyle(
                          color: OperonTheme.muted,
                          fontSize: 11,
                          fontWeight: FontWeight.w800)),
                ),
                ...answer!.sources.map(
                  (s) => ListTile(
                    dense: true,
                    leading: const Icon(Icons.verified_outlined,
                        color: OperonTheme.teal, size: 18),
                    title: Text(s),
                  ),
                )
              ]),
            )
        ]),
      ),
    );
  }

  void _ask() {
    if (q.text.trim().isEmpty) return;
    setState(
        () => answer = OperonAssistant(widget.store).ask(q.text.trim()));
  }
}
