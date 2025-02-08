import 'package:flutter/material.dart';

class NavigationHelper {
  /// Pushes a new [widget] onto the navigation stack with a fade transition.
  static Future<T?> push<T>(BuildContext context, Widget widget) {
    return Navigator.push<T>(
      context,
      _fadeRoute(widget),
    );
  }

  /// Replaces the current route with a new [widget] with a fade transition.
  static Future<T?> pushReplacement<T, TO>(
    BuildContext context,
    Widget widget,
  ) {
    return Navigator.pushReplacement<T, TO>(
      context,
      _fadeRoute(widget),
    );
  }

  /// Pushes a new [widget] and removes all the previous routes until the predicate returns true.
  static Future<T?> pushAndRemoveUntil<T>(
    BuildContext context,
    Widget widget,
    bool Function(Route<dynamic>) predicate,
  ) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      _fadeRoute(widget),
      predicate,
    );
  }

  /// Pushes a named route onto the navigation stack.
  static Future<T?> pushNamed<T>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushNamed<T>(context, routeName, arguments: arguments);
  }

  /// Replaces the current route with a named route.
  static Future<T?> pushReplacementNamed<T, TO>(
    BuildContext context,
    String routeName, {
    Object? arguments,
  }) {
    return Navigator.pushReplacementNamed<T, TO>(
      context,
      routeName,
      arguments: arguments,
    );
  }

  /// Pushes a named route and removes all previous routes until the predicate returns true.
  static Future<T?> pushAndRemoveUntilNamed<T>(
    BuildContext context,
    String routeName,
    bool Function(Route<dynamic>) predicate, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil<T>(
      context,
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  /// Pops the current route off the navigator and optionally returns a [result].
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop(context, result);
  }

  /// Creates a fade transition route.
  static PageRouteBuilder<T> _fadeRoute<T>(Widget widget) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => widget,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        var begin = 0.0;
        var end = 1.0;
        var curve = Curves.easeInOut;

        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );

        var fadeAnimation = animation.drive(tween);

        return FadeTransition(
          opacity: fadeAnimation,
          child: child,
        );
      },
    );
  }
}
