import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxi_passenger/core/widgets/app_state_widgets.dart';
import 'package:taxi_passenger/presentation/auth/bloc/auth_bloc.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listenWhen: (previous, current) => previous.status != current.status,
      listener: (context, state) {
        switch (state.status) {
          case AuthStatus.authenticated:
            context.go('/home');
          case AuthStatus.unauthenticated:
            context.go('/auth/phone');
          default:
            break;
        }
      },
      child: const Scaffold(
        body: FullScreenLoader(message: 'Запуск приложения...'),
      ),
    );
  }
}
