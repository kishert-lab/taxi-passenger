import 'package:taxi_passenger/core/constants/api_endpoints.dart';
import 'package:taxi_passenger/core/errors/app_exception.dart';
import 'package:taxi_passenger/data/api/api_client.dart';
import 'package:taxi_passenger/domain/models/models.dart';

class PassengerOrdersApi {
  PassengerOrdersApi(this._apiClient);

  final ApiClient _apiClient;

  Future<RouteEstimate> estimateOrder(OrderEstimateRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.routeEstimate,
      data: request.toJson(),
    );

    return RouteEstimate.fromJson(
      response as Map<String, dynamic>? ?? <String, dynamic>{},
    );
  }

  Future<Order> createOrder(CreateOrderRequest request) async {
    final response = await _apiClient.post(
      ApiEndpoints.orders,
      data: request.toJson(),
    );

    return PassengerOrderResponse.fromJson(
      response as Map<String, dynamic>? ?? <String, dynamic>{},
    );
  }

  Future<Order?> loadCurrentOrder() async {
    try {
      final response = await _apiClient.get(ApiEndpoints.orderCurrent);
      if (response == null) {
        return null;
      }

      return PassengerOrderResponse.fromJson(
        response as Map<String, dynamic>? ?? <String, dynamic>{},
      );
    } on AppException catch (error) {
      if (error.statusCode == 404) {
        return null;
      }
      rethrow;
    }
  }

  Future<Order> loadOrderDetails(String orderId) async {
    final response = await _apiClient.get(ApiEndpoints.orderDetails(orderId));
    return PassengerOrderResponse.fromJson(
      response as Map<String, dynamic>? ?? <String, dynamic>{},
    );
  }

  Future<Order> cancelOrder(String orderId, {required String reason}) async {
    final response = await _apiClient.post(
      ApiEndpoints.cancelOrder(orderId),
      data: {'reason': reason},
    );

    return PassengerOrderResponse.fromJson(
      response as Map<String, dynamic>? ?? <String, dynamic>{},
    );
  }

  Future<void> rateOrder({
    required String orderId,
    required int rating,
    String? comment,
  }) async {
    await _apiClient.post(
      ApiEndpoints.rateOrder(orderId),
      data: {
        'score': rating,
        if (comment != null && comment.isNotEmpty) 'comment': comment,
      },
    );
  }

  Future<List<Order>> loadOrders() async {
    final response = await _apiClient.get(ApiEndpoints.orderHistory);
    return OrderHistoryResponse.fromJson(response).orders;
  }
}
