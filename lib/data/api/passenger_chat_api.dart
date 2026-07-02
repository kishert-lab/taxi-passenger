import 'package:taxi_passenger/core/constants/api_endpoints.dart';
import 'package:taxi_passenger/data/api/api_client.dart';
import 'package:taxi_passenger/domain/models/models.dart';

class PassengerChatApi {
  PassengerChatApi(this._apiClient);

  final ApiClient _apiClient;

  Future<List<ChatMessage>> loadDriverChatMessages(String orderId) async {
    final response = await _apiClient.get(
      ApiEndpoints.orderDriverChatMessages(orderId),
    );
    return ChatMessagesResponse.fromJson(response).messages;
  }

  Future<ChatMessage> sendDriverChatMessage({
    required String orderId,
    required String body,
  }) async {
    final response = await _apiClient.post(
      ApiEndpoints.orderDriverChatMessages(orderId),
      data: {'body': body},
    );
    return ChatMessage.fromJson(
      response as Map<String, dynamic>? ?? <String, dynamic>{},
    );
  }

  Future<List<ChatMessage>> loadSupportChatMessages() async {
    final response = await _apiClient.get(ApiEndpoints.supportChatMessages);
    return ChatMessagesResponse.fromJson(response).messages;
  }

  Future<ChatMessage> sendSupportChatMessage({required String body}) async {
    final response = await _apiClient.post(
      ApiEndpoints.supportChatMessages,
      data: {'body': body},
    );
    return ChatMessage.fromJson(
      response as Map<String, dynamic>? ?? <String, dynamic>{},
    );
  }
}
