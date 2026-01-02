import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
class AnalogDial extends StatefulWidget {
  final double min;
  final double max;
  final double step;
  final double value;
  final ValueChanged<double> onChanged;
  final String label;

  const AnalogDial({
    super.key,
    this.min = 0,
    this.max = 30,
    this.step = 0.1, // Default step, but only for graphical representation and default for logic if none provided by provider
    required this.value,
    required this.onChanged,
    this.label = '',
  });

  @override
  State<AnalogDial> createState() => _AnalogDialState();
}

class _AnalogDialState extends State<AnalogDial> {
  late double _currentValue;

  @override
  void initState() {
    super.initState();
    _currentValue = widget.value;
  }

  @override
  void didUpdateWidget(AnalogDial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentValue = widget.value;
    }
  }

  void _onPanUpdate(DragUpdateDetails details) {
    // Calculate dynamic sensitivity
    // We want a specific number of pixels to represent one "step" visually
    const double pixelsPerStep = 24.0;
    final double effectiveStep = widget.step <= 0 ? 0.1 : widget.step;
    final double pixelsPerUnit = pixelsPerStep / effectiveStep;

    // Vertical drag to change value
    // Dragging 'down' (positive dy) should usually decrease value (like pulling a tape down to see higher numbers? or opposite?)
    // Standard UI: Dragging DOWN moves content DOWN.
    // If content is a ruler:
    //  12
    //  11
    //  10
    // If I drag DOWN, I see 13, 14... So value increases?
    // Let's stick to the previous direction: dy * -1 decreased value.
    // deltaY positive -> value change negative.
    
    final delta = details.delta.dy * -1.0 / pixelsPerUnit;

    double newValue = _currentValue + delta;
    newValue = newValue.clamp(widget.min, widget.max);

    // Haptics on step boundary crossing
    if ((newValue / effectiveStep).floor() != (_currentValue / effectiveStep).floor()) {
      HapticFeedback.selectionClick();
    }

    setState(() {
      _currentValue = newValue;
      widget.onChanged(newValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // The Dial (Left side)
        GestureDetector(
          onPanUpdate: _onPanUpdate,
          child: SizedBox(
            width: 150,
            height: 300,
            child: CustomPaint(
              painter: _RadioTunerPainter(
                value: _currentValue,
                min: widget.min,
                max: widget.max,
                step: widget.step <= 0 ? 0.1 : widget.step,
                color: Theme.of(context).colorScheme.onSurface,
                accentColor: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
        ),
        const SizedBox(width: 20),
        // The Readout (Right side)
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface, // Theme surface
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.1)),
          ),
          child: Text(
            _currentValue.toStringAsFixed(1),
            style: TextStyle(fontFamily: 'RobotoMono',
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

class _RadioTunerPainter extends CustomPainter {
  final double value;
  final double min;
  final double max;
  final double step;
  final Color color;
  final Color accentColor;

  _RadioTunerPainter({
    required this.value,
    required this.min,
    required this.max,
    required this.step,
    required this.color,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final centerX = size.width; 
    
    // Arc parameters
    final radius = size.height * 1.2; 
    final arcCenter = Offset(centerX + radius - 40, centerY);

    final tickPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final activeTickPaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    // Dynamic Scaling
    const double pixelsPerStep = 24.0;
    final double pixelsPerUnit = pixelsPerStep / step;

    // How many units visible?
    final visibleUnits = (size.height / pixelsPerUnit) / 2 + step; 
    final startVal = (value - visibleUnits).floorToDouble();
    final endVal = (value + visibleUnits).ceilToDouble();

    // Draw ticks at exactly 'step' intervals
    // We align startVal to the nearest step
    final alignedStart = (startVal / step).floor() * step;
    
    for (double i = alignedStart; i <= endVal; i += step) {
      // Fix floating point drift
      final roundedI = (i * 1000).round() / 1000.0;

      if (roundedI < min || roundedI > max) continue;

      final diff = roundedI - value; 
      final yOffset = diff * pixelsPerUnit;
      final yPos = centerY + yOffset;

      // Calculate X based on arc
      final dy = yPos - arcCenter.dy;
      if (dy.abs() > radius) continue;
      
      final dx = arcCenter.dx - sqrt(radius * radius - dy * dy);

      // Opacity fade at edges
      final opacity = (1.0 - (yOffset.abs() / (size.height / 2))).clamp(0.0, 1.0);
      if (opacity <= 0) continue;

      // Determine if "Major" tick
      // If step < 1, Major ticks are Integers.
      // If step >= 1, every tick is Major.
      bool isMajor = false;
      if (step < 1.0) {
        isMajor = (roundedI % 1.0).abs() < 0.001; // Is Integer
      } else {
        isMajor = true;
      }

      final tickLength = isMajor ? 30.0 : 15.0;
      
      final paint = isMajor ? activeTickPaint : tickPaint;
      paint.color = paint.color.withValues(alpha: opacity * (isMajor ? 1.0 : 0.5));

      canvas.drawLine(
        Offset(dx, yPos),
        Offset(dx - tickLength, yPos),
        paint,
      );

      // Draw numbers for Major ticks
      if (isMajor) {
        textPainter.text = TextSpan(
          text: roundedI.toStringAsFixed((step - step.roundToDouble()).abs() < 0.0001 ? 0 : 1),
          style: TextStyle(fontFamily: 'RobotoMono',
            fontSize: 14,
            color: color.withValues(alpha: opacity * 0.7),
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(dx - tickLength - textPainter.width - 8, yPos - textPainter.height / 2),
        );
      }
    }

    // Draw Center Indicator
    canvas.drawLine(
      Offset(size.width - 60, centerY),
      Offset(size.width, centerY),
      Paint()..color = accentColor ..strokeWidth = 2,
    );
    
    final path = Path()
      ..moveTo(size.width - 65, centerY)
      ..lineTo(size.width - 60, centerY - 4)
      ..lineTo(size.width - 60, centerY + 4)
      ..close();
    
    canvas.drawPath(path, Paint()..color = accentColor ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant _RadioTunerPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color || oldDelegate.step != step;
  }
}
