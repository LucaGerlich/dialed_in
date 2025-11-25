import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/models.dart';
import '../providers/coffee_provider.dart';
import '../widgets/analog_dial.dart';

class AddShotScreen extends StatefulWidget {
  final String beanId;

  const AddShotScreen({super.key, required this.beanId});

  @override
  State<AddShotScreen> createState() => _AddShotScreenState();
}

class _AddShotScreenState extends State<AddShotScreen> {
  final _doseInController = TextEditingController(text: '18.0');
  final _doseOutController = TextEditingController(text: '36.0');
  final _durationController = TextEditingController(text: '00:00.0');
  
  // Advanced Params Controllers
  final _rpmController = TextEditingController();
  final _pressureController = TextEditingController();
  final _tempController = TextEditingController();
  final _preInfusionController = TextEditingController();
  final _waterController = TextEditingController();

  double _grindSize = 10.0;
  int _durationMs = 0; // Duration in milliseconds
  Timer? _timer;
  bool _isTimerRunning = false;
  final bool _updatePreferred = false; // Fixed: made final as it's never changed
  
  String? _selectedMachineId;
  String? _selectedGrinderId;
  
  // Flavour Coordinates (-1 to 1)
  double _flavourX = 0;
  double _flavourY = 0;

  @override
  void dispose() {
    _doseInController.dispose();
    _doseOutController.dispose();
    _durationController.dispose();
    _rpmController.dispose();
    _pressureController.dispose();
    _tempController.dispose();
    _preInfusionController.dispose();
    _waterController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _toggleTimer() {
    if (_isTimerRunning) {
      _timer?.cancel();
      setState(() {
        _isTimerRunning = false;
      });
    } else {
      setState(() {
        _isTimerRunning = true;
        _durationMs = 0; // Reset duration
        _durationController.text = _formatDuration(_durationMs);
      });
      _timer = Timer.periodic(const Duration(milliseconds: 100), (timer) { // Update faster
        setState(() {
          _durationMs += 100; // Increment by 100ms
          _durationController.text = _formatDuration(_durationMs);
        });
      });
    }
  }

  void _onDurationChanged(String value) {
    if (_isTimerRunning) return; // Don't parse while timer is running
    
    int newDurationMs = 0;
    try {
      if (value.contains(':')) {
        final parts = value.split(':');
        int minutes = 0;
        int seconds = 0;
        int milliseconds = 0;

        if (parts.length >= 2) {
          minutes = int.tryParse(parts[0]) ?? 0;
          
          if (parts[1].contains('.')) {
            final secParts = parts[1].split('.');
            seconds = int.tryParse(secParts[0]) ?? 0;
            milliseconds = int.tryParse(secParts[1].padRight(3, '0')) ?? 0;
            // Only take first 3 digits for ms
            if (milliseconds > 999) milliseconds = int.parse(milliseconds.toString().substring(0,3));

          } else {
            seconds = int.tryParse(parts[1]) ?? 0;
          }
        } else if (parts.length == 1 && value.contains('.')) { // e.g., "30.5"
             final secParts = parts[0].split('.');
            seconds = int.tryParse(secParts[0]) ?? 0;
            milliseconds = int.tryParse(secParts[1].padRight(3, '0')) ?? 0;
            if (milliseconds > 999) milliseconds = int.parse(milliseconds.toString().substring(0,3));
        }


        newDurationMs = minutes * 60 * 1000 + seconds * 1000 + milliseconds;

      } else if (value.contains('.')) { // e.g., "30.5" or ".5"
        final secParts = value.split('.');
        int seconds = int.tryParse(secParts[0]) ?? 0;
        int milliseconds = int.tryParse(secParts[1].padRight(3, '0')) ?? 0;
        if (milliseconds > 999) milliseconds = int.parse(milliseconds.toString().substring(0,3));
        newDurationMs = seconds * 1000 + milliseconds;

      } else {
        newDurationMs = (int.tryParse(value) ?? 0) * 1000;
      }
    } catch (e) {
      // Ignore parsing errors for now, keep old duration
      newDurationMs = _durationMs;
    }
    
    setState(() {
      _durationMs = newDurationMs;
      // Ensure the displayed text matches the parsed duration (e.g. if user types 30, it becomes 00:30.0)
      _durationController.text = _formatDuration(_durationMs);
      // Move cursor to end
      _durationController.selection = TextSelection.fromPosition(
        TextPosition(offset: _durationController.text.length)
      );
    });
  }

  void _saveShot() {
    final doseIn = double.tryParse(_doseInController.text) ?? 0;
    final doseOut = double.tryParse(_doseOutController.text) ?? 0;

    if (doseIn > 0 && doseOut > 0 && _durationMs > 0) {
      final shot = Shot(
        grindSize: _grindSize,
        doseIn: doseIn,
        doseOut: doseOut,
        duration: _durationMs ~/ 1000, // Convert back to seconds for Shot model
        timestamp: DateTime.now(),
        grinderRpm: double.tryParse(_rpmController.text),
        pressure: double.tryParse(_pressureController.text),
        temperature: double.tryParse(_tempController.text),
        preInfusionTime: int.tryParse(_preInfusionController.text),
        machineId: _selectedMachineId,
        grinderId: _selectedGrinderId,
        water: _waterController.text.isNotEmpty ? _waterController.text : null,
        flavourX: _flavourX,
        flavourY: _flavourY,
      );

      Provider.of<CoffeeProvider>(context, listen: false).addShot(
        widget.beanId,
        shot,
        updatePreferredGrind: _updatePreferred,
      );
      Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill in all fields')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<CoffeeProvider>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dial-In'),
      ),
      body: Stack(
        children: [
          // Expanded Dial Area (Background)
          Positioned.fill(
            bottom: 150, // Reserve space for the minimized sheet header
            child: Center(
              child: AnalogDial(
                value: _grindSize,
                min: provider.grindMin,
                max: provider.grindMax,
                step: provider.grindStep,
                label: 'Grind Size',
                onChanged: (val) {
                  setState(() {
                    _grindSize = val;
                  });
                },
              ),
            ),
          ),

          // Draggable Bottom Sheet
          DraggableScrollableSheet(
            initialChildSize: 0.5,
            minChildSize: 0.4,
            maxChildSize: 0.92,
            builder: (context, scrollController) {
              return Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                  border: Border(top: BorderSide(color: Colors.white.withValues(alpha: 0.1))),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.5),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Drag Handle
                      Center(
                        child: Container(
                          width: 40,
                          height: 4,
                          margin: const EdgeInsets.only(bottom: 24),
                          decoration: BoxDecoration(
                            color: Colors.grey[600],
                            borderRadius: BorderRadius.circular(2),
                          ),
                        ),
                      ),

                      // Timer Row
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                    width: 180,
                                    child: TextField(
                                      controller: _durationController,
                                      enabled: !_isTimerRunning,
                                      onChanged: _onDurationChanged,
                                      textAlign: TextAlign.center,
                                      style: GoogleFonts.robotoMono(
                                        fontSize: 32,
                                        fontWeight: FontWeight.bold,
                                        color: Theme.of(context).colorScheme.primary,
                                      ),
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        isDense: true,
                                        contentPadding: EdgeInsets.zero,
                                      ),
                                      keyboardType: TextInputType.number,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  GestureDetector(
                                    onTap: _toggleTimer,
                                    child: Text(
                                      _isTimerRunning ? 'STOP' : 'START',
                                      style: TextStyle(
                                        color: _isTimerRunning ? Colors.red : Colors.white,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Dose Inputs
                          Expanded(
                            child: Column(
                              children: [
                                _buildCompactInput(context, 'IN', _doseInController),
                                const SizedBox(height: 8),
                                _buildCompactInput(context, 'OUT', _doseOutController),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      
                      // Gear Selection
                      if (provider.machines.isNotEmpty || provider.grinders.isNotEmpty) ...[
                        Text('GEAR', style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold, color: Colors.grey)),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            if (provider.machines.isNotEmpty)
                              Expanded(
                                child: InputDecorator(
                                  decoration: _inputDecoration('Machine'),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      isDense: true,
                                      value: _selectedMachineId,
                                      dropdownColor: const Color(0xFF1C1C1E),
                                      style: const TextStyle(color: Colors.white),
                                      items: provider.machines.map((m) => DropdownMenuItem(
                                        value: m.id,
                                        child: Text(
                                          m.name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )).toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedMachineId = val;
                                          final machine = provider.machines.firstWhere((m) => m.id == val);
                                          if (machine.defaultPressure != null) _pressureController.text = machine.defaultPressure.toString();
                                          if (machine.defaultTemperature != null) _tempController.text = machine.defaultTemperature.toString();
                                          if (machine.defaultPreInfusionTime != null) _preInfusionController.text = machine.defaultPreInfusionTime.toString();
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                            if (provider.machines.isNotEmpty && provider.grinders.isNotEmpty)
                              const SizedBox(width: 12),
                            if (provider.grinders.isNotEmpty)
                              Expanded(
                                child: InputDecorator(
                                  decoration: _inputDecoration('Grinder'),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      isExpanded: true,
                                      isDense: true,
                                      value: _selectedGrinderId,
                                      dropdownColor: const Color(0xFF1C1C1E),
                                      style: const TextStyle(color: Colors.white),
                                      items: provider.grinders.map((g) => DropdownMenuItem(
                                        value: g.id,
                                        child: Text(
                                          g.name,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      )).toList(),
                                      onChanged: (val) {
                                        setState(() {
                                          _selectedGrinderId = val;
                                          final grinder = provider.grinders.firstWhere((g) => g.id == val);
                                          if (grinder.defaultRpm != null) _rpmController.text = grinder.defaultRpm.toString();
                                        });
                                      },
                                    ),
                                  ),
                                ),
                              ),
                          ],
                        ),
                        const SizedBox(height: 16),
                      ],

                      // Advanced Params
                      ExpansionTile(
                        title: Text('ADVANCED PARAMETERS', style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                        children: [
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(child: _buildCompactInput(context, 'RPM', _rpmController)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildCompactInput(context, 'BAR', _pressureController)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Expanded(child: _buildCompactInput(context, '°C', _tempController)),
                              const SizedBox(width: 12),
                              Expanded(child: _buildCompactInput(context, 'PRE-INF (s)', _preInfusionController)),
                            ],
                          ),
                          const SizedBox(height: 8),
                          _buildCompactInput(context, 'WATER', _waterController, keyboardType: TextInputType.text),
                          const SizedBox(height: 12),
                        ],
                      ),
                      const SizedBox(height: 12),

                      // Flavour Graph
                      ExpansionTile(
                        title: Text('FLAVOUR PROFILE', style: GoogleFonts.robotoMono(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white)),
                        children: [
                          const SizedBox(height: 12),
                                                Center(
                                                  child: Container(
                                                    width: 200,
                                                    height: 200,
                                                    decoration: BoxDecoration(
                                                      color: Colors.black.withValues(alpha: 0.2),
                                                      borderRadius: BorderRadius.circular(16),
                                                      border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                                                    ),
                                                    child: GestureDetector(
                                                      onPanUpdate: (details) {
                                                        setState(() {
                                                          // Map local position to -1 to 1
                                                          // This is tricky inside a scroll view, let's use relative position
                                                          // Assuming 200x200 box
                                                          double dx = details.localPosition.dx;
                                                          double dy = details.localPosition.dy;
                                                          
                                                          _flavourX = ((dx / 200) * 2 - 1).clamp(-1.0, 1.0);
                                                          _flavourY = -((dy / 200) * 2 - 1).clamp(-1.0, 1.0); // Invert Y so up is positive
                                                        });
                                                      },
                                                      onTapDown: (details) {
                                                        setState(() {
                                                          double dx = details.localPosition.dx;
                                                          double dy = details.localPosition.dy;
                                                          _flavourX = ((dx / 200) * 2 - 1).clamp(-1.0, 1.0);
                                                          _flavourY = -((dy / 200) * 2 - 1).clamp(-1.0, 1.0);
                                                        });
                                                      },
                                                      child: CustomPaint(
                                                        painter: _FlavourGraphPainter(_flavourX, _flavourY, Theme.of(context).colorScheme.primary),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                                AnimatedSize(
                                                  duration: const Duration(milliseconds: 300),
                                                  curve: Curves.easeInOut,
                                                  child: _getTroubleshootingTips().isNotEmpty
                                                      ? Column(
                                                          children: [
                                                            const SizedBox(height: 16),
                                                            Container(
                                                              padding: const EdgeInsets.all(12),
                                                              decoration: BoxDecoration(
                                                                color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.1),
                                                                borderRadius: BorderRadius.circular(12),
                                                                border: Border.all(
                                                                    color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.3)),
                                                              ),
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Row(
                                                                    children: [
                                                                      Icon(Icons.lightbulb,
                                                                          size: 16, color: Theme.of(context).colorScheme.primary),
                                                                      const SizedBox(width: 8),
                                                                      Text('TROUBLESHOOTER',
                                                                          style: GoogleFonts.robotoMono(
                                                                              fontSize: 12,
                                                                              fontWeight: FontWeight.bold,
                                                                              color: Theme.of(context).colorScheme.primary)),
                                                                    ],
                                                                  ),
                                                                  const SizedBox(height: 8),
                                                                  ..._getTroubleshootingTips().map((tip) {
                                                                    final isHeader = tip.endsWith(':');
                                                                    return Padding(
                                                                      padding: const EdgeInsets.only(bottom: 4),
                                                                      child: Text(
                                                                        tip,
                                                                        style: GoogleFonts.robotoMono(
                                                                          fontSize: isHeader ? 12 : 11,
                                                                          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
                                                                          color: isHeader ? Colors.white : Colors.white70,
                                                                        ),
                                                                      ),
                                                                    );
                                                                  }),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      : const SizedBox.shrink(),
                                                ),
                                                const SizedBox(height: 12),
                                              ],
                                            ),                      const SizedBox(height: 16),

                      // Save Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: _saveShot,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).colorScheme.primary,
                            foregroundColor: Colors.black,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: const Text('SAVE SHOT', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, letterSpacing: 1.2)),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  InputDecoration _inputDecoration(String label) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Colors.grey),
      filled: true,
      fillColor: Colors.black.withValues(alpha: 0.2),
      isDense: true,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
    );
  }

  Widget _buildCompactInput(BuildContext context, String label, TextEditingController controller, {TextInputType? keyboardType}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withValues(alpha: 0.05)),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType ?? const TextInputType.numberWithOptions(decimal: true),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(color: Colors.white),
              textAlign: TextAlign.end,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<String> _getTroubleshootingTips() {
    final List<String> tips = [];
    const threshold = 0.3; // Sensitivity for suggestions

    if (_flavourX < -threshold) { // Sour
      tips.add('SOUR (Under-extracted):');
      tips.add('• Grind Finer');
      tips.add('• Increase Yield (ratio)');
      tips.add('• Increase Temperature');
    } else if (_flavourX > threshold) { // Bitter
      tips.add('BITTER (Over-extracted):');
      tips.add('• Grind Coarser');
      tips.add('• Decrease Yield (ratio)');
      tips.add('• Decrease Temperature');
    }

    if (_flavourY < -threshold) { // Weak
      tips.add(_flavourX.abs() > threshold ? '' : 'WEAK (Watery):'); // Header if needed
      if (_flavourX.abs() >= threshold) tips.add('WEAK (Watery):');
      tips.add('• Increase Dose (in)');
      tips.add('• Grind Finer');
    } else if (_flavourY > threshold) { // Strong
      tips.add(_flavourX.abs() > threshold ? '' : 'STRONG (Overpowering):');
      if (_flavourX.abs() >= threshold) tips.add('STRONG (Overpowering):');
      tips.add('• Decrease Dose (in)');
      tips.add('• Grind Coarser');
    }

    return tips.where((t) => t.isNotEmpty).toList();
  }

  String _formatDuration(int milliseconds) {
    final seconds = milliseconds ~/ 1000;
    final ms = (milliseconds % 1000) ~/ 100; // Get first digit of milliseconds
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}.${ms.toString()}';
  }
}

class _FlavourGraphPainter extends CustomPainter {
  final double x;
  final double y;
  final Color accentColor;

  _FlavourGraphPainter(this.x, this.y, this.accentColor);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withValues(alpha: 0.3)
      ..strokeWidth = 1;

    // Axes
    canvas.drawLine(Offset(size.width / 2, 0), Offset(size.width / 2, size.height), paint);
    canvas.drawLine(Offset(0, size.height / 2), Offset(size.width, size.height / 2), paint);

    // Labels
    final textStyle = GoogleFonts.robotoMono(fontSize: 10, color: Colors.grey);
    _drawText(canvas, 'Sour', Offset(10, size.height / 2), textStyle);
    _drawText(canvas, 'Bitter', Offset(size.width - 30, size.height / 2), textStyle);
    _drawText(canvas, 'Strong', Offset(size.width / 2, 10), textStyle);
    _drawText(canvas, 'Weak', Offset(size.width / 2, size.height - 20), textStyle);

    // Point
    // Map -1..1 to 0..width
    final px = (x + 1) / 2 * size.width;
    final py = (-y + 1) / 2 * size.height; // Invert Y

    canvas.drawCircle(Offset(px, py), 8, Paint()..color = accentColor);
    canvas.drawCircle(Offset(px, py), 12, Paint()..color = accentColor.withValues(alpha: 0.3));
  }

  void _drawText(Canvas canvas, String text, Offset offset, TextStyle style) {
    final tp = TextPainter(text: TextSpan(text: text, style: style), textDirection: TextDirection.ltr);
    tp.layout();
    tp.paint(canvas, offset - Offset(tp.width / 2, tp.height / 2));
  }

  @override
  bool shouldRepaint(covariant _FlavourGraphPainter oldDelegate) {
    return oldDelegate.x != x || oldDelegate.y != y;
  }
}