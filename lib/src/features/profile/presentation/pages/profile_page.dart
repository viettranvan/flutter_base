import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/generated/l10n.dart';
import 'package:flutter_base/src/core/index.dart';
import 'package:flutter_base/src/features/profile/profile_index.dart';
import 'package:flutter_base/src/router/router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late final ProfileBloc _profileBloc;

  @override
  void initState() {
    super.initState();
    _profileBloc = context.read<ProfileBloc>();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(S.of(context).profile),
        actions: [
          // Refresh button
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              _profileBloc.add(const RefreshUserProfileEvent());
            },
          ),
        ],
      ),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          if (state is ProfileLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ProfileError) {
            return _buildErrorState(context, state.exception);
          }

          if (state is ProfileLoaded) {
            return _buildProfileContent(context, state.userProfile);
          }

          return const Center(child: Text('Unknown state'));
        },
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, User profile) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Profile Header
          _buildProfileHeader(profile),
          const SizedBox(height: 24),

          // User Info Section
          _buildUserInfoSection(profile),
          const SizedBox(height: 24),

          // Debug & Logout buttons
          if (EnvConfig.isDevelopment())
            Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: AppButton(
                onPressed: () async {
                  if (context.mounted) {
                    context.push(RouteName.debug.path);
                  }
                },
                title: 'Debug',
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
    );
  }

  Widget _buildProfileHeader(User profile) {
    return Column(
      children: [
        // Avatar
        if (profile.image != null && profile.image!.isNotEmpty)
          CircleAvatar(
            radius: 50,
            backgroundImage: NetworkImage(profile.image!),
          )
        else
          CircleAvatar(
            radius: 50,
            child: Text(profile.fullName[0].toUpperCase()),
          ),
        const SizedBox(height: 16),

        // Name & Email
        Text(
          profile.fullName,
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 8),
      ],
    );
  }

  Widget _buildUserInfoSection(User profile) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _sectionTitle('Personal Information'),
        const SizedBox(height: 12),
        _infoTile('Full Name', '${profile.firstName} ${profile.lastName}'),
      ],
    );
  }

  Widget _buildErrorState(BuildContext context, AppException exception) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading profile',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              exception.message,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 24),
            AppButton(
              onPressed: () {
                _profileBloc.add(const FetchUserProfileEvent());
              },
              title: 'Retry',
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
    );
  }

  Widget _infoTile(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[600]),
          ),
          Flexible(
            child: Text(
              value,
              textAlign: TextAlign.end,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
