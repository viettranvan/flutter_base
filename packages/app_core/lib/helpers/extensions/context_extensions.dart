import 'package:flutter/material.dart';

/// BuildContext utility extensions
extension BuildContextX on BuildContext {
  /// Get media query data
  MediaQueryData get mediaQuery => MediaQuery.of(this);

  /// Get screen size
  Size get screenSize => mediaQuery.size;

  /// Get screen width
  double get screenWidth => screenSize.width;

  /// Get screen height
  double get screenHeight => screenSize.height;

  /// Get device padding (safe area)
  EdgeInsets get padding => mediaQuery.padding;

  /// Get device view insets (keyboard, status bar)
  EdgeInsets get viewInsets => mediaQuery.viewInsets;

  /// Check if screen is portrait
  bool get isPortrait => screenSize.width < screenSize.height;

  /// Check if screen is landscape
  bool get isLandscape => screenSize.width >= screenSize.height;

  /// Check if device is small screen (< 600 width)
  bool get isSmallScreen => screenWidth < 600;

  /// Check if device is tablet (>= 600 width)
  bool get isTablet => screenWidth >= 600;

  /// Get device orientation
  Orientation get orientation => mediaQuery.orientation;

  /// Get text scale factor
  TextScaler get textScale => mediaQuery.textScaler;

  /// Check if keyboard is visible
  bool get isKeyboardVisible => viewInsets.bottom > 0;

  /// Get keyboard height
  double get keyboardHeight => viewInsets.bottom;

  /// Get status bar height
  double get statusBarHeight => padding.top;

  /// Get bottom navigation/safe area height
  double get bottomPadding => padding.bottom;

  /// Pop with value
  void pop<T>([T? result]) => Navigator.pop(this, result);

  /// Push named route
  Future<dynamic> pushNamed(String routeName, {Object? arguments}) {
    return Navigator.pushNamed(this, routeName, arguments: arguments);
  }

  /// Push and remove until
  Future<dynamic> pushNamedAndRemoveUntil(
    String routeName,
    RoutePredicate predicate, {
    Object? arguments,
  }) {
    return Navigator.pushNamedAndRemoveUntil(
      this,
      routeName,
      predicate,
      arguments: arguments,
    );
  }

  /// Show snack bar
  ScaffoldFeatureController<SnackBar, SnackBarClosedReason> showSnackBar(
    SnackBar snackBar,
  ) {
    return ScaffoldMessenger.of(this).showSnackBar(snackBar);
  }

  /// Show simple snack bar message
  void showMessage(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showSnackBar(SnackBar(content: Text(message), duration: duration));
  }

  /// Show error snack bar
  void showError(
    String message, {
    Duration duration = const Duration(seconds: 3),
  }) {
    showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: Colors.red,
      ),
    );
  }

  /// Show success snack bar
  void showSuccess(
    String message, {
    Duration duration = const Duration(seconds: 2),
  }) {
    showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration,
        backgroundColor: Colors.green,
      ),
    );
  }

  /// Get theme
  ThemeData get theme => Theme.of(this);

  /// Get text theme
  TextTheme get textTheme => theme.textTheme;

  /// Get color scheme
  ColorScheme get colorScheme => theme.colorScheme;

  /// Check if dark mode
  bool get isDarkMode => theme.brightness == Brightness.dark;

  /// Check if light mode
  bool get isLightMode => theme.brightness == Brightness.light;
}
