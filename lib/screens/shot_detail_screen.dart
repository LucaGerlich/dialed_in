import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import '../models/models.dart';
import '../providers/coffee_provider.dart';
import 'share_shot_dialog.dart';

class ShotDetailScreen extends StatelessWidget {
  final Shot shot;
  final Bean bean;

  const ShotDetailScreen({
    super.key,
    required this.shot,
    required this.bean,
  });

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<CoffeeProvider>(
      builder: (context, provider, child) {
        // Resolve machine and grinder names
        final machine = provider.machines.firstWhere(
          (m) => m.id == shot.machineId,
          orElse: () => CoffeeMachine(name: 'Unknown', id: ''),
        );
        final grinder = provider.grinders.firstWhere(
          (g) => g.id == shot.grinderId,
          orElse: () => Grinder(name: 'Unknown', id: ''),
        );

        return Scaffold(
          appBar: AppBar(
            title: Text(
              DateFormat('MMM d, HH:mm').format(shot.timestamp),
              style: TextStyle(fontFamily: 'RobotoMono',fontWeight: FontWeight.bold),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.ios_share),
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (context) => ShareShotDialog(
                      shot: shot,
                      bean: bean,
                      machineName: machine.name != 'Unknown' ? machine.name : null,
                      grinderName: grinder.name != 'Unknown' ? grinder.name : null,
                    ),
                  );
                },
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _confirmDelete(context, provider),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bean Context
                _buildBentoContainer(
                  context,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(l10n.bean, style: TextStyle(fontFamily: 'RobotoMono', color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12)),
                      Text(
                        bean.name,
                        style: TextStyle(fontFamily: 'RobotoMono',
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (bean.origin.isNotEmpty)
                        Text(
                          bean.origin.toUpperCase(),
                          style: TextStyle(fontFamily: 'RobotoMono', color: Theme.of(context).colorScheme.onSurface, fontSize: 16),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _buildTag(context, bean.roastLevel),
                          const SizedBox(width: 8),
                          if (bean.process.isNotEmpty) _buildTag(context, bean.process),
                        ],
                      ),
                      if (bean.roastDate != null) ...[
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${l10n.roasted} ${DateFormat('MMM d').format(bean.roastDate!)}',
                              style: TextStyle(fontFamily: 'RobotoMono', color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12),
                            ),
                            Text(
                              '${l10n.resting}: ${shot.timestamp.difference(bean.roastDate!).inDays} DAYS',
                              style: TextStyle(fontFamily: 'RobotoMono',
                                color: Theme.of(context).colorScheme.primary,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Main Stats Grid
                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  childAspectRatio: 1.4,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  children: [
                    _buildStatCard(context, l10n.grindSize, shot.grindSize.toStringAsFixed(1), Icons.settings),
                    _buildStatCard(context, l10n.time, '${shot.duration}s', Icons.timer),
                    _buildStatCard(context, l10n.doseIn, '${shot.doseIn}g', Icons.arrow_downward),
                    _buildStatCard(context, l10n.doseOut, '${shot.doseOut}g', Icons.water_drop),
                  ],
                ),
                const SizedBox(height: 12),
                // Ratio Card (Full Width)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.aspect_ratio, color: Theme.of(context).colorScheme.primary, size: 20),
                          const SizedBox(width: 12),
                          Text(l10n.brewRatio, style: TextStyle(fontFamily: 'RobotoMono', color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12)),
                        ],
                      ),
                      Text(
                        '1 : ${(shot.doseOut / shot.doseIn).toStringAsFixed(1)}',
                        style: TextStyle(fontFamily: 'RobotoMono',
                          color: Theme.of(context).colorScheme.onSurface,
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),

                // Advanced Stats (if any exist)
                if (_hasAdvancedStats(shot)) ...[
                  Text(
                    l10n.extractionParameters,
                    style: TextStyle(fontFamily: 'RobotoMono', color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildBentoContainer(
                    context,
                    child: Column(
                      children: [
                        if (shot.pressure != null)
                          _buildRowItem(context, l10n.pressure, '${shot.pressure!.toStringAsFixed(1)} bar'),
                        if (shot.temperature != null)
                          _buildRowItem(context, l10n.temp, '${shot.temperature!.toStringAsFixed(1)}°C'),
                        if (shot.preInfusionTime != null && shot.preInfusionTime! > 0)
                          _buildRowItem(context, l10n.preInfusion, '${shot.preInfusionTime}s'),
                        if (shot.grinderRpm != null && shot.grinderRpm! > 0)
                          _buildRowItem(context, l10n.rpm, shot.grinderRpm!.toStringAsFixed(0)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Gear
                if (machine.name != 'Unknown' || grinder.name != 'Unknown' || shot.water != null) ...[
                  Text(
                    l10n.gear,
                    style: TextStyle(fontFamily: 'RobotoMono', color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildBentoContainer(
                    context,
                    child: Column(
                      children: [
                        if (machine.name != 'Unknown')
                          _buildRowItem(context, l10n.machine, machine.name),
                        if (grinder.name != 'Unknown')
                          _buildRowItem(context, l10n.grinder, grinder.name),
                        if (shot.water != null)
                          _buildRowItem(context, l10n.water, shot.water!),
                      ],
                    ),
                  ),
                   const SizedBox(height: 24),
                ],

                // Taste Profile
                if (shot.flavourX != null && shot.flavourY != null) ...[
                   Text(
                    l10n.tasteProfile,
                    style: TextStyle(fontFamily: 'RobotoMono', color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
                      ),
                      child: Stack(
                        children: [
                          // Labels
                          Align(alignment: Alignment.topCenter, child: Padding(padding: const EdgeInsets.all(8.0), child: Text(l10n.strong, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))))),
                          Align(alignment: Alignment.bottomCenter, child: Padding(padding: const EdgeInsets.all(8.0), child: Text(l10n.weak, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))))),
                          Align(alignment: Alignment.centerLeft, child: Padding(padding: const EdgeInsets.all(8.0), child: RotatedBox(quarterTurns: -1, child: Text(l10n.sour, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)))))),
                          Align(alignment: Alignment.centerRight, child: Padding(padding: const EdgeInsets.all(8.0), child: RotatedBox(quarterTurns: 1, child: Text(l10n.bitter, style: TextStyle(fontSize: 10, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6)))))),
                          
                          // Grid Lines
                          Center(child: Container(width: double.infinity, height: 1, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1))),
                          Center(child: Container(width: 1, height: double.infinity, color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1))),

                          // The Dot
                          Align(
                            alignment: Alignment(shot.flavourX!, shot.flavourY!),
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Theme.of(context).colorScheme.surface, width: 2),
                                boxShadow: [
                                  BoxShadow(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5), blurRadius: 8, spreadRadius: 2)
                                ]
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }

  bool _hasAdvancedStats(Shot shot) {
    return shot.pressure != null ||
        shot.temperature != null ||
        (shot.preInfusionTime != null && shot.preInfusionTime! > 0) ||
        (shot.grinderRpm != null && shot.grinderRpm! > 0);
  }

  Widget _buildStatCard(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(fontFamily: 'RobotoMono', color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6), fontSize: 10)),
          const SizedBox(height: 4),
          Text(value, style: TextStyle(fontFamily: 'RobotoMono', color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold, fontSize: 18)),
        ],
      ),
    );
  }

  Widget _buildBentoContainer(BuildContext context, {required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.05)),
      ),
      child: child,
    );
  }

  Widget _buildRowItem(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontFamily: 'RobotoMono', color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.6))),
          Text(value, style: TextStyle(fontFamily: 'RobotoMono', color: Theme.of(context).colorScheme.onSurface, fontWeight: FontWeight.bold)),
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
        border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.5)),
      ),
      child: Text(
        text.toUpperCase(),
        style: TextStyle(fontFamily: 'RobotoMono',
          color: Theme.of(context).colorScheme.primary,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _confirmDelete(BuildContext context, CoffeeProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.deleteShotTitle),
        content: Text(l10n.deleteShotMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l10n.cancel),
          ),
          TextButton(
            onPressed: () {
              // To delete a shot, we need to update the bean.
              // The provider doesn't have a direct deleteShot method yet (only updateBean).
              // Let's do it manually here or add a helper in Provider.
              // Doing it manually via updateBean:
              
              final updatedShots = List<Shot>.from(bean.shots)..removeWhere((s) => s.id == shot.id);
              
              final updatedBean = Bean(
                id: bean.id,
                name: bean.name,
                notes: bean.notes,
                preferredGrindSize: bean.preferredGrindSize,
                shots: updatedShots,
                origin: bean.origin,
                roastLevel: bean.roastLevel,
                process: bean.process,
                flavourTags: bean.flavourTags,
                roastDate: bean.roastDate,
              );
              
              provider.updateBean(updatedBean);
              
              Navigator.pop(ctx); // Close dialog
              Navigator.pop(context); // Close ShotDetailScreen
            },
            child: Text(l10n.delete, style: const TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
