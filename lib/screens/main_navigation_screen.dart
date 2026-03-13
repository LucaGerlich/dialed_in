import 'package:flutter/material.dart';
import 'package:adaptive_platform_ui/adaptive_platform_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../utils/page_transitions.dart';
import 'bean_list_screen.dart';
import 'maintenance_screen.dart';
import 'gear_settings_screen.dart';
import 'add_bean_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  bool _isCompactView = false;
  String _sortBy = 'Ranking';

  BeanListScreenState? _beanListState;

  @override
  void initState() {
    super.initState();
    _loadViewMode();
  }

  Future<void> _loadViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isCompactView = prefs.getBool('beanListCompactView') ?? false;
    });
  }

  Future<void> _toggleViewMode() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _isCompactView = !_isCompactView;
    });
    await prefs.setBool('beanListCompactView', _isCompactView);
  }

  void _showSortMenu(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final sortOptions = [l10n.sortDefault, l10n.sortRanking];

    showModalBottomSheet(
      context: context,
      builder: (ctx) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: sortOptions.map((option) {
            final isSelected = _sortBy == option;
            return ListTile(
              leading: isSelected
                  ? Icon(Icons.check, color: Theme.of(context).colorScheme.primary)
                  : const SizedBox(width: 24),
              title: Text(option),
              onTap: () {
                Navigator.pop(ctx);
                setState(() {
                  _sortBy = option;
                });
                _beanListState?.restartListAnimation();
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  AdaptiveAppBar _buildAppBar(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    switch (_currentIndex) {
      case 0:
        return AdaptiveAppBar(
          title: l10n.beanVault,
          actions: [
            AdaptiveAppBarAction(
              icon: Icons.swap_horiz,
              iosSymbol: 'rectangle.2.swap',
              onPressed: _toggleViewMode,
            ),
            AdaptiveAppBarAction(
              icon: Icons.sort,
              iosSymbol: 'line.3.horizontal.decrease',
              onPressed: () => _showSortMenu(context),
            ),
            AdaptiveAppBarAction(
              icon: Icons.settings,
              iosSymbol: 'gearshape',
              onPressed: () {
                Navigator.push(
                  context,
                  SlidePageRoute(builder: (context) => const GearSettingsScreen()),
                );
              },
            ),
          ],
        );
      case 1:
        return AdaptiveAppBar(
          title: 'Maintenance',
        );
      default:
        return AdaptiveAppBar(title: '');
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return AdaptiveScaffold(
      useHeroBackButton: false,
      appBar: _buildAppBar(context),
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
      floatingActionButton: _currentIndex == 0
          ? AdaptiveButton.child(
              style: AdaptiveButtonStyle.glass,
              size: AdaptiveButtonSize.large,
              onPressed: () {
                Navigator.push(
                  context,
                  FadePageRoute(builder: (context) => const AddBeanScreen()),
                );
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.add, size: 20),
                  SizedBox(width: 8),
                  Text('Add Bean', style: TextStyle(fontFamily: 'RobotoMono', fontWeight: FontWeight.w600)),
                ],
              ),
            )
          : _currentIndex == 1
              ? AdaptiveButton.child(
                  style: AdaptiveButtonStyle.glass,
                  size: AdaptiveButtonSize.large,
                  onPressed: () {
                    MaintenanceScreen.showAddTaskDialog(context);
                  },
                  child: const Icon(Icons.add, size: 20),
                )
              : null,
      body: Material(
        type: MaterialType.transparency,
        child: IndexedStack(
          index: _currentIndex,
          children: [
            BeanListScreen(
              isCompactView: _isCompactView,
              sortBy: _sortBy,
              onStateCreated: (state) => _beanListState = state,
            ),
            const MaintenanceScreen(),
          ],
        ),
      ),
    );
  }
}
