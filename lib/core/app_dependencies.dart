import 'package:dio/dio.dart';
import 'package:taxi_passenger/core/auth/auth_session_notifier.dart';
import 'package:taxi_passenger/core/config/app_endpoints_config.dart';
import 'package:taxi_passenger/core/storage/token_storage.dart';
import 'package:taxi_passenger/data/api/api_client.dart';
import 'package:taxi_passenger/data/api/passenger_auth_api.dart';
import 'package:taxi_passenger/data/api/passenger_car_classes_api.dart';
import 'package:taxi_passenger/data/api/passenger_geo_api.dart';
import 'package:taxi_passenger/data/api/passenger_orders_api.dart';
import 'package:taxi_passenger/data/api/passenger_profile_api.dart';
import 'package:taxi_passenger/data/api/passenger_push_api.dart';
import 'package:taxi_passenger/data/api/public_legal_api.dart';
import 'package:taxi_passenger/data/repositories/auth_repository.dart';
import 'package:taxi_passenger/data/repositories/car_class_repository.dart';
import 'package:taxi_passenger/data/repositories/geo_repository.dart';
import 'package:taxi_passenger/data/repositories/legal_repository.dart';
import 'package:taxi_passenger/data/repositories/order_repository.dart';
import 'package:taxi_passenger/data/repositories/profile_repository.dart';
import 'package:taxi_passenger/data/repositories/push_repository.dart';
import 'package:taxi_passenger/data/services/backend_availability_service.dart';
import 'package:taxi_passenger/data/services/current_location_service.dart';
import 'package:taxi_passenger/data/services/passenger_push_notification_service.dart';
import 'package:taxi_passenger/data/services/passenger_websocket_service.dart';

class AppDependencies {
  AppDependencies({
    required this.authRepository,
    required this.authSessionNotifier,
    required this.backendAvailabilityService,
    required this.carClassRepository,
    required this.geoRepository,
    required this.legalRepository,
    required this.orderRepository,
    required this.profileRepository,
    required this.pushNotificationService,
    required this.webSocketService,
  });

  final AuthRepository authRepository;
  final AuthSessionNotifier authSessionNotifier;
  final BackendAvailabilityService backendAvailabilityService;
  final CarClassRepository carClassRepository;
  final GeoRepository geoRepository;
  final LegalRepository legalRepository;
  final OrderRepository orderRepository;
  final ProfileRepository profileRepository;
  final PassengerPushNotificationService pushNotificationService;
  final PassengerWebSocketService webSocketService;

  static AppDependencies create() {
    final tokenStorage = TokenStorage();
    final authSessionNotifier = AuthSessionNotifier();
    final dio = Dio(
      BaseOptions(
        baseUrl: AppEndpointsConfig.httpBaseUrl,
        connectTimeout: const Duration(seconds: 15),
        receiveTimeout: const Duration(seconds: 15),
        sendTimeout: const Duration(seconds: 15),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    final apiClient = ApiClient(
      dio: dio,
      tokenStorage: tokenStorage,
      authSessionNotifier: authSessionNotifier,
    );
    final authApi = PassengerAuthApi(apiClient);
    final carClassesApi = PassengerCarClassesApi(apiClient);
    final geoApi = PassengerGeoApi(apiClient);
    final ordersApi = PassengerOrdersApi(apiClient);
    final profileApi = PassengerProfileApi(apiClient);
    final pushApi = PassengerPushApi(apiClient);
    final publicLegalApi = PublicLegalApi(apiClient);
    final backendAvailabilityService = BackendAvailabilityService(
      publicLegalApi: publicLegalApi,
    );
    final currentLocationService = CurrentLocationService();
    final authRepository = AuthRepository(
      authApi: authApi,
      tokenStorage: tokenStorage,
    );

    return AppDependencies(
      authRepository: authRepository,
      authSessionNotifier: authSessionNotifier,
      backendAvailabilityService: backendAvailabilityService,
      carClassRepository: CarClassRepository(carClassesApi: carClassesApi),
      geoRepository: GeoRepository(
        geoApi: geoApi,
        currentLocationService: currentLocationService,
      ),
      legalRepository: LegalRepository(publicLegalApi: publicLegalApi),
      orderRepository: OrderRepository(ordersApi: ordersApi),
      profileRepository: ProfileRepository(profileApi: profileApi),
      pushNotificationService: PassengerPushNotificationService(
        pushRepository: PushRepository(pushApi: pushApi),
        authRepository: authRepository,
      ),
      webSocketService: PassengerWebSocketService(
        tokenStorage: tokenStorage,
        wsBaseUrl: AppEndpointsConfig.wsBaseUrl,
      ),
    );
  }
}
