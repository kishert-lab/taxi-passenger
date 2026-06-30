import 'package:taxi_passenger/data/api/public_legal_api.dart';

class LegalRepository {
  LegalRepository({required PublicLegalApi publicLegalApi})
      : _publicLegalApi = publicLegalApi;

  final PublicLegalApi _publicLegalApi;

  Future<LegalDocument> loadConsent() {
    return _publicLegalApi.loadConsent();
  }

  Future<LegalDocument> loadTerms() {
    return _publicLegalApi.loadTerms();
  }

  Future<LegalDocument> loadPrivacyPolicy() {
    return _publicLegalApi.loadPrivacyPolicy();
  }
}
