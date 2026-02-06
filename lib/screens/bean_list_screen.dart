import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../l10n/app_localizations.dart';
import '../providers/coffee_provider.dart';
import '../utils/page_transitions.dart';
import '../widgets/animated_button.dart';
import '../widgets/bean_card.dart';
import '../widgets/bean_card_compact.dart';
import '../widgets/dripping_coffee_icon.dart';
import 'add_bean_screen.dart';
import 'bean_detail_screen.dart';
import 'gear_settings_screen.dart';
import 'maintenance_screen.dart';

class BeanListScreen extends StatefulWidget {
  const BeanListScreen({super.key});

  @override
  State<BeanListScreen> createState() => _BeanListScreenState();
}

class _BeanListScreenState extends State<BeanListScreen>
    with SingleTickerProviderStateMixin {
  String _selectedFilter = 'All';
  String _sortBy = 'Ranking';
  bool _isCompactView = false;
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _loadViewMode();
    _listAnimationController.forward();
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  void _restartListAnimation() {
    _listAnimationController.reset();
    _listAnimationController.forward();
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

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filters = [
      l10n.filterAll,
      l10n.filterLight,
      l10n.filterMedium,
      l10n.filterDark,
    ];
    final sortOptions = [l10n.sortDefault, l10n.sortRanking];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.beanVault),
        leading: Builder(
          builder: (context) => IconButton(
            icon: const Icon(Icons.menu),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(_isCompactView ? Icons.view_list : Icons.grid_view),
            tooltip: l10n.viewMode,
            onPressed: _toggleViewMode,
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: l10n.sortBy,
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
              _restartListAnimation();
            },
            itemBuilder: (context) => sortOptions.map((option) {
              return PopupMenuItem<String>(
                value: option,
                child: Row(
                  children: [
                    if (_sortBy == option)
                      Icon(
                        Icons.check,
                        size: 18,
                        color: Theme.of(context).colorScheme.primary,
                      )
                    else
                      const SizedBox(width: 18),
                    const SizedBox(width: 8),
                    Text(option),
                  ],
                ),
              );
            }).toList(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                SlidePageRoute(
                  builder: (context) => const GearSettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Icon(
                    Icons.coffee,
                    size: 48,
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Dialed In',
                    style: TextStyle(
                      fontFamily: 'RobotoMono',
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: const Icon(Icons.warehouse),
              title: Text(
                l10n.beanVault,
                style: TextStyle(fontFamily: 'RobotoMono'),
              ),
              selected: true,
              onTap: () {
                Navigator.pop(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.build),
              title: const Text(
                'Maintenance', //TODO: add localization later
                style: TextStyle(fontFamily: 'RobotoMono'),
              ),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  SlidePageRoute(
                    builder: (context) => const MaintenanceScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Consumer<CoffeeProvider>(
        builder: (context, provider, child) {
          var beans = provider.beans.where((bean) {
            if (_selectedFilter == l10n.filterAll) return true;
            // Map localized filter names back to data model values
            if (_selectedFilter == l10n.filterLight)
              return bean.roastLevel == 'Light';
            if (_selectedFilter == l10n.filterMedium)
              return bean.roastLevel == 'Medium';
            if (_selectedFilter == l10n.filterDark)
              return bean.roastLevel == 'Dark';
            return true;
          }).toList();

          // Sort beans based on selected sort option
          if (_sortBy == l10n.sortRanking) {
            beans.sort((a, b) => b.ranking.compareTo(a.ranking));
          }

          return Column(
            children: [
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Row(
                  children: filters.map((filter) {
                    final isSelected = _selectedFilter == filter;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChip(
                        label: Text(filter),
                        selected: isSelected,
                        onSelected: (selected) {
                          setState(() {
                            _selectedFilter = filter;
                          });
                          _restartListAnimation();
                        },
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        selectedColor: Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected
                              ? Theme.of(context).colorScheme.onPrimary
                              : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.1),
                          ),
                        ),
                        showCheckmark: false,
                      ),
                    );
                  }).toList(),
                ),
              ),

              // Bean List
              Expanded(
                child: beans.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 800),
                              tween: Tween(begin: 0.0, end: 1.0),
                              curve: Curves.elasticOut,
                              builder: (context, value, child) {
                                return Transform.scale(
                                  scale: value,
                                  child: DrippingCoffeeIcon(
                                    size: 64,
                                    color: Theme.of(context).colorScheme.secondary,
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 24),
                            TweenAnimationBuilder<double>(
                              duration: const Duration(milliseconds: 600),
                              tween: Tween(begin: 0.0, end: 1.0),
                              curve: Curves.easeOut,
                              builder: (context, value, child) {
                                return Opacity(
                                  opacity: value,
                                  child: Transform.translate(
                                    offset: Offset(0, 20 * (1 - value)),
                                    child: Text(
                                      l10n.noBeansFound,
                                      style: TextStyle(
                                        fontFamily: 'RobotoMono',
                                        fontSize: 18,
                                        color: Theme.of(context).colorScheme.secondary,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      )
                    : _isCompactView
                    ? GridView.builder(
                        padding: const EdgeInsets.all(16),
                        gridDelegate:
                            const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 2,
                              childAspectRatio: 0.75,
                              crossAxisSpacing: 12,
                              mainAxisSpacing: 12,
                            ),
                        itemCount: beans.length,
                        itemBuilder: (context, index) {
                          final bean = beans[index];
                          return _AnimatedListItem(
                            controller: _listAnimationController,
                            index: index,
                            totalItems: beans.length,
                            child: BeanCardCompact(
                              bean: bean,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  SlidePageRoute(
                                    builder: (context) =>
                                        BeanDetailScreen(beanId: bean.id),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: beans.length,
                        itemBuilder: (context, index) {
                          final bean = beans[index];
                          return _AnimatedListItem(
                            controller: _listAnimationController,
                            index: index,
                            totalItems: beans.length,
                            child: BeanCard(
                              bean: bean,
                              onTap: () {
                                Navigator.push(
                                  context,
                                  SlidePageRoute(
                                    builder: (context) =>
                                        BeanDetailScreen(beanId: bean.id),
                                  ),
                                );
                              },
                            ),
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: AnimatedButton(
        onPressed: () {
          Navigator.push(
            context,
            FadePageRoute(builder: (context) => const AddBeanScreen()),
          );
        },
        child: FloatingActionButton.extended(
          onPressed: null,
          icon: const Icon(Icons.add),
          label: Text(l10n.addBean),
        ),
      ),
    );
  }
}

class _AnimatedListItem extends StatelessWidget {
  final AnimationController controller;
  final int index;
  final int totalItems;
  final Widget child;

  const _AnimatedListItem({
    required this.controller,
    required this.index,
    required this.totalItems,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final delay = (index * 50).clamp(0, 500) / 1000.0;
    final interval = Interval(
      delay,
      (delay + 0.5).clamp(0.0, 1.0),
      curve: Curves.easeOut,
    );

    return FadeTransition(
      opacity: controller.drive(CurveTween(curve: interval)),
      child: SlideTransition(
        position: controller.drive(
          Tween<Offset>(
            begin: const Offset(0, 0.1),
            end: Offset.zero,
          ).chain(CurveTween(curve: interval)),
        ),
        child: child,
      ),
    );
  }
}
