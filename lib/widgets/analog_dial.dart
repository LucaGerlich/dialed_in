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
    this.max = 30,
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
    // Vertical drag to change value
    // Sensitivity: 1 pixel = 0.05 units (adjust as needed)
    final delta = details.delta.dy * -0.05;
    
    double newValue = _currentValue + delta;
    newValue = newValue.clamp(widget.min, widget.max);

    // Haptics on integer change
    if (newValue.floor() != _currentValue.floor()) {
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
            color: const Color(0xFF1C1C1E), // Dark surface
            borderRadius: BorderRadius.circular(40),
            border: Border.all(color: Colors.white.withOpacity(0.1)),
          ),
          child: Text(
            _currentValue.toStringAsFixed(1),
            style: GoogleFonts.robotoMono(
              fontSize: 56,
              fontWeight: FontWeight.bold,
              color: Colors.white,
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
  final Color color;
  final Color accentColor;

  _RadioTunerPainter({
    required this.value,
    required this.min,
    required this.max,
    required this.color,
    required this.accentColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final centerY = size.height / 2;
    final centerX = size.width; // Right edge of the dial area is the "center" of the arc
    
    // Arc parameters
    final radius = size.height * 1.2; // Large radius for subtle curve
    final arcCenter = Offset(centerX + radius - 40, centerY); // Center of the circle forming the arc

    final tickPaint = Paint()
      ..color = color.withOpacity(0.3)
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final activeTickPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final textPainter = TextPainter(
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.right,
    );

    // How many units visible?
    const visibleRange = 6.0; // +/- 3 units
    final startVal = (value - visibleRange).floorToDouble();
    final endVal = (value + visibleRange).ceilToDouble();

    for (double i = startVal; i <= endVal; i += 0.2) { // Ticks every 0.2
      if (i < min || i > max) continue;

      final diff = i - value; // Distance from center
      // Map diff to Y position
      // 1 unit = 40 pixels
      final yOffset = diff * 40;
      final yPos = centerY + yOffset;

      // Calculate X based on arc
      // Circle equation: (x - cx)^2 + (y - cy)^2 = r^2
      // x = cx - sqrt(r^2 - (y - cy)^2)
      final dy = yPos - arcCenter.dy;
      // If dy is too large, we are out of circle, skip
      if (dy.abs() > radius) continue;
      
      final dx = arcCenter.dx - sqrt(radius * radius - dy * dy);

      // Opacity fade at edges
      final opacity = (1.0 - (diff.abs() / visibleRange)).clamp(0.0, 1.0);
      if (opacity <= 0) continue;

      final isMajor = (i * 10).round() % 10 == 0; // Integer values
      final tickLength = isMajor ? 30.0 : 15.0;
      
      final paint = isMajor ? activeTickPaint : tickPaint;
      paint.color = paint.color.withOpacity(opacity * (isMajor ? 1.0 : 0.5));

      canvas.drawLine(
        Offset(dx, yPos),
        Offset(dx - tickLength, yPos),
        paint,
      );

      // Draw numbers for major ticks
      if (isMajor) {
        textPainter.text = TextSpan(
          text: i.round().toString(),
          style: GoogleFonts.robotoMono(
            fontSize: 14,
            color: color.withOpacity(opacity * 0.7),
          ),
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(dx - tickLength - textPainter.width - 8, yPos - textPainter.height / 2),
        );
      }
    }

    // Draw Center Indicator (The "Needle")
    // In the image, it's a line and a highlight
    final indicatorPaint = Paint()
      ..color = accentColor
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw a "lens" or box around the center?
    // Image has a box around the ticks on the left
    final boxHeight = 60.0;
    final boxWidth = 80.0;
    final boxRect = Rect.fromCenter(
      center: Offset(size.width - boxWidth/2, centerY),
      width: boxWidth,
      height: boxHeight,
    );

    // Draw selection box styling
    final boxPaint = Paint()
      ..color = Colors.white.withOpacity(0.05)
      ..style = PaintingStyle.fill;
    
    final boxBorderPaint = Paint()
      ..color = Colors.white.withOpacity(0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    // Draw curved box matching the arc? Hard. Let's do simple rounded rect for now.
    // Actually, let's just draw the "Center Line"
    
    canvas.drawLine(
      Offset(size.width - 60, centerY),
      Offset(size.width, centerY),
      Paint()..color = accentColor ..strokeWidth = 2,
    );
    
    // Small arrow on the left of the line
    final path = Path()
      ..moveTo(size.width - 65, centerY)
      ..lineTo(size.width - 60, centerY - 4)
      ..lineTo(size.width - 60, centerY + 4)
      ..close();
    
    canvas.drawPath(path, Paint()..color = accentColor ..style = PaintingStyle.fill);
  }

  @override
  bool shouldRepaint(covariant _RadioTunerPainter oldDelegate) {
    return oldDelegate.value != value || oldDelegate.color != color;
  }
}
