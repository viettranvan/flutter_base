// lib/src/core/error_handler.dart

import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';

import 'router/router.dart';

class GlobalErrorHandler {
  // 🎯 Lấy context từ root navigator (tối cao nhất)
  static BuildContext? get _rootContext {
    return rootNavigatorKey.currentContext;
  }

  static void handle(AppException exception, {BuildContext? context}) {
    final ctx = context ?? _rootContext;

    if (ctx == null) {
      AppLogger.e('No context available for error handling');
      return;
    }

    AppLogger.e('Error: ${exception.message}', error: exception);

    if (exception is NetworkException) {
      _showNetworkError(ctx);
    } else if (exception is AuthException) {
      _showAuthError(ctx);
    } else if (exception is ServerException) {
      _showServerError(ctx);
    } else if (exception is ValidationException) {
      _showValidationError(ctx, exception);
    } else if (exception is NotFoundException) {
      _showNotFoundError(ctx);
    } else {
      _showGenericError(ctx, exception);
    }
  }

  static void _showNetworkError(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Mất kết nối')));
  }

  static void _showAuthError(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Phiên hết hạn'),
        content: Text('Vui lòng đăng nhập lại'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pushReplacementNamed(ctx, '/login');
            },
            child: Text('OK'),
          ),
        ],
      ),
    );
  }

  static void _showServerError(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Lỗi server')));
  }

  static void _showValidationError(
    BuildContext context,
    ValidationException exception,
  ) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(exception.message)));
  }

  static void _showNotFoundError(BuildContext context) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Không tìm thấy')));
  }

  static void _showGenericError(BuildContext context, AppException exception) {
    // Nếu message quá dài, dùng dialog với scrollable content
    final maxSnackbarLength = 100;
    final message = exception.message;

    if (message.length > maxSnackbarLength) {
      showDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('Có lỗi xảy ra'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(message, style: Theme.of(ctx).textTheme.bodyMedium),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Đóng'),
            ),
          ],
        ),
      );
    } else {
      // Message ngắn, dùng snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(message), duration: const Duration(seconds: 3)),
      );
    }
  }
}
