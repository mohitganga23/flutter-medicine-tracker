import 'package:flutter/material.dart';

class NavigationHelper {
  /// Pushes a new [widget] onto the navigation stack with a fade transition.
  ///
  /// Returns a [Future] that completes to the result value, if any.
  static Future<T?> push<T>(BuildContext context, Widget widget) {
    return Navigator.push<T>(
      context,
      PageRouteBuilder(
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
      ),
    );
  }

  /// Replaces the current route with a new [widget] with a fade transition.
  ///
  /// Returns a [Future] that completes to the result value, if any.
  static Future<T?> pushReplacement<T, TO>(
    BuildContext context,
    Widget widget,
  ) {
    return Navigator.pushReplacement<T, TO>(
      context,
      PageRouteBuilder(
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
      ),
    );
  }

  /// Pushes a new [widget] and removes all the previous routes until the predicate returns true,
  /// with a fade transition.
  ///
  /// Returns a [Future] that completes to the result value, if any.
  static Future<T?> pushAndRemoveUntil<T>(
    BuildContext context,
    Widget widget,
    bool Function(Route<dynamic>) predicate,
  ) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      PageRouteBuilder(
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
      ),
      predicate,
    );
  }

  /// Pops the current route off the navigator and optionally returns a [result].
  static void pop<T>(BuildContext context, [T? result]) {
    Navigator.pop(context, result);
  }
}
