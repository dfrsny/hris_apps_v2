import 'package:material_ui/material_ui.dart';

class DashboardScaffold extends StatefulWidget {
  const DashboardScaffold({
    super.key,
    required this.title,
    required this.onLogout,
    this.destinations = const [],
    this.pages = const [],
    this.body,
    this.children = const [],
  }) : assert(
         destinations.length == pages.length,
         'Jumlah destinations dan pages harus sama',
       );

  final String title;
  final VoidCallback onLogout;
  final List<NavigationDestination> destinations;
  final List<Widget> pages;
  final Widget? body;
  final List<Widget> children;

  @override
  State<DashboardScaffold> createState() => _DashboardScaffoldState();
}

class _DashboardScaffoldState extends State<DashboardScaffold> {
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    final hasNavBar = widget.destinations.isNotEmpty;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          hasNavBar
              ? '${widget.title} • ${widget.destinations[_activeIndex].label}'
              : widget.title,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Logout',
            onPressed: widget.onLogout,
          ),
        ],
      ),
      body: hasNavBar
          ? IndexedStack(index: _activeIndex, children: widget.pages)
          : (widget.body ??
                ListView(
                  padding: const EdgeInsets.all(16),
                  children: widget.children.isEmpty
                      ? [const Center(child: Text('Segera hadir'))]
                      : widget.children,
                )),
      bottomNavigationBar: hasNavBar
          ? NavigationBar(
              selectedIndex: _activeIndex,
              onDestinationSelected: (index) {
                setState(() => _activeIndex = index);
              },
              destinations: widget.destinations,
            )
          : null,
    );
  }
}
