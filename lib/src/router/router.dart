import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/src/core/index.dart';
import 'package:flutter_base/src/features/home/presentation/dependencies.dart';
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
                NoTransitionPage(child: HomeDependencies.buildHomePage()),
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

      /* Debug Route - For debugging purposes - Development only */
      GoRoute(
        path: RouteName.debug.path,
        builder: (context, state) => const DebugPage(),
        redirect: (context, state) async {
          return EnvConfig.isDevelopment() ? null : '/';
        },
      ),
    ],
    redirect: (context, state) async {
      final publicPaths = {RouteName.signIn.path, RouteName.signUp.path};

      final accessToken = await appStorage.getValue(AppStorageKey.accessToken);
      final currentPath = state.uri.path;
      final isLoggedIn = (accessToken ?? '').isNotEmpty;
      // if already logged in and trying to access a public page => redirect to home
      if (isLoggedIn && publicPaths.contains(currentPath)) {
        return '/';
      }
      // if not logged in and trying to access a protected page => redirect to signIn
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
