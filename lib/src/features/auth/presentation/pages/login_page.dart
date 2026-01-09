import 'package:app_core/app_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_base/src/features/auth/presentation/blocs/login/login_bloc.dart';
import 'package:flutter_base/src/injection_container.dart';
import 'package:flutter_base/src/router/router.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login Page')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: BlocProvider(
          create: (context) => sl<LoginBloc>(),
          child: BlocConsumer<LoginBloc, LoginState>(
            listener: (context, state) {
              switch (state) {
                case LoginLoading _:
                  // show loading indicator
                  break;
                case LoginSuccessful _:
                  context.pushReplacement(RouteName.home.path);
                  break;
                case LoginInitial _:
                  break;
              }
            },
            builder: (context, state) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Welcome to the Login Page!'),
                  const SizedBox(height: 20),
                  const Text('Email'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: context.read<LoginBloc>().emailCtrl,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'Enter your email',
                    ),
                  ),
                  const SizedBox(height: 24),
                  const Text('Password'),
                  const SizedBox(height: 10),
                  TextField(
                    controller: context.read<LoginBloc>().passworkCtrl,
                    obscureText: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      hintText: 'Enter your password',
                    ),
                  ),
                  const SizedBox(height: 20),
                  InkWell(
                    onTap: () {
                      context.read<LoginBloc>().add(LoginRequested());
                    },
                    child: Container(
                      height: 60,
                      padding: EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        color: Colors.blue,
                      ),
                      child: Center(
                        child: Text(
                          "Login",
                          style: AppTypography.of(color: AppColors.white900),
                        ),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
