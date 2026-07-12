import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../home/presentation/screens/student_navigation_screen.dart';
import '../../../startups/presentation/screens/admin_verification_screen.dart';
import '../../../startups/presentation/screens/startup_dashboard_screen.dart';
import '../cubit/auth_cubit.dart';
import '../cubit/auth_state.dart';
import 'login_screen.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is AuthAuthenticated) {
          if (state.user.isAdmin) {
            return AdminVerificationScreen(
              user: state.user,
            );
          }

          if (state.user.isStartup) {
            return StartupDashboardScreen(
              user: state.user,
            );
          }

          return StudentNavigationScreen(
            user: state.user,
          );
        }

        if (state is AuthUnauthenticated ||
            state is AuthFailure) {
          return const LoginScreen();
        }

        return const _LoadingScreen();
      },
    );
  }
}

class _LoadingScreen extends StatelessWidget {
  const _LoadingScreen();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Connecting to VentureLink...'),
          ],
        ),
      ),
    );
  }
}