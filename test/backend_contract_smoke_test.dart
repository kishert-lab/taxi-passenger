import 'package:taxi_passenger/core/auth/auth_tokens.dart';
import 'package:taxi_passenger/core/constants/api_endpoints.dart';
import 'package:taxi_passenger/domain/models/models.dart';
import 'package:test/test.dart';

void main() {
  group('Auth contract', () {
    test('passenger auth/profile/push endpoints match mobile contract', () {
      expect(ApiEndpoints.requestCode, '/api/v1/passenger/auth/request-code');
      expect(ApiEndpoints.refresh, '/api/v1/passenger/auth/refresh');
      expect(ApiEndpoints.logout, '/api/v1/passenger/auth/logout');
      expect(ApiEndpoints.me, '/api/v1/passenger/me');
      expect(ApiEndpoints.pushToken, '/api/v1/passenger/push/token');
    });

    test('confirm-code envelope parses nested tokens and passenger', () {
      final session = PassengerAuthSession.fromResponse({
        'data': {
          'passenger': {
            'id': 'passenger-1',
            'phone': '+79997778866',
            'name': 'Irina',
            'avatar_url': 'https://cdn/avatar.png',
          },
          'tokens': {
            'access_token': 'access-1',
            'refresh_token': 'refresh-1',
            'token_type': 'Bearer',
            'expires_in': 900,
          },
        },
      });

      expect(session.tokens.accessToken, 'access-1');
      expect(session.tokens.refreshToken, 'refresh-1');
      expect(session.passenger.phone, '+79997778866');
      expect(session.passenger.avatarUrl, 'https://cdn/avatar.png');
    });

    test('refresh envelope parses nested tokens', () {
      final tokens = AuthTokens.fromResponse({
        'data': {
          'tokens': {
            'access_token': 'access-2',
            'refresh_token': 'refresh-2',
            'expires_in': 900,
          },
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

    test('address search point parses coordinates object', () {
      final point = GeoPoint.fromAddressSearchJson({
        'name': 'Lenina 50',
        'address': 'Ekaterinburg, Lenina 50',
        'coordinates': {'latitude': 56.8389, 'longitude': 60.6057},
      });

      expect(point.address, 'Ekaterinburg, Lenina 50');
      expect(point.toJson(), {'latitude': 56.8389, 'longitude': 60.6057});
    });
  });

  group('Catalog and order DTO contract', () {
    test('car class parses backend dto', () {
      final carClass = CarClass.fromJson({
        'id': 'class-1',
        'code': 'economy',
        'name': 'Economy',
        'description': 'Affordable city rides',
        'base_price': '120.00',
        'price_per_km': '18.00',
        'price_per_minute': '6.00',
        'minimum_price': '180.00',
        'sort_order': 10,
      });

      expect(carClass.id, 'class-1');
      expect(carClass.code, 'economy');
      expect(carClass.name, 'Economy');
      expect(carClass.description, 'Affordable city rides');
      expect(carClass.minimumPrice, '180.00');
      expect(carClass.sortOrder, 10);
    });

    test('estimate request serializes backend payload', () {
      const request = OrderEstimateRequest(
        carClassId: 'class-1',
        pickupLocation: GeoPoint(
          lat: 56.8389,
          lng: 60.6057,
          address: 'Lenina 1',
          cityId: 'city-1',
        ),
        destinationLocation: GeoPoint(
          lat: 56.8489,
          lng: 60.6157,
          address: 'Mira 10',
          cityId: 'city-1',
        ),
      );

      expect(request.toJson(), {
        'pickup': {
          'address': 'Lenina 1',
          'latitude': 56.8389,
          'longitude': 60.6057,
        },
        'dropoff': {
          'address': 'Mira 10',
          'latitude': 56.8489,
          'longitude': 60.6157,
        },
        'car_class_id': 'class-1',
      });
    });

    test('create order request serializes backend payload', () {
      const request = CreateOrderRequest(
        pickupLocation: GeoPoint(
          lat: 56.8389,
          lng: 60.6057,
          address: 'Lenina 1',
          cityId: 'city-1',
        ),
        pickupAddress: 'Lenina 1',
        pickupEntrance: '2',
        pickupComment: 'yard entrance',
        destinationLocation: GeoPoint(
          lat: 56.8489,
          lng: 60.6157,
          address: 'Mira 10',
          cityId: 'city-1',
        ),
        destinationAddress: 'Mira 10',
        carClassId: 'class-1',
        paymentType: 'cash',
        comment: 'Luggage',
        passengerLocationSharingEnabled: true,
      );

      expect(request.toJson(), {
        'pickup': {
          'address': 'Lenina 1',
          'latitude': 56.8389,
          'longitude': 60.6057,
        },
        'dropoff': {
          'address': 'Mira 10',
          'latitude': 56.8489,
          'longitude': 60.6157,
        },
        'car_class_id': 'class-1',
        'payment_method': 'cash',
        'comment': 'Luggage',
      });
    });

    test('estimate response parses backend dto', () {
      final estimate = RouteEstimate.fromJson({
        'distance_meters': 4200,
        'duration_seconds': 660,
        'estimated_price': '250.00',
        'currency': 'RUB',
        'car_class_id': 'class-1',
        'car_class': {'id': 'class-1', 'name': 'Economy'},
      });

      expect(estimate.carClassId, 'class-1');
      expect(estimate.etaMinutes, 11);
      expect(estimate.price, 250);
      expect(estimate.carClassName, 'Economy');
    });

    test('current order and history parse passenger order dto', () {
      final current = PassengerOrderResponse.fromJson({
        'order': _orderJson('arrived'),
      });
      final history = OrderHistoryResponse.fromJson({
        'orders': [_orderJson('completed')],
      });

      expect(current.id, 'order-1');
      expect(current.status, OrderStatus.driverArriving);
      expect(current.pickup.address, 'Lenina 1');
      expect(current.car?.plateNumber, 'A123AA96');
      expect(current.paymentType, 'cash');
      expect(current.carClassId, 'class-1');
      expect(history.orders.single.status, OrderStatus.completed);
    });
  });

  group('Chat and WebSocket contract', () {
    test('chat message parses new passenger response', () {
      final message = ChatMessage.fromJson({
        'id': 'msg-1',
        'thread_id': 'thread-1',
        'order_id': 'order-1',
        'chat_type': 'driver_passenger',
        'sender_id': 'passenger-1',
        'sender_user_id': null,
        'sender_passenger_id': 'passenger-1',
        'sender_role': 'passenger',
        'body': 'I am at the entrance',
        'created_at': '2026-06-30T10:00:00Z',
      });

      expect(message.id, 'msg-1');
      expect(message.senderId, 'passenger-1');
      expect(message.senderPassengerId, 'passenger-1');
      expect(message.senderUserId, isNull);
      expect(message.isPassengerMessage, isTrue);
    });

    test('ws order events parse current backend shape', () {
      final ready = OrderEvent.fromJson({
        'type': 'session.ready',
        'payload': {
          'passenger_id': 'passenger-1',
          'connected_at': '2026-06-30T10:00:00Z',
        },
      });
      final location = OrderEvent.fromJson({
        'type': 'order.driver_location',
        'payload': {
          'order_id': 'order-1',
          'status': 'arrived',
          'location': {'latitude': 56.84, 'longitude': 60.60},
          'recorded_at': '2026-06-30T10:00:01Z',
        },
      });

      expect(ready.event, 'session.ready');
      expect(location.orderStatus, OrderStatus.driverArriving);
      expect(location.driverLocation?.lat, 56.84);
      expect(location.driverLocation?.lng, 60.60);
    });
  });
}

Map<String, dynamic> _orderJson(String status) {
  return {
    'id': 'order-1',
    'driver': {'id': 'driver-1', 'first_name': 'Ivan', 'phone': '+79990000000'},
    'car': {
      'id': 'car-1',
      'brand': 'Lada',
      'model': 'Vesta',
      'color': 'White',
      'plate_number': 'A123AA96',
    },
    'pickup': {
      'address': 'Lenina 1',
      'latitude': 56.8389,
      'longitude': 60.6057,
    },
    'dropoff': {
      'address': 'Mira 10',
      'latitude': 56.8489,
      'longitude': 60.6157,
    },
    'status': status,
    'estimated_price': '250.00',
    'currency': 'RUB',
    'eta_seconds': 420,
    'payment_method': 'cash',
    'comment': 'Luggage',
    'car_class_id': 'class-1',
    'created_at': '2026-06-30T10:00:00Z',
  };
}
