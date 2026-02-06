import 'package:flutter/material.dart';

/// Custom page route with slide and fade transition
class SlidePageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;

  SlidePageRoute({required this.builder});

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    const curve = Curves.easeInOut;

    // Slide in from right
    final slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: curve,
    ));

    // Fade in
    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: curve,
    ));

    // Previous page slides left slightly
    final previousPageSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.3, 0.0),
    ).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: curve,
    ));

    return SlideTransition(
      position: previousPageSlide,
      child: SlideTransition(
        position: slideAnimation,
        child: FadeTransition(
          opacity: fadeAnimation,
          child: child,
        ),
      ),
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 300);

  @override
  Duration get reverseTransitionDuration => const Duration(milliseconds: 250);
}

/// Custom page route with fade transition for modal-style screens
class FadePageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;

  FadePageRoute({required this.builder});

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return builder(context);
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: animation,
      curve: Curves.easeInOut,
    ));

    return FadeTransition(
      opacity: fadeAnimation,
      child: child,
    );
  }

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 250);
}
