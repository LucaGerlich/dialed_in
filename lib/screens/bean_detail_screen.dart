import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';
import '../providers/coffee_provider.dart';
import 'add_shot_screen.dart';
import 'add_bean_screen.dart';
import 'shot_detail_screen.dart';

class BeanDetailScreen extends StatefulWidget {
  final String beanId;

  const BeanDetailScreen({super.key, required this.beanId});

  @override
  State<BeanDetailScreen> createState() => _BeanDetailScreenState();
}

class _BeanDetailScreenState extends State<BeanDetailScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<CoffeeProvider>(
      builder: (context, provider, child) {
        final bean = provider.beans.firstWhere((b) => b.id == widget.beanId);
        final shots = bean.shots;

        // Calculate Stats
        final totalBrews = shots.length;
        final avgDose = shots.isEmpty
            ? 0.0
            : shots.map((s) => s.doseIn).reduce((a, b) => a + b) / totalBrews;
        final avgYield = shots.isEmpty
            ? 0.0
            : shots.map((s) => s.doseOut).reduce((a, b) => a + b) / totalBrews;

        return Scaffold(
          appBar: AppBar(
            title: Text(
              bean.name,
              style: TextStyle(
                fontFamily: 'RobotoMono',
                fontWeight: FontWeight.bold,
              ),
            ),
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
                  _confirmDelete(context, provider, bean);
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              16,
              16,
              16,
              16 + 56 + 16 + MediaQuery.of(context).padding.bottom,
            ), // 16 for standard, 56 for FAB height, 16 for margin
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bean Info Bento
                _buildBentoContainer(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ORIGIN',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        bean.origin.isEmpty ? 'Unknown' : bean.origin,
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildTag(context, bean.roastLevel),
                          const SizedBox(width: 8),
                          if (bean.process.isNotEmpty)
                            _buildTag(context, bean.process),
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
                                Text(
                                  'ROAST DATE',
                                  style: TextStyle(
                                    fontFamily: 'RobotoMono',
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  DateFormat(
                                    'MMM d, yyyy',
                                  ).format(bean.roastDate!),
                                  style: TextStyle(
                                    fontFamily: 'RobotoMono',
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onSurface,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  'RESTING',
                                  style: TextStyle(
                                    fontFamily: 'RobotoMono',
                                    color: Theme.of(context)
                                        .colorScheme
                                        .onSurface
                                        .withValues(alpha: 0.6),
                                    fontSize: 12,
                                  ),
                                ),
                                Text(
                                  '${DateTime.now().difference(bean.roastDate!).inDays} days',
                                  style: TextStyle(
                                    fontFamily: 'RobotoMono',
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                      ],
                      Text(
                        'NOTES',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                      Text(
                        bean.notes,
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.7),
                        ),
                      ),
                      if (bean.flavourTags.isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Text(
                          'FLAVORS',
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          children: bean.flavourTags.map((tag) {
                            return Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  fontFamily: 'RobotoMono',
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onPrimary,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                      if ((bean.arabicaPercentage > 0 && bean.arabicaPercentage < 100) || bean.robustaPercentage > 0) ...[
                        const SizedBox(height: 12),
                        Text(
                          'COMPOSITION',
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            if (bean.arabicaPercentage > 0) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Text(
                                  'Arabica ${bean.arabicaPercentage.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontFamily: 'RobotoMono',
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            if (bean.robustaPercentage > 0) ...[
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 10,
                                  vertical: 6,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
                                  ),
                                ),
                                child: Text(
                                  'Robusta ${bean.robustaPercentage.toStringAsFixed(0)}%',
                                  style: TextStyle(
                                    fontFamily: 'RobotoMono',
                                    color: Theme.of(context).colorScheme.primary,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Stats Row
                Row(
                  children: [
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'BREWS',
                        totalBrews.toString(),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'AVG IN',
                        '${avgDose.toStringAsFixed(1)}g',
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _buildStatCard(
                        context,
                        'AVG OUT',
                        '${avgYield.toStringAsFixed(1)}g',
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Flavor Wheel (Radar Chart)
                _buildBentoContainer(
                  context,
                  height: 300,
                  child: Column(
                    children: [
                      Text(
                        'FLAVOR PROFILE',
                        style: TextStyle(
                          fontFamily: 'RobotoMono',
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.6),
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Expanded(
                        child: RadarChart(
                          RadarChartData(
                            dataSets: [
                              RadarDataSet(
                                fillColor: Theme.of(
                                  context,
                                ).colorScheme.primary.withValues(alpha: 0.3),
                                borderColor: Theme.of(
                                  context,
                                ).colorScheme.primary,
                                entryRadius: 2,
                                dataEntries: [
                                  RadarEntry(value: bean.acidity),
                                  RadarEntry(value: bean.body),
                                  RadarEntry(value: bean.sweetness),
                                  RadarEntry(value: bean.bitterness),
                                  RadarEntry(value: bean.aftertaste),
                                ],
                                borderWidth: 2,
                              ),
                            ],
                            radarBackgroundColor: Colors.transparent,
                            borderData: FlBorderData(show: false),
                            radarBorderData: const BorderSide(
                              color: Colors.transparent,
                            ),
                            titlePositionPercentageOffset: 0.2,
                            titleTextStyle: TextStyle(
                              fontFamily: 'RobotoMono',
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.6),
                              fontSize: 10,
                            ),
                            getTitle: (index, angle) {
                              switch (index) {
                                case 0:
                                  return RadarChartTitle(
                                    text: 'Acidity',
                                    angle: angle,
                                  );
                                case 1:
                                  return RadarChartTitle(
                                    text: 'Body',
                                    angle: angle,
                                  );
                                case 2:
                                  return RadarChartTitle(
                                    text: 'Sweetness',
                                    angle: angle,
                                  );
                                case 3:
                                  return RadarChartTitle(
                                    text: 'Bitterness',
                                    angle: angle,
                                  );
                                case 4:
                                  return RadarChartTitle(
                                    text: 'Aftertaste',
                                    angle: angle,
                                  );
                                default:
                                  return const RadarChartTitle(text: '');
                              }
                            },
                            tickCount: 5,
                            ticksTextStyle: const TextStyle(
                              color: Colors.transparent,
                              fontSize: 0.0,
                            ), // Hide ticks
                            tickBorderData: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.1),
                            ),
                            gridBorderData: BorderSide(
                              color: Theme.of(
                                context,
                              ).colorScheme.onSurface.withValues(alpha: 0.1),
                              width: 1,
                            ),
                          ),
                          duration: const Duration(milliseconds: 150),
                          curve: Curves.linear,
                        ),
                      ),
                    ],
                  ),
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
                        Text(
                          'GRIND SIZE OVER TIME',
                          style: TextStyle(
                            fontFamily: 'RobotoMono',
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: LineChart(
                            LineChartData(
                              lineTouchData: LineTouchData(
                                enabled: true,
                                touchTooltipData: LineTouchTooltipData(
                                  getTooltipColor: (touchedSpot) =>
                                      Theme.of(context).colorScheme.surface,
                                  tooltipPadding: const EdgeInsets.symmetric(
                                    horizontal: 12,
                                    vertical: 8,
                                  ),
                                  tooltipBorder: BorderSide(
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.3),
                                    width: 1,
                                  ),
                                  getTooltipItems: (touchedSpots) {
                                    return touchedSpots.map((spot) {
                                      final shotIndex = spot.x.toInt();
                                      final shot = shots[shotIndex];
                                      return LineTooltipItem(
                                        'Shot #${shotIndex + 1}\n',
                                        TextStyle(
                                          fontFamily: 'RobotoMono',
                                          color: Theme.of(context)
                                              .colorScheme
                                              .onSurface
                                              .withValues(alpha: 0.6),
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        children: [
                                          TextSpan(
                                            text:
                                                '${shot.grindSize.toStringAsFixed(1)}',
                                            style: TextStyle(
                                              fontFamily: 'RobotoMono',
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                          TextSpan(
                                            text:
                                                '\n${DateFormat('MMM d, HH:mm').format(shot.timestamp)}',
                                            style: TextStyle(
                                              fontFamily: 'RobotoMono',
                                              color: Theme.of(context)
                                                  .colorScheme
                                                  .onSurface
                                                  .withValues(alpha: 0.5),
                                              fontSize: 9,
                                            ),
                                          ),
                                        ],
                                      );
                                    }).toList();
                                  },
                                ),
                              ),
                              gridData: FlGridData(
                                show: true,
                                drawVerticalLine: false,
                                getDrawingHorizontalLine: (value) => FlLine(
                                  color: Theme.of(context).colorScheme.onSurface
                                      .withValues(alpha: 0.05),
                                  strokeWidth: 1,
                                ),
                              ),
                              titlesData: const FlTitlesData(show: false),
                              borderData: FlBorderData(show: false),
                              lineBarsData: [
                                LineChartBarData(
                                  spots: shots.asMap().entries.map((e) {
                                    return FlSpot(
                                      e.key.toDouble(),
                                      e.value.grindSize,
                                    );
                                  }).toList(),
                                  isCurved: true,
                                  color: Theme.of(context).colorScheme.primary,
                                  barWidth: 3,
                                  dotData: FlDotData(
                                    show: false,
                                    getDotPainter:
                                        (spot, percent, barData, index) =>
                                            FlDotCirclePainter(
                                              radius: 6,
                                              color: Theme.of(
                                                context,
                                              ).colorScheme.primary,
                                              strokeWidth: 2,
                                              strokeColor: Theme.of(
                                                context,
                                              ).colorScheme.surface,
                                            ),
                                  ),
                                  belowBarData: BarAreaData(
                                    show: true,
                                    color: Theme.of(context).colorScheme.primary
                                        .withValues(alpha: 0.1),
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
                Text(
                  'HISTORY',
                  style: TextStyle(
                    fontFamily: 'RobotoMono',
                    fontWeight: FontWeight.bold,
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
                const SizedBox(height: 8),
                ...shots.map((shot) {
                  final machine = provider.machines.firstWhere(
                    (m) => m.id == shot.machineId,
                    orElse: () => CoffeeMachine(name: 'Unknown', id: ''),
                  );
                  final grinder = provider.grinders.firstWhere(
                    (g) => g.id == shot.grinderId,
                    orElse: () => Grinder(name: 'Unknown', id: ''),
                  );

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              ShotDetailScreen(shot: shot, bean: bean),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withValues(alpha: 0.05),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                DateFormat(
                                  'MMM d, HH:mm',
                                ).format(shot.timestamp),
                                style: TextStyle(
                                  fontFamily: 'RobotoMono',
                                  color: Colors.grey,
                                  fontSize: 12,
                                ),
                              ),
                              Text(
                                shot.grindSize.toStringAsFixed(1),
                                style: TextStyle(
                                  fontFamily: 'RobotoMono',
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
                              Text(
                                '${shot.doseIn}g -> ${shot.doseOut}g',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                              Text(
                                '${shot.duration}s',
                                style: TextStyle(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                ),
                              ),
                            ],
                          ),
                          if (machine.name != 'Unknown' ||
                              grinder.name != 'Unknown') ...[
                            const SizedBox(height: 8),
                            Text(
                              '${machine.name} • ${grinder.name}',
                              style: TextStyle(
                                fontFamily: 'RobotoMono',
                                color: Colors.grey[600],
                                fontSize: 10,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddShotScreen(beanId: widget.beanId),
                ),
              );
            },
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            child: const Icon(Icons.add),
          ),
          floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        );
      },
    );
  }

  void _confirmDelete(
    BuildContext context,
    CoffeeProvider provider,
    Bean bean,
  ) {
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

  Widget _buildBentoContainer(
    BuildContext context, {
    required Widget child,
    double? height,
  }) {
    return Container(
      width: double.infinity,
      height: height,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.05),
        ),
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
        border: Border.all(
          color: Theme.of(
            context,
          ).colorScheme.onSurface.withValues(alpha: 0.05),
        ),
      ),
      child: Column(
        children: [
          Text(
            label,
            style: TextStyle(
              fontFamily: 'RobotoMono',
              color: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: 0.6),
              fontSize: 10,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontFamily: 'RobotoMono',
              color: Theme.of(context).colorScheme.onSurface,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTag(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5),
        ),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(
          fontFamily: 'RobotoMono',
          color: Theme.of(context).colorScheme.primary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
