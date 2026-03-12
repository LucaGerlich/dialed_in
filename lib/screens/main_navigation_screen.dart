import 'package:flutter/material.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import '../l10n/app_localizations.dart';
import 'bean_list_screen.dart';
import 'maintenance_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    BeanListScreen(),
    MaintenanceScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AdaptiveScaffold(
      useHeroBackButton: false,
      bottomNavigationBar: AdaptiveBottomNavigationBar(
        selectedIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: [
          AdaptiveNavigationDestination(
            icon: 'cup.and.saucer',
            selectedIcon: 'cup.and.saucer.fill',
            label: l10n.beanVault,
          ),
          AdaptiveNavigationDestination(
            icon: 'wrench',
            selectedIcon: 'wrench.fill',
            label: 'Maintenance',
          ),
        ],
      ),
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 200),
        child: KeyedSubtree(
          key: ValueKey(_currentIndex),
          child: _screens[_currentIndex],
        ),
      ),
    );
  }
}
