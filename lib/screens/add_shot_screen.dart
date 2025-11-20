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
  double _grindSize = 10.0;
  int _duration = 0;
  Timer? _timer;
  bool _isTimerRunning = false;
  bool _updatePreferred = false;

  @override
  void dispose() {
    _doseInController.dispose();
    _doseOutController.dispose();
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
        _duration = 0;
      });
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _duration++;
        });
      });
    }
  }

  void _saveShot() {
    final doseIn = double.tryParse(_doseInController.text) ?? 0;
    final doseOut = double.tryParse(_doseOutController.text) ?? 0;

    if (doseIn > 0 && doseOut > 0 && _duration > 0) {
      final shot = Shot(
        grindSize: _grindSize,
        doseIn: doseIn,
        doseOut: doseOut,
        duration: _duration,
        timestamp: DateTime.now(),
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dial-In'),
      ),
      body: Column(
        children: [
          // Expanded Dial Area (Centered)
          Expanded(
            child: Center(
              child: AnalogDial(
                value: _grindSize,
                min: 0,
                max: 30,
                label: 'Grind Size',
                onChanged: (val) {
                  setState(() {
                    _grindSize = val;
                  });
                },
              ),
            ),
          ),

          // Bottom Section (Inputs + Timer + Save)
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
              border: Border(top: BorderSide(color: Colors.white.withOpacity(0.1))),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Timer Row
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(color: Colors.white.withOpacity(0.05)),
                        ),
                        child: Column(
                          children: [
                            Text(
                              _formatDuration(_duration),
                              style: GoogleFonts.robotoMono(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Theme.of(context).colorScheme.primary,
                              ),
                            ),
                            const SizedBox(height: 8),
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
                    const SizedBox(width: 16),
                    // Dose Inputs (Stacked or Row?)
                    Expanded(
                      child: Column(
                        children: [
                          _buildCompactInput(context, 'IN', _doseInController),
                          const SizedBox(height: 12),
                          _buildCompactInput(context, 'OUT', _doseOutController),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

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
        ],
      ),
    );
  }

  Widget _buildCompactInput(BuildContext context, String label, TextEditingController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12, fontWeight: FontWeight.bold)),
          const SizedBox(width: 12),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
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

  String _formatDuration(int seconds) {
    final minutes = seconds ~/ 60;
    final remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }
}
