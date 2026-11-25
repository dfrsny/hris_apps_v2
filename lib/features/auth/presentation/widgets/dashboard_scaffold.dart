import 'package:material_ui/material_ui.dart';

class DashboardScaffold extends StatelessWidget {
  const DashboardScaffold({
    super.key,
    required this.title,
    required this.onLogout,
    this.children = const [],
  });

  final String title;
  final VoidCallback onLogout;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: onLogout,
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: children.isEmpty
            ? [const Center(child: Text('Segera hadir'))]
            : children,
      ),
    );
  }
}
