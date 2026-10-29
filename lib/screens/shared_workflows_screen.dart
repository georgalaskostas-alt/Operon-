import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../enterprise/operon_cloud.dart';

class SharedWorkflowsScreen extends StatefulWidget {
  const SharedWorkflowsScreen({super.key});
  @override
  State<SharedWorkflowsScreen> createState() => _SharedWorkflowsScreenState();
}

class _SharedWorkflowsScreenState extends State<SharedWorkflowsScreen> {
  List<Map<String, dynamic>> units = [];
  List<Map<String, dynamic>> tasks = [];
  Map<String, String> unitNames = {};
  String filter = 'mine';
  int? previousActionableCount;
  String? queueNotice;
  String? selectedUnit;
  String? error;
  bool loading = false;
  RealtimeChannel? workflowChannel;
  String? subscribedUnit;

  Future<void> load() async {
    if (!OperonCloud.configured || !OperonCloud.available) return;
    setState(() { loading = true; error = null; });
    try {
      final db = OperonCloud.client;
      final memberships = List<Map<String, dynamic>>.from(
        await db.from('operon_memberships').select('unit_id,role').eq('active', true));
      final unit = memberships.any((m) => m['unit_id'] == selectedUnit)
          ? selectedUnit : (memberships.isEmpty ? null : memberships.first['unit_id'] as String);
      final ids = memberships.map((m) => m['unit_id'] as String).toSet().toList();
      final unitRows = ids.isEmpty ? <Map<String, dynamic>>[] :
          List<Map<String, dynamic>>.from(await db.from('operon_units')
            .select('id,name').inFilter('id', ids));
      final names = {for (final row in unitRows) row['id'] as String: row['name'] as String};
      final rows = unit == null ? <Map<String, dynamic>>[] :
          List<Map<String, dynamic>>.from(await db.from('operon_workflows')
            .select('id,title,state,revision,created_by').eq('unit_id', unit));
      final rolesForUnit = memberships.where((m) => m['unit_id'] == unit)
          .map((m) => m['role'] as String).toSet();
      final actionable = rows.where((task) =>
          allowedNextStates(task, rolesForUnit).isNotEmpty).length;
      if (mounted) {
        watchUnit(unit);
        setState(() {
        units = memberships;
        unitNames = names;
        selectedUnit = unit;
        tasks = rows;
        if (previousActionableCount != null && actionable > previousActionableCount!) {
          queueNotice = 'Νέα εργασία προς ενέργεια: '
              '${actionable - previousActionableCount!}';
        } else {
          queueNotice = null;
        }
        previousActionableCount = actionable;
        });
      }
    } catch (e) {
      if (mounted) setState(() => error = 'Cloud request failed: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void watchUnit(String? unit) {
    if (unit == subscribedUnit) return;
    final oldChannel = workflowChannel;
    workflowChannel = null;
    subscribedUnit = unit;
    if (oldChannel != null) {
      OperonCloud.client.removeChannel(oldChannel);
    }
    if (unit == null) return;
    workflowChannel = OperonCloud.client
        .channel('operon-workflows-$unit')
        .onPostgresChanges(
          event: PostgresChangeEvent.all,
          schema: 'public',
          table: 'operon_workflows',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'unit_id',
            value: unit,
          ),
          callback: (_) {
            if (mounted && !loading) {
              load();
            }
          },
        )
        .subscribe();
  }

  @override
  void dispose() {
    final channel = workflowChannel;
    if (channel != null) {
      OperonCloud.client.removeChannel(channel);
    }
    super.dispose();
  }

  Future<void> showShiftHandovers() async {
    final unit = selectedUnit;
    if (unit == null || loading) return;
    try {
      final records = List<Map<String, dynamic>>.from(
        await OperonCloud.client.from('operon_shift_handovers')
            .select('id,shift_date,shift_name,summary,created_at,operon_handover_workflows(workflow_id,operon_workflows(title,state))')
            .eq('unit_id', unit)
            .order('created_at', ascending: false)
            .limit(30));
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (ctx) => SafeArea(child: FractionallySizedBox(
          heightFactor: 0.75,
          child: ListView(padding: const EdgeInsets.all(16), children: [
            Text('Παραδόσεις βάρδιας',
                style: Theme.of(ctx).textTheme.titleLarge),
            if (records.isEmpty)
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text('Δεν υπάρχουν ακόμη παραδόσεις βάρδιας.')),
            for (final record in records)
              Card(child: ListTile(
                title: Text('${record['shift_date']} · '
                    '${shiftLabel(record['shift_name'] as String)}'),
                subtitle: Text('${record['summary']}\n${_linkedSummary(record)}'),\n                isThreeLine: true,
              )),
          ]),
        )),
      );
    } catch (e) {
      if (mounted) setState(() => error = 'Αδυναμία φόρτωσης παραδόσεων: $e');
    }
  }

  String _linkedSummary(Map<String, dynamic> record) {\n    final links = (record['operon_handover_workflows'] as List?) ?? const [];\n    if (links.isEmpty) return 'Δεν έχουν συνδεθεί εκκρεμότητες.';\n    return 'Συνδεδεμένες εκκρεμότητες: ${links.length}\\n${links.map((e) { final w = e['operon_workflows']; return '• ${w?['title'] ?? 'Άγνωστη εργασία'} (${w?['state'] ?? '—'})'; }).join('\\n')}';\n  }\n\n  String shiftLabel(String shift) {
    switch (shift) {
      case 'morning': return 'Πρωινή';
      case 'afternoon': return 'Απογευματινή';
      case 'night': return 'Νυχτερινή';
      default: return shift;
    }
  }

  Future<void> createShiftHandover() async {
    final unit = selectedUnit;
    if (unit == null || loading) return;
    final note = TextEditingController();
    var shift = 'morning';\n    final openTasks = tasks.where((t) => t['state'] != 'completed').toList();\n    final selectedWorkflowIds = <String>{};
    final today = DateTime.now();
    final date = '${today.year.toString().padLeft(4, '0')}-'
        '${today.month.toString().padLeft(2, '0')}-'
        '${today.day.toString().padLeft(2, '0')}';
    final result = await showDialog<Map<String, String>>(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, update) => AlertDialog(
          title: const Text('Νέα παράδοση βάρδιας'),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Ημερομηνία: $date'),
            DropdownButton<String>(
              value: shift,
              isExpanded: true,
              items: ['morning', 'afternoon', 'night']
                  .map((value) => DropdownMenuItem(
                    value: value, child: Text(shiftLabel(value)))).toList(),
              onChanged: (value) {
                if (value != null) update(() => shift = value);
              },
            ),
            TextField(
              controller: note,
              maxLength: 2000,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Σημειώσεις παράδοσης (δοκιμαστικά δεδομένα)'),
            ),
          ]),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx),
                child: const Text('Ακύρωση')),
            FilledButton(
              onPressed: () {
                if (note.text.trim().isNotEmpty) {
                  Navigator.pop(ctx, {'shift': shift, 'summary': note.text.trim(),\n                    'workflow_ids': selectedWorkflowIds.join(',')});
                }
              },
              child: const Text('Καταχώριση'),
            ),
          ],
        ),
      ),
    );
    note.dispose();
    if (!mounted || result == null) return;
    setState(() { loading = true; error = null; });
    try {
      await OperonCloud.client.rpc('operon_create_shift_handover', params: {
        'p_unit_id': unit,
        'p_shift_date': date,
        'p_shift_name': result['shift'],
        'p_summary': result['summary'],\n        'p_workflow_ids': (result['workflow_ids'] ?? '').isEmpty\n            ? <String>[] : result['workflow_ids']!.split(','),
      });
    } catch (e) {
      if (mounted) setState(() => error = 'Αδυναμία καταχώρισης: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  void openMyQueue() {
    setState(() {
      filter = 'mine';
      queueNotice = null;
    });
  }

  Future<void> submitWorkflow() async {
    if (loading || selectedUnit == null) return;
    final controller = TextEditingController();
    final title = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('New shared workflow'),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 250,
          decoration: const InputDecoration(labelText: 'Title'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Ακύρωση')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, controller.text.trim()),
            child: const Text('Create')),
        ],
      ),
    );
    if (!mounted || title == null || title.isEmpty) return;
    setState(() { loading = true; error = null; });
    try {
      await OperonCloud.client.rpc('operon_submit_workflow', params: {
        'p_unit_id': selectedUnit,
        'p_title': title,
      });
    } catch (e) {
      if (mounted) setState(() => error = 'Unable to submit workflow: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
    await load();
  }


  List<String> allowedNextStates(Map<String, dynamic> task, Set<String> roles) {
    final state = task['state'] as String;
    if (state == 'submitted' && roles.contains('foreman')) {
      return ['foremanReview', 'returned'];
    }
    if (state == 'foremanReview' && roles.contains('foreman')) {
      return ['coordinatorReview', 'returned'];
    }
    if (state == 'coordinatorReview' && roles.contains('coordinator')) {
      return ['managementReview', 'returned'];
    }
    if (state == 'managementReview' &&
        (roles.contains('supervisor') || roles.contains('unitEngineer'))) {
      return ['completed', 'returned'];
    }
    if (state == 'returned' &&
        roles.contains('operator') &&
        task['created_by'] == OperonCloud.client.auth.currentUser?.id) {
      return ['submitted'];
    }
    return [];
  }

  String actionLabel(String current, String next) {
    if (current == 'submitted' && next == 'foremanReview') {
      return 'Ανάληψη για έλεγχο';
    }
    if (current == 'foremanReview' && next == 'coordinatorReview') {
      return 'Ολοκλήρωση ελέγχου · Προώθηση στον Συντονιστή';
    }
    if (current == 'coordinatorReview' && next == 'managementReview') {
      return 'Προώθηση για τελική έγκριση';
    }
    if (current == 'managementReview' && next == 'completed') {
      return 'Τελική έγκριση · Ολοκλήρωση';
    }
    if (next == 'returned') return 'Επιστροφή στον Χειριστή';
    if (current == 'returned' && next == 'submitted') {
      return 'Επανυποβολή εργασίας';
    }
    return stateLabel(next);
  }

  Future<void> transitionWorkflow(Map<String, dynamic> task, String next) async {
    if (loading) return;
    final controller = TextEditingController();
    final note = await showDialog<String>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(actionLabel(task['state'] as String, next)),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLength: 2000,
          maxLines: 3,
          decoration: const InputDecoration(labelText: 'Υποχρεωτικό σχόλιο'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();
              if (value.isNotEmpty) Navigator.pop(dialogContext, value);
            },
            child: const Text('Επιβεβαίωση'),
          ),
        ],
      ),
    );
    if (!mounted || note == null || note.isEmpty) return;
    setState(() { loading = true; error = null; });
    try {
      await OperonCloud.client.rpc('operon_transition_workflow', params: {
        'p_workflow_id': task['id'],
        'p_expected_revision': task['revision'],
        'p_next_state': next,
        'p_note': note,
      });
    } catch (e) {
      if (mounted) setState(() => error = 'Transition failed: $e');
    } finally {
      if (mounted) setState(() => loading = false);
    }
    await load();
  }


  String stateLabel(String state) {
    switch (state) {
      case 'submitted': return 'Υποβλήθηκε';
      case 'foremanReview': return 'Έλεγχος εργοδηγού';
      case 'coordinatorReview': return 'Έλεγχος συντονιστή';
      case 'managementReview': return 'Τελική έγκριση';
      case 'completed': return 'Ολοκληρώθηκε';
      case 'returned': return 'Επιστράφηκε';
      default: return state;
    }
  }

  String displayDate(Object? raw) {
    final date = DateTime.tryParse(raw?.toString() ?? '');
    if (date == null) return 'Άγνωστη ημερομηνία';
    final local = date.toLocal();
    String two(int n) => n.toString().padLeft(2, '0');
    return '${two(local.day)}/${two(local.month)}/${local.year} '
        '${two(local.hour)}:${two(local.minute)}';
  }

  String roleLabel(String role) {
    switch (role) {
      case 'operator': return 'Χειριστής';
      case 'foreman': return 'Εργοδηγός';
      case 'coordinator': return 'Συντονιστής';
      case 'supervisor': return 'Προϊστάμενος';
      case 'unitEngineer': return 'Μηχανικός μονάδας';
      default: return role;
    }
  }

  Future<void> showHistory(Map<String, dynamic> task) async {
    if (loading) return;
    try {
      final rows = List<Map<String, dynamic>>.from(
        await OperonCloud.client.from('operon_workflow_events')
          .select('actor_role,from_state,to_state,note,revision,created_at')
          .eq('workflow_id', task['id'] as String)
          .order('revision', ascending: true));
      if (!mounted) return;
      await showModalBottomSheet<void>(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (sheetContext) => SafeArea(child: FractionallySizedBox(
          heightFactor: 0.75,
          child: ListView(padding: const EdgeInsets.all(20), children: [
            Text(task['title'] as String, style: Theme.of(sheetContext).textTheme.titleLarge),
            const SizedBox(height: 8),
            const Text('Ιστορικό εγκρίσεων / Approval history'),
            if (rows.isEmpty) const Padding(
              padding: EdgeInsets.all(20), child: Text('Δεν υπάρχουν ακόμη αλλαγές κατάστασης.')),
            for (final event in rows)
              Card(child: ListTile(
                title: Text('${stateLabel(event['from_state'] as String)} → ${stateLabel(event['to_state'] as String)}'),
                subtitle: Text(
                  'Revision ${event['revision']} · ${event['actor_role']}\n'
                  '${event['created_at']}\n${event['note']}'),
                isThreeLine: true,
              )),
          ]),
        )),
      );
    } catch (e) {
      if (mounted) setState(() => error = 'Unable to load history: $e');
    }
  }

  @override
  void initState() { super.initState(); load(); }

  @override
  Widget build(BuildContext context) {
    final roles = units.where((m) => m['unit_id'] == selectedUnit)
        .map((m) => m['role'] as String).toSet();
    final myCount = tasks.where((task) =>
        allowedNextStates(task, roles).isNotEmpty).length;
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
              Card(
                child: ListTile(
                  leading: const Icon(Icons.notifications_active_outlined),
                  title: Text('Οι εκκρεμότητές μου: $myCount'),
                  subtitle: Text(queueNotice ??
                      (myCount == 0
                          ? 'Δεν απαιτείται ενέργεια από τον ρόλο σας.'
                          : 'Υπάρχουν εργασίες που χρειάζονται ενέργεια.')),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: openMyQueue,
                ),
              ),
              if (units.isEmpty && !loading) const Text('No unit membership assigned by administrator.'),
              if (selectedUnit != null) ...[
                DropdownButton<String>(
                  isExpanded: true, value: selectedUnit,
                  items: units.map((m) => m['unit_id'] as String).toSet()
                    .map((id) => DropdownMenuItem(value: id, child: Text(unitNames[id] ?? id))).toList(),
                  onChanged: loading ? null : (value) { setState(() { selectedUnit = value; previousActionableCount = null; queueNotice = null; }); load(); },
                ),
                Text('Ρόλοι / Roles: ${roles.join(', ')}'),
                const SizedBox(height: 12),
                Wrap(spacing: 8, children: [
                  OutlinedButton.icon(
                    onPressed: loading ? null : showShiftHandovers,
                    icon: const Icon(Icons.history),
                    label: const Text('Παραδόσεις βάρδιας'),
                  ),
                  FilledButton.icon(
                    onPressed: loading ? null : createShiftHandover,
                    icon: const Icon(Icons.note_add_outlined),
                    label: const Text('Νέα παράδοση'),
                  ),
                ]),
                const SizedBox(height: 12),
                SegmentedButton<String>(
                  segments: const [
                    ButtonSegment(value: 'mine', label: Text('Δικές μου')),
                    ButtonSegment(value: 'pending', label: Text('Εκκρεμείς')),
                    ButtonSegment(value: 'all', label: Text('Όλες')),
                    ButtonSegment(value: 'completed', label: Text('Κλειστές')),
                  ],
                  selected: {filter},
                  onSelectionChanged: (value) => setState(() => filter = value.first),
                ),
                const SizedBox(height: 12),
                if (filter == 'mine' && !tasks.any((task) =>
                    allowedNextStates(task, roles).isNotEmpty))
                  const Padding(
                    padding: EdgeInsets.symmetric(vertical: 20),
                    child: Center(child: Text('Δεν υπάρχουν εργασίες που απαιτούν δική σας ενέργεια.')),
                  ),
                if (roles.contains('operator'))
                  FilledButton.icon(
                    onPressed: loading ? null : submitWorkflow,
                    icon: const Icon(Icons.add),
                    label: const Text('Create shared workflow'),
                  ),
                for (final task in tasks.where((task) =>
                  (filter == 'mine' && allowedNextStates(task, roles).isNotEmpty) ||
                  filter == 'all' ||
                  (filter == 'completed' && task['state'] == 'completed') ||
                  (filter == 'pending' && task['state'] != 'completed')))
                  Card(child: Column(children: [
                    ListTile(
                      title: Text(task['title'] as String),
                      subtitle: Text('${stateLabel(task['state'] as String)} · revision ${task['revision']}'),
                      trailing: const Icon(Icons.history),
                      onTap: () => showHistory(task),
                    ),
                    for (final next in allowedNextStates(task, roles))
                      TextButton(
                        onPressed: loading ? null : () => transitionWorkflow(task, next),
                        child: Text(actionLabel(task['state'] as String, next)),
                      ),
                  ])),
              ],
            ]),
    );
  }
}
