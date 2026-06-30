import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:taxi_passenger/core/auth/auth_session_notifier.dart';
import 'package:taxi_passenger/core/auth/auth_tokens.dart';
import 'package:taxi_passenger/core/constants/api_endpoints.dart';
import 'package:taxi_passenger/core/errors/app_exception.dart';
import 'package:taxi_passenger/core/storage/token_storage.dart';

class ApiClient {
  ApiClient({
    required Dio dio,
    required TokenStorage tokenStorage,
    required AuthSessionNotifier authSessionNotifier,
  })  : _dio = dio,
        _refreshDio = Dio(dio.options),
        _tokenStorage = tokenStorage,
        _authSessionNotifier = authSessionNotifier {
    if (kDebugMode) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: false,
          responseHeader: false,
        ),
      );
    }

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          if (options.extra['requiresAuthorization'] == false) {
            handler.next(options);
            return;
          }

          final token = await _tokenStorage.getAccessToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }

          handler.next(options);
        },
        onError: (exception, handler) async {
          if (_shouldTryRefresh(exception)) {
            final refreshedTokens = await _refreshTokens();
            if (refreshedTokens != null) {
              final response = await _retryRequest(
                exception.requestOptions,
                refreshedTokens.accessToken,
              );
              handler.resolve(response);
              return;
            }

            _authSessionNotifier.notifySessionExpired();
          }

          if (_shouldInvalidateSessionAfterRetry(exception)) {
            await _tokenStorage.clear();
            _authSessionNotifier.notifySessionExpired();
          }

          final message = _buildErrorMessage(
            statusCode: exception.response?.statusCode,
            responseData: exception.response?.data,
            errorType: exception.type,
          );

          handler.reject(
            DioException(
              requestOptions: exception.requestOptions,
              response: exception.response,
              error: AppException(
                message,
                statusCode: exception.response?.statusCode,
              ),
              type: exception.type,
            ),
          );
        },
      ),
    );
  }

  final Dio _dio;
  final Dio _refreshDio;
  final TokenStorage _tokenStorage;
  final AuthSessionNotifier _authSessionNotifier;
  Future<AuthTokens?>? _refreshOperation;

  Future<dynamic> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuthorization = true,
    bool skipAuthRefresh = false,
  }) async {
    final response = await _dio.get<dynamic>(
      path,
      queryParameters: queryParameters,
      options: _options(
        requiresAuthorization: requiresAuthorization,
        skipAuthRefresh: skipAuthRefresh,
      ),
    );
    return _unwrapData(response.data);
  }

  Future<Map<String, dynamic>> getRaw(
    String path, {
    Map<String, dynamic>? queryParameters,
    bool requiresAuthorization = true,
    bool skipAuthRefresh = false,
  }) async {
    final response = await _dio.get<Map<String, dynamic>>(
      path,
      queryParameters: queryParameters,
      options: _options(
        requiresAuthorization: requiresAuthorization,
        skipAuthRefresh: skipAuthRefresh,
      ),
    );
    return response.data ?? <String, dynamic>{};
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic>? data,
    bool requiresAuthorization = true,
    bool skipAuthRefresh = false,
  }) async {
    final response = await _dio.post<dynamic>(
      path,
      data: data,
      options: _options(
        requiresAuthorization: requiresAuthorization,
        skipAuthRefresh: skipAuthRefresh,
      ),
    );
    return _unwrapData(response.data);
  }

  Future<Map<String, dynamic>> postRaw(
    String path, {
    Map<String, dynamic>? data,
    bool requiresAuthorization = true,
    bool skipAuthRefresh = false,
  }) async {
    final response = await _dio.post<Map<String, dynamic>>(
      path,
      data: data,
      options: _options(
        requiresAuthorization: requiresAuthorization,
        skipAuthRefresh: skipAuthRefresh,
      ),
    );
    return response.data ?? <String, dynamic>{};
  }

  Future<dynamic> patch(
    String path, {
    Map<String, dynamic>? data,
    bool requiresAuthorization = true,
    bool skipAuthRefresh = false,
  }) async {
    final response = await _dio.patch<dynamic>(
      path,
      data: data,
      options: _options(
        requiresAuthorization: requiresAuthorization,
        skipAuthRefresh: skipAuthRefresh,
      ),
    );
    return _unwrapData(response.data);
  }

  Future<Map<String, dynamic>> patchRaw(
    String path, {
    Map<String, dynamic>? data,
    bool requiresAuthorization = true,
    bool skipAuthRefresh = false,
  }) async {
    final response = await _dio.patch<Map<String, dynamic>>(
      path,
      data: data,
      options: _options(
        requiresAuthorization: requiresAuthorization,
        skipAuthRefresh: skipAuthRefresh,
      ),
    );
    return response.data ?? <String, dynamic>{};
  }

  Options _options({
    required bool requiresAuthorization,
    required bool skipAuthRefresh,
  }) {
    return Options(
      extra: {
        'requiresAuthorization': requiresAuthorization,
        'skipAuthRefresh': skipAuthRefresh,
      },
    );
  }

  Future<AuthTokens?> _refreshTokens() async {
    final inFlight = _refreshOperation;
    if (inFlight != null) {
      return inFlight;
    }

    final refreshFuture = _performRefresh();
    _refreshOperation = refreshFuture;
    try {
      return await refreshFuture;
    } finally {
      if (identical(_refreshOperation, refreshFuture)) {
        _refreshOperation = null;
      }
    }
  }

  Future<AuthTokens?> _performRefresh() async {
    final refreshToken = await _tokenStorage.getRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      return null;
    }

    try {
      final response = await _refreshDio.post<Map<String, dynamic>>(
        ApiEndpoints.refresh,
        data: {'refresh_token': refreshToken},
      );
      final tokens = AuthTokens.fromResponse(response.data ?? <String, dynamic>{});
      if (tokens.accessToken.isEmpty || tokens.refreshToken.isEmpty) {
        await _tokenStorage.clear();
        return null;
      }

      await _tokenStorage.saveTokens(tokens);
      return tokens;
    } catch (_) {
      await _tokenStorage.clear();
      return null;
    }
  }

  Future<Response<dynamic>> _retryRequest(
    RequestOptions requestOptions,
    String accessToken,
  ) {
    requestOptions.headers['Authorization'] = 'Bearer $accessToken';
    requestOptions.extra['skipAuthRefresh'] = true;
    return _dio.fetch<dynamic>(requestOptions);
  }

  String _buildErrorMessage({
    required int? statusCode,
    required Object? responseData,
    required DioExceptionType errorType,
  }) {
    String? backendMessage;

    if (responseData is Map<String, dynamic>) {
      final error = responseData['error'];
      if (error is Map<String, dynamic>) {
        backendMessage = error['message']?.toString() ?? error['code']?.toString();
      } else {
        backendMessage = responseData['message']?.toString() ??
            responseData['error']?.toString();
      }
    } else if (responseData is String && responseData.isNotEmpty) {
      backendMessage = responseData;
    }

    if (backendMessage != null && backendMessage.isNotEmpty) {
      return statusCode != null
          ? 'HTTP $statusCode: $backendMessage'
          : backendMessage;
    }

    if (statusCode != null) {
      return 'HTTP $statusCode';
    }

    switch (errorType) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return 'Таймаут соединения';
      case DioExceptionType.connectionError:
        return 'Нет соединения с сервером';
      default:
        return 'Ошибка соединения';
    }
  }

  bool _shouldTryRefresh(DioException exception) {
    if (exception.response?.statusCode != 401) {
      return false;
    }

    final extra = exception.requestOptions.extra;
    if (extra['skipAuthRefresh'] == true ||
        extra['requiresAuthorization'] == false) {
      return false;
    }

    return true;
  }

  bool _shouldInvalidateSessionAfterRetry(DioException exception) {
    if (exception.response?.statusCode != 401) {
      return false;
    }

    final extra = exception.requestOptions.extra;
    return extra['skipAuthRefresh'] == true &&
        extra['requiresAuthorization'] != false;
  }

  dynamic _unwrapData(dynamic responseData) {
    if (responseData is Map<String, dynamic> && responseData.containsKey('data')) {
      return responseData['data'];
    }

    return responseData;
  }
}
