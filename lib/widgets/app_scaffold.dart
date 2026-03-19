import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class AppScaffold extends StatelessWidget {
  final Widget child;
  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    return Scaffold(
      body: Row(
        children: [
          _NavigationRail(currentLocation: location),
          const VerticalDivider(thickness: 1, width: 1, color: Colors.white12),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _NavigationRail extends StatelessWidget {
  final String currentLocation;
  const _NavigationRail({required this.currentLocation});

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      selectedIndex: _getSelectedIndex(currentLocation),
      onDestinationSelected: (index) {
        _onDestinationSelected(context, index);
      },
      labelType: NavigationRailLabelType.all,
      backgroundColor: Theme.of(context).colorScheme.surface,
      indicatorColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
      destinations: const [
        NavigationRailDestination(
          icon: Icon(Icons.home_outlined),
          selectedIcon: Icon(Icons.home),
          label: Text('Home'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.terminal_outlined),
          selectedIcon: Icon(Icons.terminal),
          label: Text('Terminal'),
        ),
        NavigationRailDestination(
          icon: Icon(Icons.school_outlined),
          selectedIcon: Icon(Icons.school),
          label: Text('Academy'),
        ),
      ],
    );
  }

  int _getSelectedIndex(String location) {
    if (location.startsWith('/terminal')) return 1;
    if (location.startsWith('/academy')) return 2;
    return 0;
  }

  void _onDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/');
        break;
      case 1:
        context.go('/terminal');
        break;
      case 2:
        context.go('/academy');
        break;
    }
  }
}
