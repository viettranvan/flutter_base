import 'package:design_assets/design_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/src/features/page_index.dart';
import 'package:go_router/go_router.dart';

part 'route_name.dart';

final appRouter = _AppRouter();

//rootNavigatorKey (can use to hide bottom navigation bar of child screen)
final rootNavigatorKey = GlobalKey<NavigatorState>();
//shellNavigatorKey is to identify pages belong to the bottom nav
final _shellNavigatorKey = GlobalKey<NavigatorState>();

class _AppRouter {
  _AppRouter._internal();
  static final _singleton = _AppRouter._internal();
  factory _AppRouter() => _singleton;

  final GoRouter router = GoRouter(
    navigatorKey: rootNavigatorKey,
    routes: [
      // * App Bottom Navigation Route
      ShellRoute(
        navigatorKey: _shellNavigatorKey,
        pageBuilder: (context, state, child) {
          return NoTransitionPage(
            child: AppNavScreen(
              name: state.topRoute?.name ?? RouteName.home.name,
              child: child,
            ),
          );
        },
        routes: [
          // * Home Route
          GoRoute(
            parentNavigatorKey: _shellNavigatorKey,
            name: RouteName.home.name,
            path: RouteName.home.path,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: HomePage()),
            routes: _homeSubRoute,
          ),
          // * Profile Route
          GoRoute(
            parentNavigatorKey: _shellNavigatorKey,
            name: RouteName.profile.name,
            path: RouteName.profile.path,
            pageBuilder: (context, state) =>
                const NoTransitionPage(child: ProfilePage()),
            routes: _profileSubRoutes,
          ),
        ],
      ),

      // Other Routes
      GoRoute(
        path: RouteName.signIn.path,
        builder: (context, state) => const LoginPage(),
      ),
    ],
    redirect: (context, state) async {
      final publicPaths = {RouteName.signIn.path, RouteName.signUp.path};

      final accessToken = await appStorage.getValue(AppStorageKey.accessToken);
      final currentPath = state.uri.path;
      final isLoggedIn = (accessToken ?? '').isNotEmpty;
      // Nếu đã đăng nhập mà đang ở trang public => chuyển sang trang home
      if (isLoggedIn && publicPaths.contains(currentPath)) {
        return '/';
      }
      // Nếu chưa đăng nhập mà đang ở trang cần bảo vệ => chuyển về signIn
      if (!isLoggedIn && !publicPaths.contains(currentPath)) {
        return RouteName.signIn.path;
      }

      // Không cần redirect
      return null;
    },
  );
}

// * Home Sub Route
final List<GoRoute> _homeSubRoute = [];

// * Profile Sub Route
final List<GoRoute> _profileSubRoutes = [];
