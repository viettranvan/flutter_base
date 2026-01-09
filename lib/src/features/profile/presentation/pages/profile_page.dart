import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/generated/l10n.dart';
import 'package:flutter_base/src/core/config/env_config.dart';
import 'package:flutter_base/src/router/router.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(S.of(context).profile)),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            Visibility(
              visible: EnvConfig.isDevelopment(),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 20),
                child: AppButton(
                  onPressed: () async {
                    if (context.mounted) {
                      context.push(RouteName.debug.path);
                    }
                  },
                  title: 'Debug',
                ),
              ),
            ),
            AppButton(
              onPressed: () async {
                await appStorage.deleteValue(AppStorageKey.accessToken);
                await appStorage.deleteValue(AppStorageKey.refreshToken);
                if (context.mounted) {
                  context.pushReplacement(RouteName.signIn.path);
                }
              },
              title: S.current.logout,
            ),
          ],
        ),
      ),
    );
  }
}
