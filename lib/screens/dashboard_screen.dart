import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../models/models.dart';
import '../theme/operon_theme.dart';
import '../widgets/common.dart';

class DashboardScreen extends StatelessWidget {
  final AppStore store;
  const DashboardScreen({super.key, required this.store});

  @override Widget build(BuildContext context) => ListView(children: [
    const OperonHeader('Good shift.', subtitle: 'Operator workspace · Live local data'),
    Padding(padding: const EdgeInsets.symmetric(horizontal: 20), child: Row(children: [
      _metric('Open', store.tasks.where((e)=>e.state != ActionState.completed).length.toString(), Icons.warning_amber_rounded),
      const SizedBox(width: 10),
      _metric('Maintenance', store.equipment.where((e)=>e.state == EquipmentState.maintenance).length.toString(), Icons.build_rounded),
      const SizedBox(width: 10),
      _metric('Watch', store.watch.where((e)=>e.active).length.toString(), Icons.visibility_rounded),
    ])),
    const SectionLabel('Watchlist'),
    ...store.watch.where((e)=>e.active).map((e)=>ListTile(
      leading: const Icon(Icons.circle, size: 10, color: OperonTheme.teal),
      title: Text(e.equipmentTag ?? e.title, style: const TextStyle(fontWeight: FontWeight.w700)),
      subtitle: Text('${e.title} · ${e.detail}'),
    )),
    const SectionLabel('Recent log'),
    ...store.logs.take(6).map((e)=>ListTile(leading: SizedBox(width: 48, child: Text(hhmm(e.createdAt), style: const TextStyle(color: OperonTheme.muted))), title: Text(e.text), subtitle: e.equipmentTag == null ? null : Text(e.equipmentTag!))),
    const SizedBox(height: 100),
  ]);

  Widget _metric(String label, String value, IconData icon) => Expanded(child: Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(color: OperonTheme.panel, borderRadius: BorderRadius.circular(18)),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Icon(icon, color: OperonTheme.teal), const SizedBox(height: 12), Text(value, style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800)), Text(label, style: const TextStyle(color: OperonTheme.muted, fontSize: 11))]),
  ));
}
