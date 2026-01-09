import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../blocs/users/users_bloc.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JSONPlaceholder Users'),
        actions: [
          IconButton(
            onPressed: () {
              context.read<UsersBloc>().add(const FetchUsersEvent());
            },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: BlocBuilder<UsersBloc, UsersState>(
        builder: (context, state) {
          if (state is UsersInitial) {
            return const Center(child: Text('Press refresh to load users'));
          } else if (state is UsersLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is UsersLoaded) {
            return _buildUsersList(state.users);
          } else if (state is UsersError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    state.message,
                    textAlign: TextAlign.center,
                    style: AppTypography.of(size: 16, color: Colors.red),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.read<UsersBloc>().add(const FetchUsersEvent());
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildUsersList(dynamic users) {
    return ListView.builder(
      padding: const EdgeInsets.all(8),
      itemCount: users.length,
      itemBuilder: (context, index) {
        final user = users[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 4),
          child: ListTile(
            leading: CircleAvatar(child: Text('${user.id}')),
            title: Text(
              user.name,
              style: AppTypography.of(size: 16, weight: AppFontWeight.semiBold),
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text('@${user.username}', style: TextStyle(fontSize: 12)),
                const SizedBox(height: 4),
                Text(
                  user.email,
                  style: TextStyle(fontSize: 12, color: Colors.blue),
                ),
                const SizedBox(height: 4),
                Text(user.phone, style: TextStyle(fontSize: 12)),
              ],
            ),
            isThreeLine: true,
          ),
        );
      },
    );
  }
}
