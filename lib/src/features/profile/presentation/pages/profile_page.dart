import 'package:design_assets/design_assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/src/router/router.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Profile Page'),
            const SizedBox(height: 20),
            InkWell(
              onTap: () async {
                await appStorage.deleteValue(AppStorageKey.accessToken);
                await appStorage.deleteValue(AppStorageKey.refreshToken);
                if (context.mounted) {
                  context.pushReplacement(RouteName.signIn.path);
                }
              },
              child: Container(
                height: 54,
                constraints: const BoxConstraints(maxWidth: 400),
                decoration: BoxDecoration(
                  color: AppColors.primaryBrand900,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Center(
                  child: Text(
                    'Log out',
                    style: AppTextStyle.of(
                      size: 16,
                      color: AppColors.white900,
                      weight: AppFontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
