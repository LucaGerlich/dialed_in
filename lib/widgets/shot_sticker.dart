import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import '../models/models.dart';

class ShotSticker extends StatelessWidget {
  final Shot shot;
  final Bean bean;
  final String? machineName;
  final String? grinderName;

  const ShotSticker({
    super.key,
    required this.shot,
    required this.bean,
    this.machineName,
    this.grinderName,
  });

  @override
  Widget build(BuildContext context) {
    // We use a container with a transparent background for the sticker itself.
    // The Text and Icons will be the only visible parts.
    // We add some shadows to ensure visibility on mixed backgrounds.
    
    final textShadow = [
      Shadow(
        offset: const Offset(0, 1),
        blurRadius: 3.0,
        color: Colors.black.withOpacity(0.8),
      ),
    ];

    return Container(
      width: 350, // Fixed width for consistency
      padding: const EdgeInsets.all(24),
      decoration: const BoxDecoration(
        color: Colors.transparent, 
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Bean Info
          Text(
            bean.name.toUpperCase(),
            style: GoogleFonts.robotoMono(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: const Color(0xFFFF9F0A), // Technical Orange
              shadows: textShadow,
            ),
          ),
          if (bean.origin.isNotEmpty)
            Text(
              bean.origin.toUpperCase(),
              style: GoogleFonts.robotoMono(
                fontSize: 16,
                color: Colors.white,
                shadows: textShadow,
              ),
            ),
          
          const SizedBox(height: 24),

          // Stats Grid
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Grind
              Expanded(
                child: _buildStatItem(
                  label: 'GRIND',
                  value: shot.grindSize.toStringAsFixed(1),
                  icon: Icons.settings,
                  textShadow: textShadow,
                ),
              ),
              // Time
              Expanded(
                child: _buildStatItem(
                  label: 'TIME',
                  value: '${shot.duration}s',
                  icon: Icons.timer,
                  textShadow: textShadow,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Dose
              Expanded(
                child: _buildStatItem(
                  label: 'IN',
                  value: '${shot.doseIn.toStringAsFixed(1)}g',
                  icon: Icons.arrow_downward,
                  textShadow: textShadow,
                ),
              ),
              // Yield
              Expanded(
                child: _buildStatItem(
                  label: 'OUT',
                  value: '${shot.doseOut.toStringAsFixed(1)}g',
                  icon: Icons.water_drop,
                  textShadow: textShadow,
                ),
              ),
            ],
          ),

          const SizedBox(height: 24),

          // Gear (Optional)
          if (machineName != null || grinderName != null) ...[
             Row(
               children: [
                 const Icon(Icons.coffee_maker, color: Colors.white70, size: 16, shadows: [Shadow(blurRadius: 2, color: Colors.black)]),
                 const SizedBox(width: 8),
                 Expanded(
                   child: Text(
                     [machineName, grinderName].whereType<String>().join(' • '),
                     style: GoogleFonts.robotoMono(
                       fontSize: 12,
                       color: Colors.white70,
                       shadows: textShadow,
                     ),
                     overflow: TextOverflow.ellipsis,
                   ),
                 ),
               ],
             ),
             const SizedBox(height: 8),
          ],

          // Footer / Branding
          const Divider(color: Colors.white54),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DIALED IN',
                style: GoogleFonts.robotoMono(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  color: const Color(0xFFFF9F0A),
                  shadows: textShadow,
                ),
              ),
              Text(
                DateFormat('MMM d, yyyy').format(shot.timestamp),
                style: GoogleFonts.robotoMono(
                  fontSize: 12,
                  color: Colors.white70,
                  shadows: textShadow,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required String label,
    required String value,
    required IconData icon,
    required List<Shadow> textShadow,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: const Color(0xFFFF9F0A), size: 16, shadows: const [Shadow(blurRadius: 2, color: Colors.black)]),
            const SizedBox(width: 4),
            Text(
              label,
              style: GoogleFonts.robotoMono(
                fontSize: 12,
                color: Colors.white70,
                fontWeight: FontWeight.bold,
                shadows: textShadow,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: GoogleFonts.robotoMono(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: textShadow,
          ),
        ),
      ],
    );
  }
}
