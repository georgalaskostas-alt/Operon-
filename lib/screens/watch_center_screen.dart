import 'package:flutter/material.dart';
import '../data/app_store.dart';
import '../localization/app_language.dart';
import '../theme/operon_theme.dart';

class WatchCenterScreen extends StatefulWidget {
  final AppStore store;
  const WatchCenterScreen({super.key, required this.store});
  @override State<WatchCenterScreen> createState() => _WatchCenterScreenState();
}
class _WatchCenterScreenState extends State<WatchCenterScreen> {
  @override
  Widget build(BuildContext context) {
    final active = widget.store.watch.where((item) => item.active).toList();
    return Scaffold(
      appBar: AppBar(title: Text(context.tr.watchCenter)),
      body: active.isEmpty ? Center(child: Text(context.tr.noActiveWatch)) : ListView(
        padding: const EdgeInsets.all(12),
        children: active.map((item) => Card(
          child: ListTile(
            leading: const Icon(Icons.visibility, color: OperonTheme.teal),
            title: Text(item.equipmentTag ?? item.title),
            subtitle: Text('${item.title} · ${item.detail}'),
            trailing: IconButton(icon: const Icon(Icons.check_circle_outline),onPressed: () {widget.store.resolveWatch(item);setState(() {});}),
          ),
        )).toList(),
      ),
    );
  }
}
