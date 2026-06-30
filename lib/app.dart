import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:taxi_passenger/core/app_dependencies.dart';
import 'package:taxi_passenger/core/auth/auth_session_notifier.dart';
import 'package:taxi_passenger/core/config/firebase_config.dart';
import 'package:taxi_passenger/core/routing/app_router.dart';
import 'package:taxi_passenger/core/theme/app_theme.dart';
import 'package:taxi_passenger/presentation/auth/bloc/auth_bloc.dart';
import 'package:taxi_passenger/presentation/home/bloc/map_bloc.dart';
import 'package:taxi_passenger/presentation/order/bloc/order_bloc.dart';
import 'package:taxi_passenger/presentation/order/bloc/order_realtime_bloc.dart';
import 'package:taxi_passenger/presentation/profile/bloc/passenger_profile_bloc.dart';

class PassengerApp extends StatefulWidget {
  const PassengerApp({super.key, required this.dependencies});

  final AppDependencies dependencies;

  @override
  State<PassengerApp> createState() => _PassengerAppState();
}

class _PassengerAppState extends State<PassengerApp> {
  @override
  void dispose() {
    widget.dependencies.authSessionNotifier.dispose();
    widget.dependencies.pushNotificationService.dispose();
    widget.dependencies.webSocketService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: widget.dependencies.authRepository),
        RepositoryProvider<AuthSessionNotifier>.value(
          value: widget.dependencies.authSessionNotifier,
        ),
        RepositoryProvider.value(value: widget.dependencies.geoRepository),
        RepositoryProvider.value(value: widget.dependencies.legalRepository),
        RepositoryProvider.value(value: widget.dependencies.orderRepository),
        RepositoryProvider.value(value: widget.dependencies.profileRepository),
        RepositoryProvider.value(value: widget.dependencies.webSocketService),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AuthBloc(
              authRepository: widget.dependencies.authRepository,
            )..add(const AuthBootstrapRequested()),
          ),
          BlocProvider(
            create: (_) => PassengerProfileBloc(
              profileRepository: widget.dependencies.profileRepository,
            ),
          ),
          BlocProvider(
            create: (_) => MapBloc(
              geoRepository: widget.dependencies.geoRepository,
            ),
          ),
          BlocProvider(
            create: (_) => OrderBloc(
              orderRepository: widget.dependencies.orderRepository,
            ),
          ),
          BlocProvider(
            create: (_) => OrderRealtimeBloc(
              webSocketService: widget.dependencies.webSocketService,
            ),
          ),
        ],
        child: _AuthSessionWatcher(
          child: BlocListener<AuthBloc, AuthState>(
            listenWhen: (previous, current) => previous.status != current.status,
            listener: (context, state) async {
              if (!FirebaseConfig.pushEnabled) {
                return;
              }
              if (state.status == AuthStatus.authenticated) {
                await widget.dependencies.pushNotificationService.syncToken();
              }
            },
            child: MaterialApp.router(
              debugShowCheckedModeBanner: false,
              theme: AppTheme.light(),
              routerConfig: AppRouter.router,
            ),
          ),
        ),
      ),
    );
  }
}

class _AuthSessionWatcher extends StatefulWidget {
  const _AuthSessionWatcher({required this.child});

  final Widget child;

  @override
  State<_AuthSessionWatcher> createState() => _AuthSessionWatcherState();
}

class _AuthSessionWatcherState extends State<_AuthSessionWatcher> {
  StreamSubscription<void>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = context
        .read<AuthSessionNotifier>()
        .sessionExpiredStream
        .listen((_) {
      if (!mounted) {
        return;
      }
      context.read<AuthBloc>().add(const AuthSessionExpired());
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}
