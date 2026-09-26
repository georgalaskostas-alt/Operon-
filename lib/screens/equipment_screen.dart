import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../localization/app_language.dart';
import '../models/models.dart';
import '../theme/operon_theme.dart';
import '../widgets/common.dart';
import 'equipment_intelligence_screen.dart';

class EquipmentScreen extends StatefulWidget {
  final AppStore store;
  const EquipmentScreen({super.key, required this.store});
  @override
  State<EquipmentScreen> createState() => _EquipmentScreenState();
}

class _EquipmentScreenState extends State<EquipmentScreen> {
  String query = '';

  @override
  Widget build(BuildContext context) {
    final t = context.tr;
    final items = widget.store.equipment
        .where((e) => '${e.tag} ${e.name} ${e.area}'
            .toLowerCase()
            .contains(query.toLowerCase()))
        .toList();
    return ListView(children: [
      OperonHeader(t.equipment, subtitle: t.statusNotesHistory),
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: TextField(
          onChanged: (value) => setState(() => query = value),
          decoration: InputDecoration(
            prefixIcon: const Icon(Icons.search),
            hintText: t.searchTagEquipment,
          ),
        ),
      ),
      const SizedBox(height: 12),
      ...items.map((e) => Card(
            margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 6),
            child: ListTile(
              onTap: () => _details(e),
              title: Text(e.tag,
                  style: const TextStyle(fontWeight: FontWeight.w800)),
              subtitle: Text(
                  '${e.name}\n${e.note.isEmpty ? e.area : e.note}'),
              isThreeLine: true,
              trailing: Text(e.state.name,
                  style: const TextStyle(
                      color: OperonTheme.teal,
                      fontSize: 11,
                      fontWeight: FontWeight.w700)),
            ),
          )),
      const SizedBox(height: 100),
    ]);
  }

  void _details(Equipment equipment) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EquipmentIntelligenceScreen(
            store: widget.store, equipment: equipment),
      ),
    ).then((_) => setState(() {}));
  }
}
