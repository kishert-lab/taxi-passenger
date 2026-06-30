import 'package:taxi_passenger/data/api/api_client.dart';

class LegalDocument {
  const LegalDocument({
    required this.id,
    required this.title,
    required this.content,
    required this.version,
    required this.documentType,
  });

  final String id;
  final String title;
  final String content;
  final String version;
  final String documentType;

  factory LegalDocument.fromJson(Map<String, dynamic> json) {
    return LegalDocument(
      id: json['id']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      content: json['content']?.toString() ?? '',
      version: json['version']?.toString() ?? '',
      documentType: json['document_type']?.toString() ?? '',
    );
  }
}

class PublicLegalApi {
  PublicLegalApi(this._apiClient);

  final ApiClient _apiClient;

  Future<LegalDocument> loadConsent({String language = 'ru'}) async {
    final response = await _apiClient.get(
      '/api/v1/public/legal/consent',
      queryParameters: {'language': language},
      requiresAuthorization: false,
    );
    final data = response['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return LegalDocument.fromJson(data);
  }

  Future<LegalDocument> loadTerms({String language = 'ru'}) async {
    final response = await _apiClient.get(
      '/api/v1/public/legal/terms',
      queryParameters: {'language': language},
      requiresAuthorization: false,
    );
    final data = response['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return LegalDocument.fromJson(data);
  }

  Future<LegalDocument> loadPrivacyPolicy({String language = 'ru'}) async {
    final response = await _apiClient.get(
      '/api/v1/public/legal/privacy-policy',
      queryParameters: {'language': language},
      requiresAuthorization: false,
    );
    final data = response['data'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return LegalDocument.fromJson(data);
  }
}
