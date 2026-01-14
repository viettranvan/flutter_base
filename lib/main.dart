import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/generated/l10n.dart';
import 'package:flutter_base/src/injection_container.dart';
import 'package:flutter_base/src/router/router.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppPreferences.init();
  await setup();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Barber Online',
      debugShowCheckedModeBanner: false,
      supportedLocales: S.delegate.supportedLocales,
      localizationsDelegates: const [
        S.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      routerConfig: appRouter.router,
      theme: ThemeData(
        fontFamily: 'PlusJakartaSans',
        package: 'app_core',
        bottomSheetTheme: const BottomSheetThemeData(
          backgroundColor: AppColors.white900,
        ),

        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: AppColors.white900,
          selectedIconTheme: IconThemeData(color: AppColors.primaryBrand900),
          unselectedIconTheme: IconThemeData(color: AppColors.coolGray400),
        ),

        /// Prevents to splash effect when clicking.
        highlightColor: Colors.transparent,
        splashColor: Colors.transparent,
        scaffoldBackgroundColor: AppColors.white900,

        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.white900,
          scrolledUnderElevation: 0,
        ),
        brightness: Brightness.light,
        useMaterial3: true,
      ),
    );
  }
}
