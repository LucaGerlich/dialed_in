import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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
  final List<String> _filters = ['All', 'Light', 'Medium', 'Dark'];
  String _sortBy = 'Ranking';
  final List<String> _sortOptions = ['Default', 'Ranking'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Coffee Collection'),
        leading: const Icon(Icons.coffee), // Aesthetic icon
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.sort),
            tooltip: 'Sort by',
            onSelected: (value) {
              setState(() {
                _sortBy = value;
              });
            },
            itemBuilder: (context) => _sortOptions.map((option) {
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
            if (_selectedFilter == 'All') return true;
            return bean.roastLevel == _selectedFilter;
          }).toList();

          // Sort beans based on selected sort option
          if (_sortBy == 'Ranking') {
            beans.sort((a, b) => b.ranking.compareTo(a.ranking));
          }

          return Column(
            children: [
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: _filters.map((filter) {
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
                        elevation: isSelected ? 4 : 0,
                        shadowColor: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
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
                            width: isSelected ? 2 : 1,
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
                              Icons.coffee,
                              size: 80,
                              color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Your bean collection is empty',
                              style: TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Time to stock up! ☕',
                              style: TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: 16,
                                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6),
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Tap + to add your first coffee',
                              style: TextStyle(
                                fontFamily: 'RobotoMono',
                                fontSize: 14,
                                color: Theme.of(context).colorScheme.primary,
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
