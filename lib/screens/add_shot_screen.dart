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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Grind Size Dial
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: AnalogDial(
                value: _grindSize,
                min: 0,
                max: 30, // Configurable range as requested? (Hardcoded for now, could be dynamic)
                label: 'Grind Size',
                onChanged: (val) {
                  setState(() {
                    _grindSize = val;
                  });
                },
              ),
            ),
            const SizedBox(height: 24),

            // Dose Inputs
            Row(
              children: [
                Expanded(
                  child: _buildNumberInput(
                    context,
                    label: 'Dose In (g)',
                    controller: _doseInController,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildNumberInput(
                    context,
                    label: 'Yield (g)',
                    controller: _doseOutController,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Timer
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Text(
                    _formatDuration(_duration),
                    style: GoogleFonts.robotoMono(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _toggleTimer,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isTimerRunning ? Colors.red : Theme.of(context).colorScheme.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                    ),
                    child: Text(_isTimerRunning ? 'STOP TIMER' : 'START TIMER'),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Update Preferred Toggle
            SwitchListTile(
              title: const Text('Update Preferred Grind'),
              value: _updatePreferred,
              onChanged: (val) => setState(() => _updatePreferred = val),
              contentPadding: EdgeInsets.zero,
            ),
            const SizedBox(height: 24),

            // Save Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveShot,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                child: const Text('Save Shot', style: TextStyle(fontSize: 18)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNumberInput(BuildContext context,
      {required String label, required TextEditingController controller}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          TextField(
            controller: controller,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: Theme.of(context).textTheme.titleLarge,
            decoration: const InputDecoration(
              border: InputBorder.none,
              isDense: true,
              contentPadding: EdgeInsets.symmetric(vertical: 8),
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
