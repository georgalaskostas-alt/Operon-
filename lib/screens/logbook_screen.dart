import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../localization/app_language.dart';
import '../theme/operon_theme.dart';
import '../widgets/common.dart';

class LogbookScreen extends StatelessWidget {
  final AppStore store;
  const LogbookScreen({super.key, required this.store});

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    return ListView(children: [
      OperonHeader(t.logbook, subtitle: t.immutableTimeline),
      ...store.logs.map(
        (e) => Card(
          margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
          child: ListTile(
            leading: Text(hhmm(e.createdAt),
                style: const TextStyle(color: OperonTheme.muted)),
            title: Text(e.text),
            subtitle: Text('${e.equipmentTag ?? t.general} · ${e.source}'),
          ),
        ),
      ),
      const SizedBox(height: 100),
    ]);
  }
}
