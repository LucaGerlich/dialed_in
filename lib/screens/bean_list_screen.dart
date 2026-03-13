import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../l10n/app_localizations.dart';
import '../providers/coffee_provider.dart';
import '../utils/page_transitions.dart';
import '../widgets/bean_card.dart';
import '../widgets/bean_card_compact.dart';
import '../widgets/dripping_coffee_icon.dart';
import 'bean_detail_screen.dart';

class BeanListScreen extends StatefulWidget {
  final bool isCompactView;
  final String sortBy;
  final ValueChanged<BeanListScreenState>? onStateCreated;

  const BeanListScreen({
    super.key,
    this.isCompactView = false,
    this.sortBy = 'Ranking',
    this.onStateCreated,
  });

  @override
  BeanListScreenState createState() => BeanListScreenState();
}

class BeanListScreenState extends State<BeanListScreen>
    with SingleTickerProviderStateMixin {
  String _selectedFilter = 'All';
  late AnimationController _listAnimationController;

  @override
  void initState() {
    super.initState();
    _listAnimationController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _listAnimationController.forward();
    widget.onStateCreated?.call(this);
  }

  @override
  void dispose() {
    _listAnimationController.dispose();
    super.dispose();
  }

  void restartListAnimation() {
    _listAnimationController.reset();
    _listAnimationController.forward();
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

    return Consumer<CoffeeProvider>(
      builder: (context, provider, child) {
        var beans = provider.beans.where((bean) {
          if (_selectedFilter == l10n.filterAll) return true;
          if (_selectedFilter == l10n.filterLight)
            return bean.roastLevel == 'Light';
          if (_selectedFilter == l10n.filterMedium)
            return bean.roastLevel == 'Medium';
          if (_selectedFilter == l10n.filterDark)
            return bean.roastLevel == 'Dark';
          return true;
        }).toList();

        if (widget.sortBy == l10n.sortRanking) {
          beans.sort((a, b) => b.ranking.compareTo(a.ranking));
        }

        final topPadding = MediaQuery.of(context).viewPadding.top + 56;

        return Column(
          children: [
            // Filter Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: EdgeInsets.fromLTRB(16, topPadding + 12, 16, 12),
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
                        restartListAnimation();
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
                  : widget.isCompactView
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
