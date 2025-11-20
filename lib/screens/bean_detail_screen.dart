import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/coffee_provider.dart';
import 'add_shot_screen.dart';
import 'add_bean_screen.dart';

class BeanDetailScreen extends StatelessWidget {
  final String beanId;

  const BeanDetailScreen({super.key, required this.beanId});

  @override
  Widget build(BuildContext context) {
    return Consumer<CoffeeProvider>(
      builder: (context, provider, child) {
        final bean = provider.beans.firstWhere((b) => b.id == beanId);
        final shots = bean.shots;

        // Calculate Stats
        final totalBrews = shots.length;
        final avgDose = shots.isEmpty ? 0.0 : shots.map((s) => s.doseIn).reduce((a, b) => a + b) / totalBrews;
        final avgYield = shots.isEmpty ? 0.0 : shots.map((s) => s.doseOut).reduce((a, b) => a + b) / totalBrews;

        return Scaffold(
          appBar: AppBar(
            title: Text(bean.name, style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold)),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddBeanScreen(bean: bean),
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () {
                  provider.deleteBean(bean.id);
                  Navigator.pop(context);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bean Info Bento
                _buildBentoContainer(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('ORIGIN', style: GoogleFonts.robotoMono(color: Colors.grey, fontSize: 12)),
                      Text(bean.origin.isEmpty ? 'Unknown' : bean.origin, style: GoogleFonts.robotoMono(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildTag(context, bean.roastLevel),
                          const SizedBox(width: 8),
                          if (bean.process.isNotEmpty) _buildTag(context, bean.process),
                        ],
                      ),
                      const SizedBox(height: 12),
                      if (bean.roastDate != null) ...[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('ROAST DATE', style: GoogleFonts.robotoMono(color: Colors.grey, fontSize: 12)),
                                Text(
                                  DateFormat('MMM d, yyyy').format(bean.roastDate!),
                                  style: GoogleFonts.robotoMono(color: Colors.white, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text('RESTING', style: GoogleFonts.robotoMono(color: Colors.grey, fontSize: 12)),
                                Text(
                                  '${DateTime.now().difference(bean.roastDate!).inDays} days',
                                  style: GoogleFonts.robotoMono(color: Theme.of(context).colorScheme.primary, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text('NOTES', style: GoogleFonts.robotoMono(color: Colors.grey, fontSize: 12)),
                      Text(bean.notes, style: GoogleFonts.robotoMono(color: Colors.white70)),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Stats Row
                Row(
                  children: [
                    Expanded(child: _buildStatCard(context, 'BREWS', totalBrews.toString())),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard(context, 'AVG IN', '${avgDose.toStringAsFixed(1)}g')),
                    const SizedBox(width: 12),
                    Expanded(child: _buildStatCard(context, 'AVG OUT', '${avgYield.toStringAsFixed(1)}g')),
                  ],
                ),
                const SizedBox(height: 16),

                // Chart Bento
                if (shots.length > 1)
                  _buildBentoContainer(
                    context,
                    height: 250,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('GRIND SIZE OVER TIME', style: GoogleFonts.robotoMono(color: Colors.grey, fontSize: 12)),
                        const SizedBox(height: 16),
                        Expanded(
                          child: LineChart(
                            LineChartData(
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) => FlLine(color: Colors.white.withOpacity(0.05), strokeWidth: 1),
                              ),
                              titlesData: const FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: shots.asMap().entries.map((e) {
                                    return FlSpot(e.key.toDouble(), e.value.grindSize);
                                  }).toList(),
                                  isCurved: true,
                                  color: Theme.of(context).colorScheme.primary,
                                  barWidth: 3,
                                  dotData: FlDotData(
                                    show: true,
                                    getDotPainter: (spot, percent, barData, index) => FlDotCirclePainter(
                                      radius: 4,
                                      color: Theme.of(context).colorScheme.primary,
                                      strokeWidth: 2,
                                      strokeColor: Colors.black,
                                    ),
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

                // Shot List
                Text('HISTORY', style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold, color: Colors.grey)),
                const SizedBox(height: 8),
                ...shots.map((shot) {
                  final machine = provider.machines.firstWhere((m) => m.id == shot.machineId, orElse: () => CoffeeMachine(name: 'Unknown', id: ''));
                  final grinder = provider.grinders.firstWhere((g) => g.id == shot.grinderId, orElse: () => Grinder(name: 'Unknown', id: ''));
                  
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.white.withOpacity(0.05)),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              DateFormat('MMM d, HH:mm').format(shot.timestamp),
                              style: GoogleFonts.robotoMono(color: Colors.grey, fontSize: 12),
                            ),
                            Text(
                              '${shot.grindSize.toStringAsFixed(1)}',
                              style: GoogleFonts.robotoMono(
                                color: Theme.of(context).colorScheme.primary,
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('${shot.doseIn}g -> ${shot.doseOut}g', style: const TextStyle(color: Colors.white)),
                            Text('${shot.duration}s', style: const TextStyle(color: Colors.white)),
                          ],
                        ),
                        if (machine.name != 'Unknown' || grinder.name != 'Unknown') ...[
                          const SizedBox(height: 8),
                          Text(
                            '${machine.name} • ${grinder.name}',
                            style: GoogleFonts.robotoMono(color: Colors.grey[600], fontSize: 10),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
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

  Widget _buildBentoContainer(BuildContext context, {required Widget child, double? height}) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: child,
    );
  }

  Widget _buildStatCard(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        children: [
          Text(label, style: GoogleFonts.robotoMono(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.robotoMono(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
        ],
      ),
    );
  }

  Widget _buildTag(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.primary.withOpacity(0.5)),
      ),
      child: Text(
        text.toUpperCase(),
        style: GoogleFonts.robotoMono(
          color: Theme.of(context).colorScheme.primary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
