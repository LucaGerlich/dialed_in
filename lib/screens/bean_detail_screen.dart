import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:fl_chart/fl_chart.dart';
import '../models/models.dart';
import '../providers/coffee_provider.dart';
import 'add_shot_screen.dart';

class BeanDetailScreen extends StatelessWidget {
  final String beanId;

  const BeanDetailScreen({super.key, required this.beanId});

  @override
  Widget build(BuildContext context) {
    return Consumer<CoffeeProvider>(
      builder: (context, provider, child) {
        final bean = provider.beans.firstWhere(
          (b) => b.id == beanId,
          orElse: () => Bean(name: 'Deleted'),
        );

        if (bean.name == 'Deleted') {
          return const Scaffold(body: Center(child: Text('Bean not found')));
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(bean.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(context, provider, bean),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Top Section: Image + Info (Bento Item 1)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.white.withOpacity(0.1)),
                  ),
                  child: Column(
                    children: [
                      Container(
                        height: 100,
                        width: 80,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.05),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.coffee,
                          size: 40,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        bean.name,
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(fontSize: 24),
                        textAlign: TextAlign.center,
                      ),
                      if (bean.notes.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        Text(
                          bean.notes,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                color: Colors.grey[400],
                              ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Graph Section (Bento Item 2)
                if (bean.shots.isNotEmpty)
                  Container(
                    height: 250,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: Colors.white.withOpacity(0.1)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Grind Size Over Time',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 20),
                        Expanded(
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) {
                                  return FlLine(
                                    color: Colors.white.withOpacity(0.05),
                                    strokeWidth: 1,
                                  );
                                },
                              ),
                              titlesData: const FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: _getSpots(bean.shots),
                                  isCurved: true,
                                  color: Theme.of(context).colorScheme.primary,
                                  barWidth: 3,
                                  isStrokeCapRound: true,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, barData, index) {
                                      return FlDotCirclePainter(
                                        radius: 4,
                                        color: Theme.of(context).colorScheme.primary,
                                        strokeWidth: 2,
                                        strokeColor: Colors.black,
                                      );
                                    },
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 16),

                // Shots List (Bento Item 3)
                Text(
                  'Shots',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 12),
                ...bean.shots.reversed.map((shot) => Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Row(
                        children: [
                          CircleAvatar(
                            backgroundColor: Theme.of(context).colorScheme.primary.withOpacity(0.2),
                            child: Text(
                              shot.grindSize.toString(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${shot.doseIn}g in → ${shot.doseOut}g out',
                                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontSize: 16),
                                ),
                                Text(
                                  '${shot.duration}s • ${DateFormat.MMMd().format(shot.timestamp)}',
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    )),
                const SizedBox(height: 80), // Space for FAB
              ],
            ),
          ),
          floatingActionButton: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: FloatingActionButton.extended(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => AddShotScreen(beanId: bean.id),
                  ),
                );
              },
              label: const Text('Log New Shot'),
              icon: const Icon(Icons.add),
              backgroundColor: Theme.of(context).colorScheme.primary,
              foregroundColor: Theme.of(context).colorScheme.onPrimary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            ),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        );
      },
    );
  }

  List<FlSpot> _getSpots(List<Shot> shots) {
    return shots
        .asMap()
        .entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.grindSize))
        .toList();
  }

  void _confirmDelete(BuildContext context, CoffeeProvider provider, Bean bean) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Bean?'),
        content: const Text('This will delete the bean and all its shots.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              provider.deleteBean(bean.id);
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
