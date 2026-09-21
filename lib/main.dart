import 'package:flutter/material.dart';

void main() {
  runApp(const OperonApp());
}

class OperonApp extends StatelessWidget {
  const OperonApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'OPERON',
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF07111D),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF22C7B8),
          secondary: Color(0xFF57A8FF),
          surface: Color(0xFF0E1B2A),
        ),
        useMaterial3: true,
      ),
      home: const OperatorShell(),
    );
  }
}

class OperatorShell extends StatefulWidget {
  const OperatorShell({super.key});

  @override
  State<OperatorShell> createState() => _OperatorShellState();
}

class _OperatorShellState extends State<OperatorShell> {
  int index = 0;

  static const pages = [
    DashboardPage(),
    PlaceholderPage(title: 'Equipment', icon: Icons.precision_manufacturing_rounded),
    PlaceholderPage(title: 'Logbook', icon: Icons.menu_book_rounded),
    PlaceholderPage(title: 'Workspace', icon: Icons.grid_view_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(child: pages[index]),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _showQuickEntry(context),
        backgroundColor: const Color(0xFF22C7B8),
        foregroundColor: const Color(0xFF041417),
        child: const Icon(Icons.add_rounded, size: 30),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: NavigationBar(
        selectedIndex: index,
        onDestinationSelected: (value) => setState(() => index = value),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.home_rounded), label: 'Home'),
          NavigationDestination(icon: Icon(Icons.precision_manufacturing_rounded), label: 'Equipment'),
          NavigationDestination(icon: Icon(Icons.menu_book_rounded), label: 'Logbook'),
          NavigationDestination(icon: Icon(Icons.grid_view_rounded), label: 'More'),
        ],
      ),
    );
  }

  void _showQuickEntry(BuildContext context) {
    showModalBottomSheet(
      context: context,
      showDragHandle: true,
      backgroundColor: const Color(0xFF0E1B2A),
      builder: (_) => const Padding(
        padding: EdgeInsets.fromLTRB(20, 8, 20, 32),
        child: Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            QuickAction(icon: Icons.edit_note_rounded, label: 'Quick Log'),
            QuickAction(icon: Icons.document_scanner_rounded, label: 'Scan Notes'),
            QuickAction(icon: Icons.photo_camera_rounded, label: 'Take Photo'),
            QuickAction(icon: Icons.timer_rounded, label: 'Timer'),
          ],
        ),
      ),
    );
  }
}

class DashboardPage extends StatelessWidget {
  const DashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: const [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('OPERON', style: TextStyle(fontSize: 12, letterSpacing: 3, color: Color(0xFF22C7B8), fontWeight: FontWeight.w700)),
              SizedBox(height: 6),
              Text('Good shift.', style: TextStyle(fontSize: 30, fontWeight: FontWeight.w700)),
              Text('Morning · Unit workspace', style: TextStyle(color: Color(0xFF8FA4B8))),
            ]),
            CircleAvatar(radius: 24, backgroundColor: Color(0xFF14263A), child: Icon(Icons.person_rounded)),
          ],
        ),
        SizedBox(height: 24),
        SectionTitle('NOW'),
        SizedBox(height: 10),
        Row(children: [
          Expanded(child: MetricCard(value: '3', label: 'Open issues', icon: Icons.warning_amber_rounded)),
          SizedBox(width: 12),
          Expanded(child: MetricCard(value: '2', label: 'Maintenance', icon: Icons.build_rounded)),
        ]),
        SizedBox(height: 12),
        Row(children: [
          Expanded(child: MetricCard(value: '4', label: 'Active timers', icon: Icons.timer_outlined)),
          SizedBox(width: 12),
          Expanded(child: MetricCard(value: '1', label: 'Reminder', icon: Icons.notifications_active_outlined)),
        ]),
        SizedBox(height: 24),
        SectionTitle('WATCHLIST'),
        SizedBox(height: 10),
        StatusCard(tag: 'P-2101A', title: 'Maintenance', detail: 'Mechanical inspection pending', status: 'OPEN'),
        StatusCard(tag: 'E-2204', title: 'Monitor ΔP', detail: 'Shift watch item', status: 'WATCH'),
        SizedBox(height: 24),
        SectionTitle('RECENT LOG'),
        SizedBox(height: 10),
        TimelineRow(time: '15:42', text: 'P-2101A stopped'),
        TimelineRow(time: '15:44', text: 'P-2101B started'),
        TimelineRow(time: '15:50', text: 'Maintenance informed'),
      ],
    );
  }
}

class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});
  @override
  Widget build(BuildContext context) => Text(text, style: const TextStyle(fontSize: 12, letterSpacing: 1.5, color: Color(0xFF8FA4B8), fontWeight: FontWeight.w700));
}

class MetricCard extends StatelessWidget {
  final String value, label;
  final IconData icon;
  const MetricCard({super.key, required this.value, required this.label, required this.icon});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xFF0E1B2A), borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFF193149))),
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(icon, color: const Color(0xFF22C7B8)),
      const SizedBox(height: 14),
      Text(value, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700)),
      Text(label, style: const TextStyle(color: Color(0xFF8FA4B8))),
    ]),
  );
}

class StatusCard extends StatelessWidget {
  final String tag, title, detail, status;
  const StatusCard({super.key, required this.tag, required this.title, required this.detail, required this.status});
  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(color: const Color(0xFF0E1B2A), borderRadius: BorderRadius.circular(18)),
    child: Row(children: [
      Container(width: 4, height: 48, decoration: BoxDecoration(color: const Color(0xFF22C7B8), borderRadius: BorderRadius.circular(4))),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(tag, style: const TextStyle(fontWeight: FontWeight.w700)),
        Text(title),
        Text(detail, style: const TextStyle(color: Color(0xFF8FA4B8), fontSize: 12)),
      ])),
      Text(status, style: const TextStyle(color: Color(0xFF22C7B8), fontSize: 11, fontWeight: FontWeight.w700)),
    ]),
  );
}

class TimelineRow extends StatelessWidget {
  final String time, text;
  const TimelineRow({super.key, required this.time, required this.text});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 8),
    child: Row(children: [
      SizedBox(width: 52, child: Text(time, style: const TextStyle(color: Color(0xFF8FA4B8)))),
      const Icon(Icons.circle, size: 8, color: Color(0xFF22C7B8)),
      const SizedBox(width: 12),
      Text(text),
    ]),
  );
}

class QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  const QuickAction({super.key, required this.icon, required this.label});
  @override
  Widget build(BuildContext context) => SizedBox(
    width: (MediaQuery.sizeOf(context).width - 52) / 2,
    child: FilledButton.tonalIcon(onPressed: () {}, icon: Icon(icon), label: Padding(padding: const EdgeInsets.symmetric(vertical: 16), child: Text(label))),
  );
}

class PlaceholderPage extends StatelessWidget {
  final String title;
  final IconData icon;
  const PlaceholderPage({super.key, required this.title, required this.icon});
  @override
  Widget build(BuildContext context) => Center(child: Column(mainAxisSize: MainAxisSize.min, children: [Icon(icon, size: 54, color: const Color(0xFF22C7B8)), const SizedBox(height: 12), Text(title, style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w700))]));
}
