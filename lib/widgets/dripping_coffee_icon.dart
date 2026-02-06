import 'package:flutter/material.dart';

/// Animated coffee icon with dripping animation
class DrippingCoffeeIcon extends StatefulWidget {
  final double size;
  final Color color;

  const DrippingCoffeeIcon({super.key, this.size = 64, required this.color});

  @override
  State<DrippingCoffeeIcon> createState() => _DrippingCoffeeIconState();
}

class _DrippingCoffeeIconState extends State<DrippingCoffeeIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _dropAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );

    // Drop position animation (falls from top to cup)
    _dropAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(
          begin: -0.4,
          end: 1.3,
        ).chain(CurveTween(curve: Curves.easeIn)),
        weight: 100,
      ),
      TweenSequenceItem(tween: ConstantTween<double>(1.3), weight: 200),
    ]).animate(_controller);

    // Scale animation (drop gets smaller as it falls, then disappears)
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0.8, end: 0.6),
        weight: 100,
      ),
      TweenSequenceItem(tween: Tween<double>(begin: 0.4, end: 0.0), weight: 30),
    ]).animate(_controller);

    // Fade animation (drop fades out when it hits the cup)
    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(tween: ConstantTween<double>(1.0), weight: 100),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 0.0),
        weight: 100,
      ),
    ]).animate(_controller);

    _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size * 1.4,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Coffee cup icon (positioned at bottom)
          Positioned(
            bottom: 0,
            child: Icon(Icons.coffee, size: widget.size, color: widget.color),
          ),
          // Animated dripping drop
          AnimatedBuilder(
            animation: _controller,
            builder: (context, child) {
              return Positioned(
                top:
                    widget.size * 0.2 +
                    (widget.size * 0.4 * _dropAnimation.value),
                child: Opacity(
                  opacity: _fadeAnimation.value,
                  child: Transform.scale(
                    scale: _scaleAnimation.value,
                    child: Container(
                      width: widget.size * 0.15,
                      height: widget.size * 0.2,
                      decoration: BoxDecoration(
                        color: widget.color.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(widget.size * 0.1),
                      ),
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
