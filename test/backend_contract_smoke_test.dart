import 'package:taxi_passenger/core/auth/auth_tokens.dart';
import 'package:taxi_passenger/core/constants/api_endpoints.dart';
import 'package:taxi_passenger/domain/models/models.dart';
import 'package:test/test.dart';

void main() {
  group('Auth contract', () {
    test('request/logout/refresh endpoints are passenger endpoints', () {
      expect(
        ApiEndpoints.requestCode,
        '/api/v1/passenger/auth/request-code',
      );
      expect(
        ApiEndpoints.refresh,
        '/api/v1/passenger/auth/refresh',
      );
      expect(
        ApiEndpoints.logout,
        '/api/v1/passenger/auth/logout',
      );
    });

    test('confirm-code envelope parses tokens and passenger', () {
      final session = PassengerAuthSession.fromResponse({
        'data': {
          'access_token': 'access-1',
          'refresh_token': 'refresh-1',
          'token_type': 'Bearer',
          'expires_in': 900,
          'passenger': {
            'id': 'passenger-1',
            'phone': '+79997778866',
            'name': 'Ирина',
            'avatar_url': 'https://cdn/avatar.png',
          },
        },
      });

      expect(session.tokens.accessToken, 'access-1');
      expect(session.tokens.refreshToken, 'refresh-1');
      expect(session.passenger.phone, '+79997778866');
      expect(session.passenger.avatarUrl, 'https://cdn/avatar.png');
    });

    test('refresh envelope parses tokens', () {
      final tokens = AuthTokens.fromResponse({
        'data': {
          'access_token': 'access-2',
          'refresh_token': 'refresh-2',
          'expires_in': 900,
        },
      });

      expect(tokens.accessToken, 'access-2');
      expect(tokens.refreshToken, 'refresh-2');
      expect(tokens.expiresIn, 900);
    });
  });

  group('Passenger/profile/address contract', () {
    test('passenger supports avatar_url and avatar', () {
      final avatarUrlPassenger = Passenger.fromJson({
        'id': '1',
        'phone': '+7',
        'avatar_url': 'https://cdn/a.png',
      });
      final avatarPassenger = Passenger.fromJson({
        'id': '1',
        'phone': '+7',
        'avatar': 'https://cdn/b.png',
      });

      expect(avatarUrlPassenger.avatarUrl, 'https://cdn/a.png');
      expect(avatarPassenger.avatarUrl, 'https://cdn/b.png');
    });

    test('address search point parses city_id and serializes to latitude/longitude', () {
      final point = GeoPoint.fromAddressSearchJson({
        'name': 'Ленина 50',
        'address': 'Екатеринбург, Ленина 50',
        'city_id': 'city-1',
        'coordinates': {
          'latitude': 56.8389,
          'longitude': 60.6057,
        },
      });

      expect(point.address, 'Екатеринбург, Ленина 50');
      expect(point.cityId, 'city-1');
      expect(point.toJson(), {
        'latitude': 56.8389,
        'longitude': 60.6057,
      });
    });
  });

  group('Order DTO contract', () {
    test('estimate request serializes backend payload', () {
      const request = OrderEstimateRequest(
        cityId: 'city-1',
        tariffId: 'tariff-1',
        pickupLocation: GeoPoint(
          lat: 56.8389,
          lng: 60.6057,
          address: 'Ленина 1',
          cityId: 'city-1',
        ),
        destinationLocation: GeoPoint(
          lat: 56.8489,
          lng: 60.6157,
          address: 'Мира 10',
          cityId: 'city-1',
        ),
      );

      expect(request.toJson(), {
        'city_id': 'city-1',
        'tariff_id': 'tariff-1',
        'pickup_location': {'latitude': 56.8389, 'longitude': 60.6057},
        'destination_location': {'latitude': 56.8489, 'longitude': 60.6157},
      });
    });

    test('create order request serializes backend payload', () {
      const request = CreateOrderRequest(
        cityId: 'city-1',
        pickupLocation: GeoPoint(
          lat: 56.8389,
          lng: 60.6057,
          address: 'Ленина 1',
          cityId: 'city-1',
        ),
        pickupAddress: 'Ленина 1',
        destinationLocation: GeoPoint(
          lat: 56.8489,
          lng: 60.6157,
          address: 'Мира 10',
          cityId: 'city-1',
        ),
        destinationAddress: 'Мира 10',
        tariffId: 'tariff-1',
        paymentType: 'cash',
        comment: '',
        passengerPhone: '+79997778866',
      );

      expect(request.toJson(), {
        'city_id': 'city-1',
        'pickup_location': {'latitude': 56.8389, 'longitude': 60.6057},
        'pickup_address': 'Ленина 1',
        'destination_location': {'latitude': 56.8489, 'longitude': 60.6157},
        'destination_address': 'Мира 10',
        'tariff_id': 'tariff-1',
        'payment_type': 'cash',
        'comment': '',
        'passenger_phone': '+79997778866',
      });
    });

    test('estimate response parses backend dto', () {
      final estimate = RouteEstimate.fromJson({
        'tariff_id': 'tariff-1',
        'tariff_name': 'Economy',
        'distance_km': 4.2,
        'duration_min': 11,
        'price': 250,
        'currency': 'RUB',
        'price_type': 'estimated',
      });

      expect(estimate.tariffId, 'tariff-1');
      expect(estimate.etaMinutes, 11);
      expect(estimate.price, 250);
      expect(estimate.tariffs.single.id, 'tariff-1');
    });

    test('current order and history parse passenger order dto', () {
      final current = PassengerOrderResponse.fromJson(_orderJson('driver_arriving'));
      final history = OrderHistoryResponse.fromJson({
        'orders': [_orderJson('completed')],
      });

      expect(current.id, 'order-1');
      expect(current.status, OrderStatus.driverArriving);
      expect(current.pickup.address, 'Ленина 1');
      expect(current.car?.plateNumber, 'А123АА96');
      expect(history.orders.single.status, OrderStatus.completed);
    });
  });

  group('WebSocket contract', () {
    test('sync.required and driver.location_updated parse correctly', () {
      final sync = OrderEvent.fromJson({
        'event': 'sync.required',
        'request_id': 'req-1',
        'occurred_at': '2026-06-30T10:00:00Z',
        'payload': {'reason': 'reconnect'},
      });
      final location = OrderEvent.fromJson({
        'event': 'driver.location_updated',
        'request_id': 'req-2',
        'occurred_at': '2026-06-30T10:00:01Z',
        'payload': {
          'order_id': 'order-1',
          'status': 'driver_arriving',
          'location': {'latitude': 56.84, 'longitude': 60.60},
        },
      });

      expect(sync.isSyncRequired, isTrue);
      expect(location.orderStatus, OrderStatus.driverArriving);
      expect(location.driverLocation?.lat, 56.84);
      expect(location.driverLocation?.lng, 60.60);
    });
  });
}

Map<String, dynamic> _orderJson(String status) {
  return {
    'order_id': 'order-1',
    'driver': {
      'id': 'driver-1',
      'name': 'Иван',
      'phone': '+79990000000',
      'photo_url': 'https://cdn/driver.png',
      'rating': 4.9,
      'ratings_count': 10,
    },
    'car': {
      'id': 'car-1',
      'brand': 'Lada',
      'model': 'Vesta',
      'color': 'White',
      'plate_number': 'А123АА96',
    },
    'pickup_point': {
      'address': 'Ленина 1',
      'location': {'latitude': 56.8389, 'longitude': 60.6057},
    },
    'destination_point': {
      'address': 'Мира 10',
      'location': {'latitude': 56.8489, 'longitude': 60.6157},
    },
    'status': status,
    'price': {'amount': 250, 'currency': 'RUB'},
    'eta_seconds': 420,
    'allowed_actions': ['cancel'],
    'timeline': [
      {
        'status': status,
        'occurred_at': '2026-06-30T10:00:00Z',
      },
    ],
    'version': 3,
  };
}
