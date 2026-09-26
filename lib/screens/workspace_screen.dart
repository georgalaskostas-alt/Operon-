import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../localization/app_language.dart';
import '../theme/operon_theme.dart';
import '../widgets/common.dart';
import 'actions_screen.dart';
import 'ai_screen.dart';
import 'handover_screen.dart';
import 'notes_screen.dart';
import 'process_circuits_screen.dart';
import 'procedures_screen.dart';
import 'scan_notes_screen.dart';
import 'timers_screen.dart';
import 'watch_center_screen.dart';

class WorkspaceScreen extends StatelessWidget {
  final AppStore store;
  const WorkspaceScreen({super.key, required this.store});

  @override
  Widget build(BuildContext c) {
    final t = c.tr;
    return ListView(
      children: [
        OperonHeader(t.workspace, subtitle: t.workspaceSubtitle),
        _t(c, Icons.pending_actions, t.pendingActions, t.pendingActionsSub,
            ActionsScreen(store: store)),
        _t(c, Icons.visibility_rounded, t.watchItems, t.watchItemsSub,
            WatchCenterScreen(store: store)),
        _t(c, Icons.timer_rounded, t.timers, t.timersSub,
            const TimersScreen()),
        _t(c, Icons.note_alt_rounded, t.notes, t.notesSub,
            NotesScreen(store: store)),
        _t(c, Icons.document_scanner_rounded, t.scanHandwritten,
            t.scanHandwrittenSub, ScanNotesScreen(store: store)),
        _t(c, Icons.fact_check_rounded, t.procedures, t.proceduresSub,
            ProceduresScreen(store: store)),
        _t(c, Icons.account_tree_rounded, t.processCircuits,
            t.processCircuitsSub, ProcessCircuitsScreen(store: store)),
        _t(c, Icons.handshake_rounded, t.handover, t.handoverSub,
            HandoverScreen(store: store)),
        _t(c, Icons.auto_awesome_rounded, t.privateAi, t.privateAiSub,
            AiScreen(store: store)),
        _languageTile(c),
        const SizedBox(height: 100),
      ],
    );
  }

  Widget _languageTile(BuildContext c) {
    final t = c.tr;
    final controller = c.languageController;
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
      child: ListTile(
        onTap: () => _chooseLanguage(c),
        leading: const Icon(Icons.language_rounded, color: OperonTheme.teal),
        title: Text(t.languageLabel,
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text(
          controller.language == AppLanguage.el ? t.greek : t.english,
        ),
        trailing: const Icon(Icons.chevron_right),
      ),
    );
  }

  Future<void> _chooseLanguage(BuildContext c) async {
    final controller = c.languageController;
    final t = c.tr;
    await showModalBottomSheet<void>(
      context: c,
      showDragHandle: true,
      builder: (sheetContext) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                t.languageLabel,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(t.languageSub,
                  style: const TextStyle(color: OperonTheme.muted)),
              const SizedBox(height: 12),
              ListTile(
                onTap: () {
                  controller.setLanguage(AppLanguage.el);
                  Navigator.pop(sheetContext);
                },
                leading: Icon(
                  controller.language == AppLanguage.el
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: OperonTheme.teal,
                ),
                title: Text(t.greek),
              ),
              ListTile(
                onTap: () {
                  controller.setLanguage(AppLanguage.en);
                  Navigator.pop(sheetContext);
                },
                leading: Icon(
                  controller.language == AppLanguage.en
                      ? Icons.radio_button_checked
                      : Icons.radio_button_unchecked,
                  color: OperonTheme.teal,
                ),
                title: Text(t.english),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _t(BuildContext c, IconData i, String t, String s, Widget? page) =>
      Card(
        margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
        child: ListTile(
          onTap: page == null
              ? null
              : () => Navigator.push(
                    c,
                    MaterialPageRoute(builder: (_) => page),
                  ),
          leading: Icon(i, color: OperonTheme.teal),
          title: Text(t, style: const TextStyle(fontWeight: FontWeight.w700)),
          subtitle: Text(s),
          trailing: const Icon(Icons.chevron_right),
        ),
      );
}
