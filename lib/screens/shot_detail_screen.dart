import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
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
              style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold),
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
                      Text('BEAN', style: GoogleFonts.robotoMono(color: Colors.grey, fontSize: 12)),
                      Text(
                        bean.name,
                        style: GoogleFonts.robotoMono(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (bean.origin.isNotEmpty)
                        Text(
                          bean.origin.toUpperCase(),
                          style: GoogleFonts.robotoMono(color: Colors.white, fontSize: 16),
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
                              'ROASTED: ${DateFormat('MMM d').format(bean.roastDate!)}',
                              style: GoogleFonts.robotoMono(color: Colors.grey, fontSize: 12),
                            ),
                            Text(
                              'RESTING: ${shot.timestamp.difference(bean.roastDate!).inDays} DAYS',
                              style: GoogleFonts.robotoMono(
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
                    _buildStatCard(context, 'GRIND SIZE', shot.grindSize.toStringAsFixed(1), Icons.settings),
                    _buildStatCard(context, 'TIME', '${shot.duration}s', Icons.timer),
                    _buildStatCard(context, 'DOSE IN', '${shot.doseIn}g', Icons.arrow_downward),
                    _buildStatCard(context, 'DOSE OUT', '${shot.doseOut}g', Icons.water_drop),
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
                    border: Border.all(color: Colors.white.withOpacity(0.05)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.aspect_ratio, color: Theme.of(context).colorScheme.primary, size: 20),
                          const SizedBox(width: 12),
                          Text('BREW RATIO', style: GoogleFonts.robotoMono(color: Colors.grey, fontSize: 12)),
                        ],
                      ),
                      Text(
                        '1 : ${(shot.doseOut / shot.doseIn).toStringAsFixed(1)}',
                        style: GoogleFonts.robotoMono(
                          color: Colors.white,
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
                    'EXTRACTION PARAMETERS',
                    style: GoogleFonts.robotoMono(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildBentoContainer(
                    context,
                    child: Column(
                      children: [
                        if (shot.pressure != null)
                          _buildRowItem('PRESSURE', '${shot.pressure!.toStringAsFixed(1)} bar'),
                        if (shot.temperature != null)
                          _buildRowItem('TEMP', '${shot.temperature!.toStringAsFixed(1)}°C'),
                        if (shot.preInfusionTime != null && shot.preInfusionTime! > 0)
                          _buildRowItem('PRE-INFUSION', '${shot.preInfusionTime}s'),
                        if (shot.grinderRpm != null && shot.grinderRpm! > 0)
                          _buildRowItem('RPM', '${shot.grinderRpm!.toStringAsFixed(0)}'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),
                ],

                // Gear
                if (machine.name != 'Unknown' || grinder.name != 'Unknown') ...[
                  Text(
                    'GEAR',
                    style: GoogleFonts.robotoMono(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  _buildBentoContainer(
                    context,
                    child: Column(
                      children: [
                        if (machine.name != 'Unknown')
                          _buildRowItem('MACHINE', machine.name),
                        if (grinder.name != 'Unknown')
                          _buildRowItem('GRINDER', grinder.name),
                      ],
                    ),
                  ),
                   const SizedBox(height: 24),
                ],

                // Taste Profile
                if (shot.flavourX != null && shot.flavourY != null) ...[
                   Text(
                    'TASTE PROFILE',
                    style: GoogleFonts.robotoMono(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  AspectRatio(
                    aspectRatio: 1,
                    child: Container(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        borderRadius: BorderRadius.circular(24),
                        border: Border.all(color: Colors.white.withOpacity(0.05)),
                      ),
                      child: Stack(
                        children: [
                          // Labels
                          const Align(alignment: Alignment.topCenter, child: Padding(padding: EdgeInsets.all(8.0), child: Text('STRONG', style: TextStyle(fontSize: 10, color: Colors.grey)))),
                          const Align(alignment: Alignment.bottomCenter, child: Padding(padding: EdgeInsets.all(8.0), child: Text('WEAK', style: TextStyle(fontSize: 10, color: Colors.grey)))),
                          const Align(alignment: Alignment.centerLeft, child: Padding(padding: EdgeInsets.all(8.0), child: RotatedBox(quarterTurns: -1, child: Text('SOUR', style: TextStyle(fontSize: 10, color: Colors.grey))))),
                          const Align(alignment: Alignment.centerRight, child: Padding(padding: EdgeInsets.all(8.0), child: RotatedBox(quarterTurns: 1, child: Text('BITTER', style: TextStyle(fontSize: 10, color: Colors.grey))))),
                          
                          // Grid Lines
                          Center(child: Container(width: double.infinity, height: 1, color: Colors.white10)),
                          Center(child: Container(width: 1, height: double.infinity, color: Colors.white10)),

                          // The Dot
                          Align(
                            alignment: Alignment(shot.flavourX!, shot.flavourY!),
                            child: Container(
                              width: 16,
                              height: 16,
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 2),
                                boxShadow: [
                                  BoxShadow(color: Theme.of(context).colorScheme.primary.withOpacity(0.5), blurRadius: 8, spreadRadius: 2)
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
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary, size: 20),
          const SizedBox(height: 8),
          Text(label, style: GoogleFonts.robotoMono(color: Colors.grey, fontSize: 10)),
          const SizedBox(height: 4),
          Text(value, style: GoogleFonts.robotoMono(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
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
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: child,
    );
  }

  Widget _buildRowItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: GoogleFonts.robotoMono(color: Colors.grey)),
          Text(value, style: GoogleFonts.robotoMono(color: Colors.white, fontWeight: FontWeight.bold)),
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

  void _confirmDelete(BuildContext context, CoffeeProvider provider) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Shot?'),
        content: const Text('Are you sure you want to delete this shot record?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
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
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}
