import 'package:flutter/material.dart';
import '../enterprise/operon_cloud.dart';

class SharedWorkflowsScreen extends StatefulWidget {
  const SharedWorkflowsScreen({super.key});
  @override
  State<SharedWorkflowsScreen> createState() => _SharedWorkflowsScreenState();
}

class _SharedWorkflowsScreenState extends State<SharedWorkflowsScreen> {
  List<Map<String, dynamic>> units = [];
  List<Map<String, dynamic>> tasks = [];
  String? selectedUnit;
  String? error;
  bool loading = false;

  Future<void> load() async {
    if (!OperonCloud.configured || !OperonCloud.available) return;
    setState(() { loading = true; error = null; });
    try {
      final db = OperonCloud.client;
      final memberships = List<Map<String, dynamic>>.from(
        await db.from('operon_memberships').select('unit_id,role').eq('active', true));
      final unit = memberships.any((m) => m['unit_id'] == selectedUnit)
          ? selectedUnit : (memberships.isEmpty ? null : memberships.first['unit_id'] as String);
      final rows = unit == null ? <Map<String, dynamic>>[] :
          List<Map<String, dynamic>>.from(await db.from('operon_workflows')
            .select('id,title,state,revision,created_by').eq('unit_id', unit));
      if (mounted) setState(() { units = memberships; selectedUnit = unit; tasks = rows; });
    } catch (e) {
      if (mounted) setState(() => error = 'Cloud request failed: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  @override
  void initState() { super.initState(); load(); }

  @override
  Widget build(BuildContext context) {
    final roles = units.where((m) => m['unit_id'] == selectedUnit)
        .map((m) => m['role'] as String).toSet();
    return Scaffold(
      appBar: AppBar(title: const Text('Shared Workflows'),
        actions: [IconButton(onPressed: loading ? null : load, icon: const Icon(Icons.refresh))]),
      body: !OperonCloud.configured
        ? const Center(child: Text('Cloud is not configured; offline tasks are unchanged.'))
        : !OperonCloud.available
          ? const Center(child: Text('Sign in from OPERON Account first.'))
          : ListView(padding: const EdgeInsets.all(16), children: [
              const Text('Development data only. Local tasks are not uploaded.'),
              if (loading) const LinearProgressIndicator(),
              if (error != null) Text(error!),
              if (units.isEmpty && !loading) const Text('No unit membership assigned by administrator.'),
              if (selectedUnit != null) ...[
                DropdownButton<String>(
                  isExpanded: true, value: selectedUnit,
                  items: units.map((m) => m['unit_id'] as String).toSet()
                    .map((id) => DropdownMenuItem(value: id, child: Text('Unit: $id'))).toList(),
                  onChanged: loading ? null : (value) { setState(() => selectedUnit = value); load(); },
                ),
                Text('Roles: ${roles.join(', ')}'),
                for (final task in tasks)
                  Card(child: ListTile(title: Text(task['title'] as String),
                    subtitle: Text('${task['state']} · revision ${task['revision']}'))),
              ],
            ]),
    );
  }
}
