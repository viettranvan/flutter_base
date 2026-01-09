import 'dart:developer' as dev;

import 'package:app_core/utils/index.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/generated/l10n.dart';
import 'package:flutter_base/src/router/router.dart';
import 'package:go_router/go_router.dart';

class AppNavScreen extends StatefulWidget {
  const AppNavScreen({super.key, required this.child, required this.name});
  final String name;
  final Widget child;

  @override
  State<AppNavScreen> createState() => _AppNavScreenState();
}

class _AppNavScreenState extends State<AppNavScreen> {
  static final tabs = [RouteName.home.path, RouteName.profile.path];

  @override
  void initState() {
    final router = appRouter.router;
    appRouter.router.routerDelegate.addListener(() {
      final location = router.routeInformationProvider.value.uri;
      dev.log('🏷️ Current full path: $location');
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).uri.toString();
    var currentIndex = tabs.indexWhere((e) => e == location);
    if (currentIndex == -1) currentIndex = 0;

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Divider(
            height: 1,
            color: Color(0xffEBF0F5), // Màu viền top
          ),
          BottomNavigationBar(
            currentIndex: currentIndex,
            selectedItemColor: AppColors.primaryBrand900,
            unselectedItemColor: AppColors.coolGray400,
            selectedFontSize: 12,
            selectedLabelStyle: AppTextStyle.of(
              size: 12,
              color: AppColors.primaryBrand900,
            ),
            unselectedLabelStyle: AppTextStyle.of(
              size: 12,
              color: AppColors.coolGray400,
            ),
            showUnselectedLabels: true,
            type: BottomNavigationBarType.fixed,
            onTap: (int index) {
              if (index != currentIndex) {
                context.go(tabs[index]);
              }
            },
            items: [
              BottomNavigationBarItem(
                label: S.of(context).home,
                icon: Icon(
                  Icons.home,
                  color: currentIndex == 0
                      ? AppColors.primaryBrand900
                      : AppColors.coolGray400,
                ),
              ),

              BottomNavigationBarItem(
                label: S.of(context).profile,
                icon: Icon(
                  Icons.person,
                  color: currentIndex == 1
                      ? AppColors.primaryBrand900
                      : AppColors.coolGray400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
