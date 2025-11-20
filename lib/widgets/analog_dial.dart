import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';

class AnalogDial extends StatefulWidget {
  final double min;
  final double max;
  final double value;
  final ValueChanged<double> onChanged;
  final String label;

  const AnalogDial({
    super.key,
    this.min = 0,
    this.max = 20,
    required this.value,
    required this.onChanged,
    this.label = '',
  });

  @override
  State<AnalogDial> createState() => _AnalogDialState();
}

class _AnalogDialState extends State<AnalogDial> {
  double _currentAngle = 0;

  @override
  void initState() {
    super.initState();
    _currentAngle = _valueToAngle(widget.value);
  }

  @override
  void didUpdateWidget(AnalogDial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.value != widget.value) {
      _currentAngle = _valueToAngle(widget.value);
    }
  }

  double _valueToAngle(double value) {
    // Map value (min-max) to angle (-pi*0.8 to pi*0.8)
    return ((value - widget.min) / (widget.max - widget.min)) * (1.6 * pi) - (0.8 * pi);
  }

  double _angleToValue(double angle) {
    // Map angle to value
    // Clamp angle first
    final clampedAngle = angle.clamp(-0.8 * pi, 0.8 * pi);
    return ((clampedAngle + 0.8 * pi) / (1.6 * pi)) * (widget.max - widget.min) + widget.min;
  }

  void _onPanUpdate(DragUpdateDetails details) {
    final renderBox = context.findRenderObject() as RenderBox;
    final center = renderBox.size.center(Offset.zero);
    final position = renderBox.globalToLocal(details.globalPosition);
    final vector = position - center;
    
    // Calculate angle from vertical up (which is -pi/2 in atan2, but we want 0 to be up)
    // Actually standard atan2: 0 is right, pi/2 is down, -pi/2 is up, pi/-pi is left.
    // We want our dial to go from bottom-left to bottom-right.
    // Let's just use standard angle and map it.
    
    double angle = atan2(vector.dy, vector.dx);
    // Rotate so that -pi/2 (up) is 0? No, let's stick to standard and just clamp.
    // Our range is -0.8pi (approx -144 deg) to 0.8pi (approx 144 deg).
    // -pi is left, 0 is right, pi/2 is down.
    // -0.8pi is bottom-left. 0.8pi is bottom-right.
    // The gap is at the bottom.
    
    // Adjust angle to be continuous across the gap if needed, but simple clamping works for now
    // if we assume the user doesn't cross the bottom gap.
    
    // Basic interaction: just track delta?
    // Let's try absolute angle tracking.
    
    // Convert standard angle to our range.
    // If angle is in the bottom gap (e.g. > 0.8pi or < -0.8pi), we clamp to nearest.
    
    // Problem: atan2 returns -pi to pi.
    // 0.8pi is roughly 2.5. -0.8pi is -2.5.
    // The gap is between 2.5 and 3.14 and -3.14 and -2.5.
    
    if (angle > 0.8 * pi) angle = 0.8 * pi;
    if (angle < -0.8 * pi) angle = -0.8 * pi;

    final newValue = _angleToValue(angle);
    
    // Only trigger haptics if value changed significantly (e.g. crossed a tick)
    // Or just trigger on every update but throttle?
    // Let's trigger if the integer part changes or every 0.5 step?
    // For smooth feel, maybe just selectionClick on every move is too much.
    // Let's try triggering every time the value crosses a 0.5 threshold.
    
    if ((newValue * 2).floor() != (widget.value * 2).floor()) {
      HapticFeedback.selectionClick();
    }

    setState(() {
      _currentAngle = angle;
      widget.onChanged(newValue);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.label.isNotEmpty)
          Text(
            widget.label,
            style: GoogleFonts.lato(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        const SizedBox(height: 10),
        GestureDetector(
          onPanUpdate: _onPanUpdate,
          child: CustomPaint(
            size: const Size(200, 200),
            painter: _DialPainter(
              angle: _currentAngle,
              color: Theme.of(context).colorScheme.primary,
              accentColor: Theme.of(context).colorScheme.secondary,
            ),
          ),
        ),
        const SizedBox(height: 10),
        Text(
          widget.value.toStringAsFixed(1),
          style: GoogleFonts.playfairDisplay(
            fontSize: 32,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ],
    );
  }
}

class _DialPainter extends CustomPainter {
  final double angle;
  final Color color;
  final Color accentColor;

  _DialPainter({required this.angle, required this.color, required this.accentColor});

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.width / 2;
    final strokeWidth = 4.0;

    // Draw ticks
    final tickPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final activeTickPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    const totalTicks = 40;
    const startAngle = -0.8 * pi;
    const endAngle = 0.8 * pi;
    const angleRange = endAngle - startAngle;

    for (int i = 0; i <= totalTicks; i++) {
      final tickAngle = startAngle + (angleRange / totalTicks) * i;
      final isPast = tickAngle <= angle;
      
      final innerRadius = radius - 15;
      final outerRadius = radius;
      
      final p1 = Offset(
        center.dx + innerRadius * cos(tickAngle),
        center.dy + innerRadius * sin(tickAngle),
      );
      final p2 = Offset(
        center.dx + outerRadius * cos(tickAngle),
        center.dy + outerRadius * sin(tickAngle),
      );

      canvas.drawLine(p1, p2, isPast ? activeTickPaint : tickPaint);
    }

    // Draw Knob Shadow
    final knobRadius = radius - 30;
    final shadowPaint = Paint()
      ..color = Colors.black.withOpacity(0.2)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);
    
    canvas.drawCircle(center + const Offset(0, 2), knobRadius, shadowPaint);

    // Draw Knob
    final knobPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    canvas.drawCircle(center, knobRadius, knobPaint);

    // Draw Indicator
    final indicatorPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    final indicatorPos = Offset(
      center.dx + (knobRadius - 10) * cos(angle),
      center.dy + (knobRadius - 10) * sin(angle),
    );

    canvas.drawLine(center, indicatorPos, indicatorPaint);
  }

  @override
  bool shouldRepaint(covariant _DialPainter oldDelegate) {
    return oldDelegate.angle != angle || oldDelegate.color != color;
  }
}
