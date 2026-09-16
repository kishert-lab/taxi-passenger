import 'package:go_router/go_router.dart';
import 'package:taxi_passenger/domain/models/models.dart';
import 'package:taxi_passenger/presentation/auth/screens/auth_code_screen.dart';
import 'package:taxi_passenger/presentation/auth/screens/auth_phone_screen.dart';
import 'package:taxi_passenger/presentation/auth/screens/splash_screen.dart';
import 'package:taxi_passenger/presentation/history/screens/orders_history_screen.dart';
import 'package:taxi_passenger/presentation/home/screens/address_search_screen.dart';
import 'package:taxi_passenger/presentation/home/screens/passenger_home_screen.dart';
import 'package:taxi_passenger/presentation/order/screens/active_order_screen.dart';
import 'package:taxi_passenger/presentation/order/screens/order_completed_screen.dart';
import 'package:taxi_passenger/presentation/order/screens/order_searching_screen.dart';
import 'package:taxi_passenger/presentation/order/screens/trip_in_progress_screen.dart';
import 'package:taxi_passenger/presentation/profile/screens/profile_screen.dart';

class AppRouter {
  const AppRouter._();

  static final router = GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(path: '/', builder: (_, __) => const SplashScreen()),
      GoRoute(path: '/auth/phone', builder: (_, __) => const AuthPhoneScreen()),
      GoRoute(
        path: '/auth/code',
        builder: (_, state) => AuthCodeScreen(phone: state.extra! as String),
      ),
      GoRoute(path: '/home', builder: (_, __) => const PassengerHomeScreen()),
      GoRoute(
        path: '/address-search',
        builder: (_, state) =>
            AddressSearchScreen(mode: state.extra! as AddressSearchMode),
      ),
      GoRoute(
        path: '/order/searching',
        builder: (_, __) => const OrderSearchingScreen(),
      ),
      GoRoute(
        path: '/order/active',
        builder: (_, __) => const ActiveOrderScreen(),
      ),
      GoRoute(
        path: '/order/trip',
        builder: (_, __) => const TripInProgressScreen(),
      ),
      GoRoute(
        path: '/order/completed',
        builder: (_, state) =>
            OrderCompletedScreen(order: state.extra! as Order),
      ),
      GoRoute(
        path: '/orders/history',
        builder: (_, __) => const OrdersHistoryScreen(),
      ),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
    ],
  );
}
