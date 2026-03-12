import 'package:flutter/cupertino.dart';
import 'dart:io' show Platform;

/// Custom page route with slide and fade transition.
/// On iOS, extends CupertinoPageRoute for native swipe-back gesture support.
/// On Android, uses a custom slide + fade transition.
PageRoute<T> SlidePageRoute<T>({required WidgetBuilder builder}) {
  if (Platform.isIOS) {
    return CupertinoPageRoute<T>(builder: builder);
  }
  return _MaterialSlidePageRoute<T>(builder: builder);
}

/// Custom page route with fade transition for modal-style screens.
/// On iOS, uses CupertinoPageRoute for native swipe-back gesture support.
/// On Android, uses a fade transition.
PageRoute<T> FadePageRoute<T>({required WidgetBuilder builder}) {
  if (Platform.isIOS) {
    return CupertinoPageRoute<T>(builder: builder);
  }
  return _MaterialFadePageRoute<T>(builder: builder);
}

class _MaterialSlidePageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;

  _MaterialSlidePageRoute({required this.builder});

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

    final slideAnimation = Tween<Offset>(
      begin: const Offset(1.0, 0.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: animation, curve: curve));

    final fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: animation, curve: curve));

    final previousPageSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.3, 0.0),
    ).animate(CurvedAnimation(parent: secondaryAnimation, curve: curve));

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

class _MaterialFadePageRoute<T> extends PageRoute<T> {
  final WidgetBuilder builder;

  _MaterialFadePageRoute({required this.builder});

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
    ).animate(CurvedAnimation(parent: animation, curve: Curves.easeInOut));

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
