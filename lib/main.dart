import 'package:flutter/material.dart';
import 'data/app_store.dart';
import 'localization/app_language.dart';
import 'screens/dashboard_screen.dart';
import 'screens/equipment_screen.dart';
import 'screens/logbook_screen.dart';
import 'screens/workspace_screen.dart';
import 'theme/operon_theme.dart';
import 'screens/scan_notes_screen.dart';
import 'services/notification_service.dart';
import 'services/quick_entry_parser.dart';
import 'screens/quick_entry_review_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService.instance.initialize();
  runApp(const OperonApp());
}

class OperonApp extends StatefulWidget {
  const OperonApp({super.key});

  @override
  State<OperonApp> createState() => _OperonAppState();
}

class _OperonAppState extends State<OperonApp> {
  final store = AppStore();
  final language = AppLanguageController();

  @override
  void initState() {
    super.initState();
    store.hydrate();
    language.hydrate();
  }

  @override
  Widget build(BuildContext context) => OperonLanguageScope(
        controller: language,
        child: AnimatedBuilder(
          animation: language,
          builder: (_, __) => MaterialApp(
            debugShowCheckedModeBanner: false,
            title: 'OPERON',
            locale: language.locale,
            theme: OperonTheme.dark(),
            home: AnimatedBuilder(
              animation: store,
              builder: (_, __) => Shell(store: store),
            ),
          ),
        ),
      );
}

class Shell extends StatefulWidget {
  final AppStore store;
  const Shell({super.key, required this.store});

  @override
  State<Shell> createState() => _ShellState();
}

class _ShellState extends State<Shell> {
  int index = 0;

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final pages = [
      DashboardScreen(store: widget.store),
      EquipmentScreen(store: widget.store),
      LogbookScreen(store: widget.store),
      WorkspaceScreen(store: widget.store),
    ];

    return Scaffold(
      body: SafeArea(child: IndexedStack(index: index, children: pages)),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _quick(context),
        child: const Icon(Icons.add_rounded, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (v) => setState(() => index = v),
        destinations: [
          NavigationDestination(icon: const Icon(Icons.home_rounded), label: t.home),
          NavigationDestination(
            icon: const Icon(Icons.precision_manufacturing_rounded),
            label: t.equipment,
          ),
          NavigationDestination(
            icon: const Icon(Icons.menu_book_rounded),
            label: t.logbook,
          ),
          NavigationDestination(
            icon: const Icon(Icons.grid_view_rounded),
            label: t.more,
          ),
        ],
      ),
    );
  }

  void _quick(BuildContext context) {
    final c = TextEditingController();
    final t = context.tr;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (context) => Padding(
        padding: EdgeInsets.fromLTRB(
          20,
          0,
          20,
          MediaQuery.viewInsetsOf(context).bottom + 28,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              t.quickEntry,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 6),
            Text(
              t.quickEntryHelp,
              style: const TextStyle(color: OperonTheme.muted),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: c,
              autofocus: true,
              maxLines: 3,
              decoration: InputDecoration(hintText: t.quickEntryHint),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => ScanNotesScreen(store: widget.store),
                        ),
                      );
                    },
                    icon: const Icon(Icons.document_scanner),
                    label: Text(t.scanNotes),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () {
                      final raw = c.text.trim();
                      if (raw.isEmpty) return;
                      final draft =
                          QuickEntryParser().parse(raw, widget.store.equipment);
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuickEntryReviewScreen(
                            store: widget.store,
                            draft: draft,
                          ),
                        ),
                      );
                    },
                    icon: const Icon(Icons.auto_awesome),
                    label: Text(t.interpret),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
