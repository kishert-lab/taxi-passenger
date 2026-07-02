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
      avatarUrl:
          json['avatar_url']?.toString() ??
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

  Passenger copyWith({String? name, String? email, String? avatarUrl}) {
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
      lat:
          (json['latitude'] as num?)?.toDouble() ??
          (json['lat'] as num?)?.toDouble() ??
          0,
      lng:
          (json['longitude'] as num?)?.toDouble() ??
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
      lat:
          (json['latitude'] as num?)?.toDouble() ??
          (json['lat'] as num?)?.toDouble() ??
          0,
      lng:
          (json['longitude'] as num?)?.toDouble() ??
          (json['lng'] as num?)?.toDouble() ??
          0,
      address: address,
      cityId: cityId,
    );
  }

  factory GeoPoint.fromAddressSearchJson(Map<String, dynamic> json) {
    final coordinates =
        json['coordinates'] as Map<String, dynamic>? ?? <String, dynamic>{};
    return GeoPoint(
      lat: (coordinates['latitude'] as num?)?.toDouble() ?? 0,
      lng: (coordinates['longitude'] as num?)?.toDouble() ?? 0,
      address: json['address']?.toString() ?? json['name']?.toString() ?? '',
      cityId: json['city_id']?.toString(),
    );
  }

  Map<String, dynamic> toJson() => toLocationJson();

  Map<String, dynamic> toLocationJson() => {'latitude': lat, 'longitude': lng};

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
      driverId:
          json['driver_id']?.toString() ?? json['driverId']?.toString() ?? '',
      carId: json['car_id']?.toString() ?? json['carId']?.toString() ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
      distanceMeters:
          (json['distance_meters'] as num?)?.toInt() ??
          (json['distanceMeters'] as num?)?.toInt() ??
          0,
      etaMinutes:
          (json['eta_minutes'] as num?)?.toInt() ??
          (json['etaMinutes'] as num?)?.toInt() ??
          0,
      carClass:
          json['car_class']?.toString() ?? json['carClass']?.toString() ?? '',
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

class CarClass extends Equatable {
  const CarClass({
    required this.id,
    required this.code,
    required this.name,
    required this.description,
    required this.basePrice,
    required this.pricePerKm,
    required this.pricePerMinute,
    required this.minimumPrice,
    required this.sortOrder,
  });

  final String id;
  final String code;
  final String name;
  final String description;
  final String basePrice;
  final String pricePerKm;
  final String pricePerMinute;
  final String minimumPrice;
  final int sortOrder;

  factory CarClass.fromJson(Map<String, dynamic> json) {
    final basePrice = json['base_price']?.toString() ?? '';
    final pricePerKm = json['price_per_km']?.toString() ?? '';
    final pricePerMinute = json['price_per_minute']?.toString() ?? '';
    final minimumPrice = json['minimum_price']?.toString() ?? '';
    final description =
        json['description']?.toString() ??
        json['subtitle']?.toString() ??
        _buildPricingDescription(
          basePrice: basePrice,
          minimumPrice: minimumPrice,
        );

    return CarClass(
      id: json['id']?.toString() ?? '',
      code: json['code']?.toString() ?? '',
      name: json['name']?.toString() ?? json['title']?.toString() ?? '',
      description: description,
      basePrice: basePrice,
      pricePerKm: pricePerKm,
      pricePerMinute: pricePerMinute,
      minimumPrice: minimumPrice,
      sortOrder: (json['sort_order'] as num?)?.toInt() ?? 0,
    );
  }

  static String _buildPricingDescription({
    required String basePrice,
    required String minimumPrice,
  }) {
    if (minimumPrice.isNotEmpty) {
      return 'от $minimumPrice';
    }

    if (basePrice.isNotEmpty) {
      return basePrice;
    }

    return '';
  }

  @override
  List<Object?> get props => [
    id,
    code,
    name,
    description,
    basePrice,
    pricePerKm,
    pricePerMinute,
    minimumPrice,
    sortOrder,
  ];
}

typedef Tariff = CarClass;

class RouteEstimate extends Equatable {
  const RouteEstimate({
    required this.carClassId,
    required this.carClassName,
    required this.distanceKm,
    required this.etaMinutes,
    required this.price,
    required this.currency,
    required this.priceType,
  });

  final String carClassId;
  final String carClassName;
  final double distanceKm;
  final int etaMinutes;
  final double price;
  final String currency;
  final String priceType;

  String get tariffId => carClassId;
  String get tariffName => carClassName;
  List<CarClass> get tariffs => const [];

  factory RouteEstimate.fromJson(Map<String, dynamic> json) {
    final carClass =
        json['car_class'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final amount = _parseDoubleValue(json['estimated_price'] ?? json['price']);
    final distanceMeters = (json['distance_meters'] as num?)?.toDouble();

    return RouteEstimate(
      carClassId:
          json['car_class_id']?.toString() ??
          carClass['id']?.toString() ??
          json['tariff_id']?.toString() ??
          '',
      carClassName:
          json['car_class_name']?.toString() ??
          carClass['name']?.toString() ??
          json['class_name']?.toString() ??
          json['tariff_name']?.toString() ??
          '',
      distanceKm: distanceMeters != null
          ? distanceMeters / 1000
          : (json['distance_km'] as num?)?.toDouble() ?? 0,
      etaMinutes: _resolveEtaMinutes(json),
      price: amount,
      currency: json['currency']?.toString() ?? 'RUB',
      priceType: json['price_type']?.toString() ?? 'estimated',
    );
  }

  static int _resolveEtaMinutes(Map<String, dynamic> json) {
    final durationSeconds = (json['duration_seconds'] as num?)?.toInt();
    if (durationSeconds != null) {
      return (durationSeconds / 60).ceil();
    }
    return (json['duration_min'] as num?)?.toInt() ??
        (json['eta_minutes'] as num?)?.toInt() ??
        0;
  }

  static double _parseDoubleValue(Object? value) {
    if (value is num) {
      return value.toDouble();
    }
    return double.tryParse(value?.toString() ?? '') ?? 0;
  }

  @override
  List<Object?> get props => [
    carClassId,
    carClassName,
    distanceKm,
    etaMinutes,
    price,
    currency,
    priceType,
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
    case 'accepted':
    case 'driver_assigned':
      return OrderStatus.assigned;
    case 'arrived':
    case 'driver_arriving':
      return OrderStatus.driverArriving;
    case 'driver_waiting':
      return OrderStatus.driverWaiting;
    case 'started':
    case 'trip_started':
    case 'in_progress':
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
      return 'Поиск водителя';
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
  const MoneyResponse({required this.amount, required this.currency});

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
  const PointDTO({required this.address, required this.location});

  final String address;
  final GeoPoint location;

  factory PointDTO.fromJson(Map<String, dynamic> json) {
    final locationJson =
        json['location'] as Map<String, dynamic>? ??
        json['coordinates'] as Map<String, dynamic>? ??
        ((json['latitude'] != null || json['longitude'] != null)
            ? <String, dynamic>{
                'latitude': json['latitude'],
                'longitude': json['longitude'],
              }
            : null) ??
        <String, dynamic>{};

    return PointDTO(
      address: json['address']?.toString() ?? '',
      location: GeoPoint.fromCoordinatesJson(
        locationJson,
        address: json['address']?.toString() ?? '',
        cityId: json['city_id']?.toString(),
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
      photoUrl:
          json['photo_url']?.toString() ?? json['avatar']?.toString() ?? '',
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
      plateNumber:
          json['plate_number']?.toString() ??
          json['plateNumber']?.toString() ??
          '',
      className:
          json['class_name']?.toString() ??
          json['car_class_name']?.toString() ??
          json['className']?.toString() ??
          '',
    );
  }

  @override
  List<Object?> get props => [id, brand, model, color, plateNumber, className];
}

class OrderTimelineItem extends Equatable {
  const OrderTimelineItem({required this.status, required this.occurredAt});

  final OrderStatus status;
  final DateTime occurredAt;

  factory OrderTimelineItem.fromJson(Map<String, dynamic> json) {
    return OrderTimelineItem(
      status: orderStatusFromString(json['status']?.toString() ?? ''),
      occurredAt:
          DateTime.tryParse(json['occurred_at']?.toString() ?? '') ??
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
    required this.paymentType,
    required this.comment,
    required this.pickupEntrance,
    required this.pickupComment,
    required this.passengerLocationSharingEnabled,
    required this.carClassId,
    required this.createdAtValue,
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
  final String paymentType;
  final String comment;
  final String pickupEntrance;
  final String pickupComment;
  final bool passengerLocationSharingEnabled;
  final String carClassId;
  final DateTime createdAtValue;

  String get id => orderId;
  GeoPoint get pickup => pickupPoint.toGeoPoint();
  GeoPoint get destination => destinationPoint.toGeoPoint();
  double get priceValue => (price?.amount ?? 0).toDouble();
  int get etaMinutes => etaSeconds == null ? 0 : (etaSeconds! / 60).ceil();
  int get distanceMeters => 0;
  DateTime get createdAt =>
      timeline.isNotEmpty ? timeline.first.occurredAt : createdAtValue;
  String get tariffId => carClassId;
  String get paymentMethod => paymentType;

  factory PassengerOrderResponse.fromJson(Map<String, dynamic> json) {
    final source = json['order'] as Map<String, dynamic>? ?? json;
    final timelineJson = (source['timeline'] as List<dynamic>? ?? [])
        .whereType<Map<String, dynamic>>()
        .map(OrderTimelineItem.fromJson)
        .toList();

    final pickupPoint = _parsePoint(
      nested:
          source['pickup_point'] as Map<String, dynamic>? ??
          source['pickup'] as Map<String, dynamic>?,
      location: source['pickup_location'] as Map<String, dynamic>?,
      address: source['pickup_address']?.toString(),
      cityId: source['city_id']?.toString(),
    );
    final destinationPoint = _parsePoint(
      nested:
          source['destination_point'] as Map<String, dynamic>? ??
          source['dropoff'] as Map<String, dynamic>? ??
          source['destination'] as Map<String, dynamic>?,
      location: source['destination_location'] as Map<String, dynamic>?,
      address: source['destination_address']?.toString(),
      cityId: source['city_id']?.toString(),
    );

    final priceJson =
        source['price'] ?? source['estimated_price'] ?? source['final_price'];
    final etaSeconds =
        (source['eta_seconds'] as num?)?.toInt() ??
        ((source['eta_minutes'] as num?)?.toInt() != null
            ? (source['eta_minutes'] as num).toInt() * 60
            : null);

    return PassengerOrderResponse(
      orderId: source['order_id']?.toString() ?? source['id']?.toString() ?? '',
      driver: source['driver'] is Map<String, dynamic>
          ? DriverDTO.fromJson(source['driver'] as Map<String, dynamic>)
          : null,
      car: source['car'] is Map<String, dynamic>
          ? CarDTO.fromJson(source['car'] as Map<String, dynamic>)
          : null,
      pickupPoint: pickupPoint,
      destinationPoint: destinationPoint,
      status: orderStatusFromString(source['status']?.toString() ?? ''),
      price: priceJson is Map<String, dynamic>
          ? MoneyResponse.fromJson(priceJson)
          : priceJson != null
          ? MoneyResponse(
              amount: _parseMoneyAmount(priceJson),
              currency: source['currency']?.toString() ?? 'RUB',
            )
          : null,
      etaSeconds: etaSeconds,
      allowedActions: (source['allowed_actions'] as List<dynamic>? ?? [])
          .map((item) => item.toString())
          .toList(),
      timeline: timelineJson,
      version: (source['version'] as num?)?.toInt() ?? 0,
      paymentType:
          source['payment_method']?.toString() ??
          source['payment_type']?.toString() ??
          'cash',
      comment: source['comment']?.toString() ?? '',
      pickupEntrance: source['pickup_entrance']?.toString() ?? '',
      pickupComment: source['pickup_comment']?.toString() ?? '',
      passengerLocationSharingEnabled:
          source['passenger_location_sharing_enabled'] == true,
      carClassId:
          source['car_class_id']?.toString() ??
          source['tariff_id']?.toString() ??
          '',
      createdAtValue:
          DateTime.tryParse(source['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  static int _parseMoneyAmount(Object value) {
    if (value is num) {
      return value.round();
    }

    return (double.tryParse(value.toString()) ?? 0).round();
  }

  static PointDTO _parsePoint({
    required Map<String, dynamic>? nested,
    required Map<String, dynamic>? location,
    required String? address,
    required String? cityId,
  }) {
    if (nested != null) {
      return PointDTO.fromJson(nested);
    }

    return PointDTO(
      address: address ?? '',
      location: GeoPoint.fromCoordinatesJson(
        location ?? <String, dynamic>{},
        address: address ?? '',
        cityId: cityId,
      ),
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
    String? paymentType,
    String? comment,
    String? pickupEntrance,
    String? pickupComment,
    bool? passengerLocationSharingEnabled,
    String? carClassId,
    DateTime? createdAtValue,
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
      paymentType: paymentType ?? this.paymentType,
      comment: comment ?? this.comment,
      pickupEntrance: pickupEntrance ?? this.pickupEntrance,
      pickupComment: pickupComment ?? this.pickupComment,
      passengerLocationSharingEnabled:
          passengerLocationSharingEnabled ??
          this.passengerLocationSharingEnabled,
      carClassId: carClassId ?? this.carClassId,
      createdAtValue: createdAtValue ?? this.createdAtValue,
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
    paymentType,
    comment,
    pickupEntrance,
    pickupComment,
    passengerLocationSharingEnabled,
    carClassId,
    createdAtValue,
  ];
}

typedef Order = PassengerOrderResponse;
typedef Driver = DriverDTO;
typedef Car = CarDTO;

class OrderHistoryResponse extends Equatable {
  const OrderHistoryResponse({required this.orders});

  final List<PassengerOrderResponse> orders;

  factory OrderHistoryResponse.fromJson(dynamic json) {
    if (json is List<dynamic>) {
      return OrderHistoryResponse(
        orders: json
            .whereType<Map<String, dynamic>>()
            .map(PassengerOrderResponse.fromJson)
            .toList(),
      );
    }

    final map = json as Map<String, dynamic>? ?? <String, dynamic>{};
    final ordersJson =
        (map['orders'] as List<dynamic>? ??
                (map['history'] as List<dynamic>?) ??
                map['items'] as List<dynamic>? ??
                const [])
            .whereType<Map<String, dynamic>>()
            .toList();
    return OrderHistoryResponse(
      orders: ordersJson.map(PassengerOrderResponse.fromJson).toList(),
    );
  }

  @override
  List<Object?> get props => [orders];
}

class OrderEstimateRequest extends Equatable {
  const OrderEstimateRequest({
    required this.pickupLocation,
    required this.destinationLocation,
    required this.carClassId,
  });

  final GeoPoint pickupLocation;
  final GeoPoint destinationLocation;
  final String carClassId;

  Map<String, dynamic> toJson() => {
    'pickup': {
      'address': pickupLocation.address,
      'latitude': pickupLocation.lat,
      'longitude': pickupLocation.lng,
    },
    'dropoff': {
      'address': destinationLocation.address,
      'latitude': destinationLocation.lat,
      'longitude': destinationLocation.lng,
    },
    'car_class_id': carClassId,
  };

  @override
  List<Object?> get props => [pickupLocation, destinationLocation, carClassId];
}

class CreateOrderRequest extends Equatable {
  const CreateOrderRequest({
    required this.pickupLocation,
    required this.pickupAddress,
    required this.destinationLocation,
    required this.destinationAddress,
    required this.carClassId,
    required this.paymentType,
    required this.comment,
    required this.pickupEntrance,
    required this.pickupComment,
    required this.passengerLocationSharingEnabled,
  });

  final GeoPoint pickupLocation;
  final String pickupAddress;
  final GeoPoint destinationLocation;
  final String destinationAddress;
  final String carClassId;
  final String paymentType;
  final String comment;
  final String pickupEntrance;
  final String pickupComment;
  final bool passengerLocationSharingEnabled;

  Map<String, dynamic> toJson() => {
    'pickup': {
      'address': pickupAddress,
      'latitude': pickupLocation.lat,
      'longitude': pickupLocation.lng,
    },
    'dropoff': {
      'address': destinationAddress,
      'latitude': destinationLocation.lat,
      'longitude': destinationLocation.lng,
    },
    'car_class_id': carClassId,
    'payment_method': paymentType,
    if (comment.isNotEmpty) 'comment': comment,
  };

  @override
  List<Object?> get props => [
    pickupLocation,
    pickupAddress,
    pickupEntrance,
    pickupComment,
    destinationLocation,
    destinationAddress,
    carClassId,
    paymentType,
    comment,
    passengerLocationSharingEnabled,
  ];
}

class ChatMessage extends Equatable {
  const ChatMessage({
    required this.id,
    required this.threadId,
    required this.orderId,
    required this.chatType,
    required this.senderId,
    required this.senderUserId,
    required this.senderPassengerId,
    required this.senderRole,
    required this.body,
    required this.createdAt,
  });

  final String id;
  final String threadId;
  final String? orderId;
  final String chatType;
  final String senderId;
  final String? senderUserId;
  final String? senderPassengerId;
  final String senderRole;
  final String body;
  final DateTime createdAt;

  bool get isPassengerMessage => senderRole == 'passenger';

  factory ChatMessage.fromJson(Map<String, dynamic> json) {
    final orderIdValue = json['order_id'];
    final senderUserIdValue = json['sender_user_id'];
    final senderPassengerIdValue = json['sender_passenger_id'];

    return ChatMessage(
      id: json['id']?.toString() ?? '',
      threadId: json['thread_id']?.toString() ?? '',
      orderId: orderIdValue == null || orderIdValue.toString().isEmpty
          ? null
          : orderIdValue.toString(),
      chatType: json['chat_type']?.toString() ?? '',
      senderId: json['sender_id']?.toString() ?? '',
      senderUserId:
          senderUserIdValue == null ||
              senderUserIdValue.toString().isEmpty ||
              senderUserIdValue.toString() == 'null'
          ? null
          : senderUserIdValue.toString(),
      senderPassengerId:
          senderPassengerIdValue == null ||
              senderPassengerIdValue.toString().isEmpty ||
              senderPassengerIdValue.toString() == 'null'
          ? null
          : senderPassengerIdValue.toString(),
      senderRole: json['sender_role']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      createdAt:
          DateTime.tryParse(json['created_at']?.toString() ?? '') ??
          DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
    id,
    threadId,
    orderId,
    chatType,
    senderId,
    senderUserId,
    senderPassengerId,
    senderRole,
    body,
    createdAt,
  ];
}

class ChatMessagesResponse extends Equatable {
  const ChatMessagesResponse({required this.messages});

  final List<ChatMessage> messages;

  factory ChatMessagesResponse.fromJson(dynamic json) {
    if (json is List<dynamic>) {
      return ChatMessagesResponse(
        messages: json
            .whereType<Map<String, dynamic>>()
            .map(ChatMessage.fromJson)
            .toList(),
      );
    }

    final map = json as Map<String, dynamic>? ?? <String, dynamic>{};
    final messagesJson =
        (map['messages'] as List<dynamic>? ??
                map['items'] as List<dynamic>? ??
                const [])
            .whereType<Map<String, dynamic>>()
            .toList();

    return ChatMessagesResponse(
      messages: messagesJson.map(ChatMessage.fromJson).toList(),
    );
  }

  @override
  List<Object?> get props => [messages];
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
    final payload =
        json['payload'] as Map<String, dynamic>? ?? <String, dynamic>{};
    final location = payload['location'] as Map<String, dynamic>?;
    final timestamp =
        payload['recorded_at']?.toString() ??
        payload['assigned_at']?.toString() ??
        payload['arrived_at']?.toString() ??
        payload['started_at']?.toString() ??
        payload['completed_at']?.toString() ??
        payload['cancelled_at']?.toString() ??
        json['occurred_at']?.toString() ??
        '';

    return OrderEvent(
      event: json['event']?.toString() ?? json['type']?.toString() ?? '',
      requestId:
          json['request_id']?.toString() ??
          payload['request_id']?.toString() ??
          '',
      occurredAt: DateTime.tryParse(timestamp) ?? DateTime.now(),
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
