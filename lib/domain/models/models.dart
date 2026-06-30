import 'package:equatable/equatable.dart';

class Passenger extends Equatable {
  const Passenger({
    required this.id,
    required this.phone,
    required this.name,
    required this.email,
    required this.avatar,
  });

  final String id;
  final String phone;
  final String name;
  final String email;
  final String avatar;

  factory Passenger.fromJson(Map<String, dynamic> json) {
    return Passenger(
      id: json['id']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      email: json['email']?.toString() ?? '',
      avatar: json['avatar']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'phone': phone,
        'name': name,
        'email': email,
        'avatar': avatar,
      };

  Passenger copyWith({String? name, String? email}) {
    return Passenger(
      id: id,
      phone: phone,
      name: name ?? this.name,
      email: email ?? this.email,
      avatar: avatar,
    );
  }

  @override
  List<Object?> get props => [id, phone, name, email, avatar];
}

class GeoPoint extends Equatable {
  const GeoPoint({
    required this.lat,
    required this.lng,
    required this.address,
  });

  final double lat;
  final double lng;
  final String address;

  factory GeoPoint.fromJson(Map<String, dynamic> json) {
    return GeoPoint(
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
      address: json['address']?.toString() ?? '',
    );
  }

  factory GeoPoint.fromAddressSearchJson(Map<String, dynamic> json) {
    final coordinates = json['coordinates'] as Map<String, dynamic>? ??
        <String, dynamic>{};
    return GeoPoint(
      lat: (coordinates['latitude'] as num?)?.toDouble() ?? 0,
      lng: (coordinates['longitude'] as num?)?.toDouble() ?? 0,
      address: json['address']?.toString() ??
          json['name']?.toString() ??
          '',
    );
  }

  Map<String, dynamic> toJson() => {
        'lat': lat,
        'lng': lng,
        'address': address,
      };

  @override
  List<Object?> get props => [lat, lng, address];
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
      driverId: json['driverId']?.toString() ?? '',
      carId: json['carId']?.toString() ?? '',
      lat: (json['lat'] as num?)?.toDouble() ?? 0,
      lng: (json['lng'] as num?)?.toDouble() ?? 0,
      distanceMeters: (json['distanceMeters'] as num?)?.toInt() ?? 0,
      etaMinutes: (json['etaMinutes'] as num?)?.toInt() ?? 0,
      carClass: json['carClass']?.toString() ?? '',
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

class Driver extends Equatable {
  const Driver({
    required this.id,
    required this.name,
    required this.phone,
    required this.rating,
    required this.avatar,
  });

  final String id;
  final String name;
  final String phone;
  final double rating;
  final String avatar;

  factory Driver.fromJson(Map<String, dynamic> json) {
    return Driver(
      id: json['id']?.toString() ?? '',
      name: json['name']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      rating: (json['rating'] as num?)?.toDouble() ?? 0,
      avatar: json['avatar']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, name, phone, rating, avatar];
}

class Car extends Equatable {
  const Car({
    required this.id,
    required this.brand,
    required this.model,
    required this.color,
    required this.plateNumber,
    required this.className,
  });

  final String id;
  final String brand;
  final String model;
  final String color;
  final String plateNumber;
  final String className;

  factory Car.fromJson(Map<String, dynamic> json) {
    return Car(
      id: json['id']?.toString() ?? '',
      brand: json['brand']?.toString() ?? '',
      model: json['model']?.toString() ?? '',
      color: json['color']?.toString() ?? '',
      plateNumber: json['plateNumber']?.toString() ?? '',
      className: json['className']?.toString() ?? '',
    );
  }

  @override
  List<Object?> get props => [id, brand, model, color, plateNumber, className];
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
    required this.price,
    required this.etaMinutes,
    required this.tariffs,
  });

  final double price;
  final int etaMinutes;
  final List<Tariff> tariffs;

  factory RouteEstimate.fromJson(Map<String, dynamic> json) {
    final tariffsJson = (json['tariffs'] as List<dynamic>? ?? [])
        .cast<Map<String, dynamic>>();
    return RouteEstimate(
      price: (json['price'] as num?)?.toDouble() ?? 0,
      etaMinutes: (json['etaMinutes'] as num?)?.toInt() ?? 0,
      tariffs: tariffsJson.map(Tariff.fromJson).toList(),
    );
  }

  @override
  List<Object?> get props => [price, etaMinutes, tariffs];
}

enum OrderStatus {
  searching,
  assigned,
  driverArriving,
  inProgress,
  completed,
  cancelled,
}

OrderStatus orderStatusFromString(String value) {
  switch (value) {
    case 'assigned':
      return OrderStatus.assigned;
    case 'driver_arriving':
      return OrderStatus.driverArriving;
    case 'in_progress':
      return OrderStatus.inProgress;
    case 'completed':
      return OrderStatus.completed;
    case 'cancelled':
      return OrderStatus.cancelled;
    default:
      return OrderStatus.searching;
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
    case OrderStatus.inProgress:
      return 'Поездка началась';
    case OrderStatus.completed:
      return 'Поездка завершена';
    case OrderStatus.cancelled:
      return 'Заказ отменен';
  }
}

class Order extends Equatable {
  const Order({
    required this.id,
    required this.status,
    required this.pickup,
    required this.destination,
    required this.tariffId,
    required this.price,
    required this.driver,
    required this.car,
    required this.createdAt,
    required this.paymentMethod,
    required this.etaMinutes,
    required this.distanceMeters,
  });

  final String id;
  final OrderStatus status;
  final GeoPoint pickup;
  final GeoPoint destination;
  final String tariffId;
  final double price;
  final Driver? driver;
  final Car? car;
  final DateTime createdAt;
  final String paymentMethod;
  final int etaMinutes;
  final int distanceMeters;

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id']?.toString() ?? '',
      status: orderStatusFromString(json['status']?.toString() ?? ''),
      pickup: GeoPoint.fromJson(
        (json['pickup'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
      destination: GeoPoint.fromJson(
        (json['destination'] as Map<String, dynamic>? ?? <String, dynamic>{}),
      ),
      tariffId: json['tariffId']?.toString() ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0,
      driver: json['driver'] is Map<String, dynamic>
          ? Driver.fromJson(json['driver'] as Map<String, dynamic>)
          : null,
      car: json['car'] is Map<String, dynamic>
          ? Car.fromJson(json['car'] as Map<String, dynamic>)
          : null,
      createdAt: DateTime.tryParse(json['createdAt']?.toString() ?? '') ??
          DateTime.now(),
      paymentMethod: json['paymentMethod']?.toString() ?? 'Наличные',
      etaMinutes: (json['etaMinutes'] as num?)?.toInt() ?? 0,
      distanceMeters: (json['distanceMeters'] as num?)?.toInt() ?? 0,
    );
  }

  Order copyWith({
    OrderStatus? status,
    Driver? driver,
    Car? car,
    int? etaMinutes,
    int? distanceMeters,
  }) {
    return Order(
      id: id,
      status: status ?? this.status,
      pickup: pickup,
      destination: destination,
      tariffId: tariffId,
      price: price,
      driver: driver ?? this.driver,
      car: car ?? this.car,
      createdAt: createdAt,
      paymentMethod: paymentMethod,
      etaMinutes: etaMinutes ?? this.etaMinutes,
      distanceMeters: distanceMeters ?? this.distanceMeters,
    );
  }

  @override
  List<Object?> get props => [
        id,
        status,
        pickup,
        destination,
        tariffId,
        price,
        driver,
        car,
        createdAt,
        paymentMethod,
        etaMinutes,
        distanceMeters,
      ];
}

class OrderEvent extends Equatable {
  const OrderEvent({
    required this.type,
    required this.order,
    this.driverLocation,
  });

  final String type;
  final Order order;
  final GeoPoint? driverLocation;

  factory OrderEvent.fromJson(Map<String, dynamic> json) {
    return OrderEvent(
      type: json['type']?.toString() ?? '',
      order: Order.fromJson(
        json['order'] as Map<String, dynamic>? ?? <String, dynamic>{},
      ),
      driverLocation: json['driverLocation'] is Map<String, dynamic>
          ? GeoPoint.fromJson(json['driverLocation'] as Map<String, dynamic>)
          : null,
    );
  }

  @override
  List<Object?> get props => [type, order, driverLocation];
}
