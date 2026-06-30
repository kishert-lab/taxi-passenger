class ApiEndpoints {
  const ApiEndpoints._();

  static const requestCode = '/api/v1/passenger/auth/request-code';
  static const confirmCode = '/api/v1/passenger/auth/confirm-code';
  static const refresh = '/api/v1/passenger/auth/refresh';
  static const logout = '/api/v1/passenger/auth/logout';
  static const nearbyCars = '/api/v1/passenger/nearby-cars';
  static const routeEstimate = '/api/v1/passenger/orders/estimate';
  static const orders = '/api/v1/passenger/orders';
  static const orderCurrent = '/api/v1/passenger/orders/current';
  static const orderHistory = '/api/v1/passenger/orders/history';
  static const me = '/api/v1/passenger/me';
  static const addressSearch = '/api/v1/passenger/address/search';
  static const webSocket = '/api/v1/ws';
  static const pushToken = '/api/v1/passenger/push/token';
}
