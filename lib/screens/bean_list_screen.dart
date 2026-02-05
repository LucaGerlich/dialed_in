import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../providers/coffee_provider.dart';
import '../widgets/bean_card.dart';
import 'add_bean_screen.dart';
import 'bean_detail_screen.dart';
import 'gear_settings_screen.dart';

class BeanListScreen extends StatefulWidget {
  const BeanListScreen({super.key});

  @override
  State<BeanListScreen> createState() => _BeanListScreenState();
}

class _BeanListScreenState extends State<BeanListScreen> {
  String _selectedFilter = 'All';
  String _sortBy = 'Ranking';

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final filters = [l10n.filterAll, l10n.filterLight, l10n.filterMedium, l10n.filterDark];
    final sortOptions = [l10n.sortDefault, l10n.sortRanking];

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.beanVault),
        leading: const Icon(Icons.coffee), // Aesthetic icon
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: l10n.sortBy,
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
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
                MaterialPageRoute(builder: (context) => const GearSettingsScreen()),
              );
            },
          ),
        ],
      ),
      body: Consumer<CoffeeProvider>(
        builder: (context, provider, child) {
          var beans = provider.beans.where((bean) {
            if (_selectedFilter == l10n.filterAll) return true;
            // Map localized filter names back to data model values
            if (_selectedFilter == l10n.filterLight) return bean.roastLevel == 'Light';
            if (_selectedFilter == l10n.filterMedium) return bean.roastLevel == 'Medium';
            if (_selectedFilter == l10n.filterDark) return bean.roastLevel == 'Dark';
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
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
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
                        },
                        backgroundColor: Theme.of(context).colorScheme.surface,
                        selectedColor: Theme.of(context).colorScheme.primary,
                        labelStyle: TextStyle(
                          color: isSelected ? Theme.of(context).colorScheme.onPrimary : Theme.of(context).colorScheme.onSurface,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(20),
                          side: BorderSide(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1),
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
                            Icon(
                              Icons.coffee_maker_outlined,
                              size: 64,
                              color: Theme.of(context).colorScheme.secondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              l10n.noBeansFound,
                              style: TextStyle(fontFamily: 'RobotoMono',
                                fontSize: 18,
                                color: Theme.of(context).colorScheme.secondary,
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: beans.length,
                        itemBuilder: (context, index) {
                          final bean = beans[index];
                          return BeanCard(
                            bean: bean,
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => BeanDetailScreen(beanId: bean.id),
                                ),
                              );
                            },
                          );
                        },
                      ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddBeanScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
