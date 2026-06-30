import 'package:equatable/equatable.dart';

class Passenger extends Equatable {
  const Passenger({
    required this.id,
    required this.phone,
    required this.name,
    required this.email,
    required this.avatarUrl,
  });

  final String id;
  final String phone;
  final String name;
  final String email;
  final String avatarUrl;

  String get avatar => avatarUrl;

  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      id: json['id']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatarUrl: json['avatar_url']?.toString() ??
          json['avatar']?.toString() ??
          json['photo_url']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'name': name,
        'email': email,
        'avatar_url': avatarUrl,
      };

  Passenger copyWith({
    String? name,
    String? email,
    String? avatarUrl,
  }) {
    return Passenger(
      id: id,
      phone: phone,
      name: name ?? this.name,
      email: email ?? this.email,
      avatarUrl: avatarUrl ?? this.avatarUrl,
    );
  }

  @override
  List<Object?> get props => [id, phone, name, email, avatarUrl];
}

class GeoPoint extends Equatable {
  const GeoPoint({
    required this.lat,
    required this.lng,
    required this.address,
    this.cityId,
  });

  final double lat;
  final double lng;
  final String address;
  final String? cityId;

  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(
      lat: (json['latitude'] as num?)?.toDouble() ??
          (json['lat'] as num?)?.toDouble() ??
          0,
      lng: (json['longitude'] as num?)?.toDouble() ??
          (json['lng'] as num?)?.toDouble() ??
          0,
      address: json['address']?.toString() ?? '',
      cityId: json['city_id']?.toString(),
    );
  }

  factory GeoPoint.fromCoordinatesJson(
    Map<String, dynamic> json, {
    String address = '',
    String? cityId,
  }) {
    return GeoPoint(
      lat: (json['latitude'] as num?)?.toDouble() ?? 0,
      lng: (json['longitude'] as num?)?.toDouble() ?? 0,
      address: address,
      cityId: cityId,
    );
  }

  factory GeoPoint.fromAddressSearchJson(Map<String, dynamic> json) {
    final coordinates = json['coordinates'] as Map<String, dynamic>? ??
        <String, dynamic>{};
    return GeoPoint(
      lat: (coordinates['latitude'] as num?)?.toDouble() ?? 0,
      lng: (coordinates['longitude'] as num?)?.toDouble() ?? 0,
      address: json['address']?.toString() ?? json['name']?.toString() ?? '',
      cityId: json['city_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => toLocationJson();

  Map<String, dynamic> toLocationJson() => {
        'latitude': lat,
        'longitude': lng,
      };

  GeoPoint copyWith({
    double? lat,
    double? lng,
    String? address,
    String? cityId,
  }) {
    return GeoPoint(
      lat: lat ?? this.lat,
      lng: lng ?? this.lng,
      address: address ?? this.address,
      cityId: cityId ?? this.cityId,
    );
  }

  @override
  List<Object?> get props => [lat, lng, address, cityId];
}

class NearbyCar extends Equatable {
  const NearbyCar({
    required this.driverId,
    required this.carId,
    required this.lat,
    required this.lng,
    required this.distanceMeters,
    required this.etaMinutes,
    required this.carClass,
  });

  final String driverId;
  final String carId;
  final double lat;
  final double lng;
  final int distanceMeters;
  final int etaMinutes;
  final String carClass;

  factory NearbyCar.fromJson(Map<String, dynamic> json) {
    return NearbyCar(
      driverId: json['driver_id']?.toString() ?? json['driverId']?.toString() ?? '',
      carId: json['car_id']?.toString() ?? json['carId']?.toString() ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
      distanceMeters: (json['distance_meters'] as num?)?.toInt() ??
          (json['distanceMeters'] as num?)?.toInt() ??
          0,
      etaMinutes: (json['eta_minutes'] as num?)?.toInt() ??
          (json['etaMinutes'] as num?)?.toInt() ??
          0,
      carClass: json['car_class']?.toString() ??
          json['carClass']?.toString() ??
          '',
    );
  }

  @override
  List<Object?> get props => [
        driverId,
        carId,
        lat,
        lng,
        distanceMeters,
        etaMinutes,
        carClass,
      ];
}

class Tariff extends Equatable {
  const Tariff({
    required this.id,
    required this.name,
    required this.description,
  });

  final String id;
  final String name;
  final String description;

  factory Tariff.fromJson(Map<String, dynamic> json) {
    return Tariff(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      description: json['description']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name, description];
}

class RouteEstimate extends Equatable {
  const RouteEstimate({
    required this.tariffId,
    required this.tariffName,
    required this.distanceKm,
    required this.etaMinutes,
    required this.price,
    required this.currency,
    required this.priceType,
    required this.tariffs,
  });

  final String tariffId;
  final String tariffName;
  final double distanceKm;
  final int etaMinutes;
  final double price;
  final String currency;
  final String priceType;
  final List<Tariff> tariffs;

  factory RouteEstimate.fromJson(Map<String, dynamic> json) {
    final tariffId = json['tariff_id']?.toString() ?? '';
    final tariffName = json['tariff_name']?.toString() ?? 'Тариф';
    final price = (json['price'] as num?)?.toDouble() ?? 0;
    final currency = json['currency']?.toString() ?? 'RUB';

    return RouteEstimate(
      tariffId: tariffId,
      tariffName: tariffName,
      distanceKm: (json['distance_km'] as num?)?.toDouble() ?? 0,
      etaMinutes: (json['duration_min'] as num?)?.toInt() ?? 0,
      price: price,
      currency: currency,
      priceType: json['price_type']?.toString() ?? 'estimated',
      tariffs: tariffId.isEmpty
          ? const []
          : [
              Tariff(
                id: tariffId,
                name: tariffName,
                description: '${price.toStringAsFixed(0)} $currency',
              ),
            ],
    );
  }

  @override
  List<Object?> get props => [
        tariffId,
        tariffName,
        distanceKm,
        etaMinutes,
        price,
        currency,
        priceType,
        tariffs,
      ];
}

enum OrderStatus {
  searching,
  assigned,
  driverArriving,
  driverWaiting,
  inProgress,
  completed,
  cancelled,
  failed,
}

OrderStatus orderStatusFromString(String value) {
  switch (value) {
    case 'driver_assigned':
      return OrderStatus.assigned;
    case 'driver_arriving':
      return OrderStatus.driverArriving;
    case 'driver_waiting':
      return OrderStatus.driverWaiting;
    case 'trip_started':
      return OrderStatus.inProgress;
    case 'completed':
      return OrderStatus.completed;
    case 'cancelled':
      return OrderStatus.cancelled;
    case 'failed':
      return OrderStatus.failed;
    default:
      return OrderStatus.searching;
  }
}

String orderStatusToBackendValue(OrderStatus status) {
  switch (status) {
    case OrderStatus.assigned:
      return 'driver_assigned';
    case OrderStatus.driverArriving:
      return 'driver_arriving';
    case OrderStatus.driverWaiting:
      return 'driver_waiting';
    case OrderStatus.inProgress:
      return 'trip_started';
    case OrderStatus.completed:
      return 'completed';
    case OrderStatus.cancelled:
      return 'cancelled';
    case OrderStatus.failed:
      return 'failed';
    case OrderStatus.searching:
      return 'searching';
  }
}

String orderStatusLabel(OrderStatus status) {
  switch (status) {
    case OrderStatus.searching:
      return 'Ищем водителя';
    case OrderStatus.assigned:
      return 'Водитель назначен';
    case OrderStatus.driverArriving:
      return 'Водитель подъезжает';
    case OrderStatus.driverWaiting:
      return 'Водитель ожидает';
    case OrderStatus.inProgress:
      return 'Поездка началась';
    case OrderStatus.completed:
      return 'Поездка завершена';
    case OrderStatus.cancelled:
      return 'Заказ отменен';
    case OrderStatus.failed:
      return 'Заказ завершился ошибкой';
  }
}

class MoneyResponse extends Equatable {
  const MoneyResponse({
    required this.amount,
    required this.currency,
  });

  final int amount;
  final String currency;

  factory MoneyResponse.fromJson(Map<String, dynamic> json) {
    return MoneyResponse(
      amount: (json['amount'] as num?)?.toInt() ?? 0,
      currency: json['currency']?.toString() ?? 'RUB',
    );
  }

  @override
  List<Object?> get props => [amount, currency];
}

class PointDTO extends Equatable {
  const PointDTO({
    required this.address,
    required this.location,
  });

  final String address;
  final GeoPoint location;

  factory PointDTO.fromJson(Map<String, dynamic> json) {
    return PointDTO(
      address: json['address']?.toString() ?? '',
      location: GeoPoint.fromCoordinatesJson(
        json['location'] as Map<String, dynamic>? ?? <String, dynamic>{},
        address: json['address']?.toString() ?? '',
      ),
    );
  }

  GeoPoint toGeoPoint() => location.copyWith(address: address);

  @override
  List<Object?> get props => [address, location];
}

class DriverDTO extends Equatable {
  const DriverDTO({
    required this.id,
    required this.name,
    required this.phone,
    required this.photoUrl,
    required this.rating,
    required this.ratingsCount,
  });

  final String id;
  final String name;
  final String phone;
  final String photoUrl;
  final double rating;
  final int ratingsCount;

  String get avatar => photoUrl;

  factory DriverDTO.fromJson(Map<String, dynamic> json) {
    return DriverDTO(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      photoUrl: json['photo_url']?.toString() ??
          json['avatar']?.toString() ??
          '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      ratingsCount: (json['ratings_count'] as num?)?.toInt() ?? 0,
    );
  }

  @override
  List<Object?> get props => [id, name, phone, photoUrl, rating, ratingsCount];
}

class CarDTO extends Equatable {
  const CarDTO({
    required this.id,
    required this.brand,
    required this.model,
    required this.color,
    required this.plateNumber,
    this.className = '',
  });

  final String id;
  final String brand;
  final String model;
  final String color;
  final String plateNumber;
  final String className;

  factory CarDTO.fromJson(Map<String, dynamic> json) {
    return CarDTO(
      id: json['id']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      plateNumber: json['plate_number']?.toString() ??
          json['plateNumber']?.toString() ??
          '',
      className: json['class_name']?.toString() ??
          json['className']?.toString() ??
          '',
    );
  }

  @override
  List<Object?> get props => [id, brand, model, color, plateNumber, className];
}

class OrderTimelineItem extends Equatable {
  const OrderTimelineItem({
    required this.status,
    required this.occurredAt,
  });

  final OrderStatus status;
  final DateTime occurredAt;

  factory OrderTimelineItem.fromJson(Map<String, dynamic> json) {
    return OrderTimelineItem(
      status: orderStatusFromString(json['status']?.toString() ?? ''),
      occurredAt: DateTime.tryParse(json['occurred_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [status, occurredAt];
}

class PassengerOrderResponse extends Equatable {
  const PassengerOrderResponse({
    required this.orderId,
    required this.pickupPoint,
    required this.destinationPoint,
    required this.status,
    required this.allowedActions,
    required this.timeline,
    required this.version,
    this.driver,
    this.car,
    this.price,
    this.etaSeconds,
  });

  final String orderId;
  final DriverDTO? driver;
  final CarDTO? car;
  final PointDTO pickupPoint;
  final PointDTO destinationPoint;
  final OrderStatus status;
  final MoneyResponse? price;
  final int? etaSeconds;
  final List<String> allowedActions;
  final List<OrderTimelineItem> timeline;
  final int version;

  String get id => orderId;
  GeoPoint get pickup => pickupPoint.toGeoPoint();
  GeoPoint get destination => destinationPoint.toGeoPoint();
  double get priceValue => (price?.amount ?? 0).toDouble();
  int get etaMinutes => etaSeconds == null ? 0 : (etaSeconds! / 60).ceil();
  int get distanceMeters => 0;
  DateTime get createdAt =>
      timeline.isNotEmpty ? timeline.first.occurredAt : DateTime.now();
  String get tariffId => '';
  String get paymentMethod => 'cash';

  factory PassengerOrderResponse.fromJson(Map<String, dynamic> json) {
    final timelineJson = (json['timeline'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(OrderTimelineItem.fromJson)
        .toList();

    return PassengerOrderResponse(
      orderId: json['order_id']?.toString() ?? json['id']?.toString() ?? '',
      driver: json['driver'] is Map<String, dynamic>
          ? DriverDTO.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
      car: json['car'] is Map<String, dynamic>
          ? CarDTO.fromJson(json['car'] as Map<String, dynamic>)
          : null,
      pickupPoint: PointDTO.fromJson(
        json['pickup_point'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      destinationPoint: PointDTO.fromJson(
        json['destination_point'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      status: orderStatusFromString(json['status']?.toString() ?? ''),
      price: json['price'] is Map<String, dynamic>
          ? MoneyResponse.fromJson(json['price'] as Map<String, dynamic>)
          : null,
      etaSeconds: (json['eta_seconds'] as num?)?.toInt(),
      allowedActions: (json['allowed_actions'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      timeline: timelineJson,
      version: (json['version'] as num?)?.toInt() ?? 0,
    );
  }

  PassengerOrderResponse copyWith({
    DriverDTO? driver,
    CarDTO? car,
    PointDTO? pickupPoint,
    PointDTO? destinationPoint,
    OrderStatus? status,
    MoneyResponse? price,
    int? etaSeconds,
    List<String>? allowedActions,
    List<OrderTimelineItem>? timeline,
    int? version,
  }) {
    return PassengerOrderResponse(
      orderId: orderId,
      driver: driver ?? this.driver,
      car: car ?? this.car,
      pickupPoint: pickupPoint ?? this.pickupPoint,
      destinationPoint: destinationPoint ?? this.destinationPoint,
      status: status ?? this.status,
      price: price ?? this.price,
      etaSeconds: etaSeconds ?? this.etaSeconds,
      allowedActions: allowedActions ?? this.allowedActions,
      timeline: timeline ?? this.timeline,
      version: version ?? this.version,
    );
  }

  @override
  List<Object?> get props => [
        orderId,
        driver,
        car,
        pickupPoint,
        destinationPoint,
        status,
        price,
        etaSeconds,
        allowedActions,
        timeline,
        version,
      ];
}

typedef Order = PassengerOrderResponse;
typedef Driver = DriverDTO;
typedef Car = CarDTO;

class OrderHistoryResponse extends Equatable {
  const OrderHistoryResponse({required this.orders});

  final List<PassengerOrderResponse> orders;

  factory OrderHistoryResponse.fromJson(Map<String, dynamic> json) {
    final orders = (json['orders'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(PassengerOrderResponse.fromJson)
        .toList();
    return OrderHistoryResponse(orders: orders);
  }

  @override
  List<Object?> get props => [orders];
}

class OrderEstimateRequest extends Equatable {
  const OrderEstimateRequest({
    required this.cityId,
    required this.tariffId,
    required this.pickupLocation,
    required this.destinationLocation,
  });

  final String cityId;
  final String tariffId;
  final GeoPoint pickupLocation;
  final GeoPoint destinationLocation;

  Map<String, dynamic> toJson() => {
        'city_id': cityId,
        'tariff_id': tariffId,
        'pickup_location': pickupLocation.toLocationJson(),
        'destination_location': destinationLocation.toLocationJson(),
      };

  @override
  List<Object?> get props => [
        cityId,
        tariffId,
        pickupLocation,
        destinationLocation,
      ];
}

class CreateOrderRequest extends Equatable {
  const CreateOrderRequest({
    required this.cityId,
    required this.pickupLocation,
    required this.pickupAddress,
    required this.destinationLocation,
    required this.destinationAddress,
    required this.tariffId,
    required this.paymentType,
    required this.comment,
    required this.passengerPhone,
  });

  final String cityId;
  final GeoPoint pickupLocation;
  final String pickupAddress;
  final GeoPoint destinationLocation;
  final String destinationAddress;
  final String tariffId;
  final String paymentType;
  final String comment;
  final String passengerPhone;

  Map<String, dynamic> toJson() => {
        'city_id': cityId,
        'pickup_location': pickupLocation.toLocationJson(),
        'pickup_address': pickupAddress,
        'destination_location': destinationLocation.toLocationJson(),
        'destination_address': destinationAddress,
        'tariff_id': tariffId,
        'payment_type': paymentType,
        'comment': comment,
        'passenger_phone': passengerPhone,
      };

  @override
  List<Object?> get props => [
        cityId,
        pickupLocation,
        pickupAddress,
        destinationLocation,
        destinationAddress,
        tariffId,
        paymentType,
        comment,
        passengerPhone,
      ];
}

class OrderEvent extends Equatable {
  const OrderEvent({
    required this.event,
    required this.requestId,
    required this.occurredAt,
    required this.payload,
    this.order,
    this.orderId,
    this.orderStatus,
    this.driverLocation,
  });

  final String event;
  final String requestId;
  final DateTime occurredAt;
  final Map<String, dynamic> payload;
  final Order? order;
  final String? orderId;
  final OrderStatus? orderStatus;
  final GeoPoint? driverLocation;

  bool get isSyncRequired => event == 'sync.required';
  bool get affectsOrderState => event.startsWith('order.') || isSyncRequired;

  factory OrderEvent.fromJson(Map<String, dynamic> json) {
    final payload = json['payload'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final location = payload['location'] as Map<String, dynamic>?;

    return OrderEvent(
      event: json['event']?.toString() ?? '',
      requestId: json['request_id']?.toString() ?? '',
      occurredAt: DateTime.tryParse(json['occurred_at']?.toString() ?? '') ??
          DateTime.now(),
      payload: payload,
      orderId: payload['order_id']?.toString(),
      orderStatus: payload['status'] == null
          ? null
          : orderStatusFromString(payload['status']!.toString()),
      driverLocation: location == null
          ? null
          : GeoPoint.fromCoordinatesJson(location),
    );
  }

  OrderEvent copyWith({
    Order? order,
    String? orderId,
    OrderStatus? orderStatus,
    GeoPoint? driverLocation,
  }) {
    return OrderEvent(
      event: event,
      requestId: requestId,
      occurredAt: occurredAt,
      payload: payload,
      order: order ?? this.order,
      orderId: orderId ?? this.orderId,
      orderStatus: orderStatus ?? this.orderStatus,
      driverLocation: driverLocation ?? this.driverLocation,
    );
  }

  @override
  List<Object?> get props => [
        event,
        requestId,
        occurredAt,
        payload,
        order,
        orderId,
        orderStatus,
        driverLocation,
      ];
}
