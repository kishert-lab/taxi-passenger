part of 'map_bloc.dart';

class MapState extends Equatable {
  const MapState({
    this.currentLocation,
    this.pickupPoint,
    this.destinationPoint,
    this.nearbyCars = const [],
    this.carClasses = const [],
    this.routeEstimate,
    this.selectedCarClassId = '',
    this.isLoadingLocation = false,
    this.isLoadingCars = false,
    this.isLoadingCarClasses = false,
    this.isLoadingEstimate = false,
    this.errorMessage,
  });

  final GeoPoint? currentLocation;
  final GeoPoint? pickupPoint;
  final GeoPoint? destinationPoint;
  final List<NearbyCar> nearbyCars;
  final List<CarClass> carClasses;
  final RouteEstimate? routeEstimate;
  final String selectedCarClassId;
  final bool isLoadingLocation;
  final bool isLoadingCars;
  final bool isLoadingCarClasses;
  final bool isLoadingEstimate;
  final String? errorMessage;

  MapState copyWith({
    GeoPoint? currentLocation,
    GeoPoint? pickupPoint,
    GeoPoint? destinationPoint,
    List<NearbyCar>? nearbyCars,
    List<CarClass>? carClasses,
    RouteEstimate? routeEstimate,
    bool clearRouteEstimate = false,
    String? selectedCarClassId,
    bool? isLoadingLocation,
    bool? isLoadingCars,
    bool? isLoadingCarClasses,
    bool? isLoadingEstimate,
    String? errorMessage,
  }) {
    return MapState(
      currentLocation: currentLocation ?? this.currentLocation,
      pickupPoint: pickupPoint ?? this.pickupPoint,
      destinationPoint: destinationPoint ?? this.destinationPoint,
      nearbyCars: nearbyCars ?? this.nearbyCars,
      carClasses: carClasses ?? this.carClasses,
      routeEstimate: clearRouteEstimate
          ? null
          : routeEstimate ?? this.routeEstimate,
      selectedCarClassId: selectedCarClassId ?? this.selectedCarClassId,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      isLoadingCars: isLoadingCars ?? this.isLoadingCars,
      isLoadingCarClasses: isLoadingCarClasses ?? this.isLoadingCarClasses,
      isLoadingEstimate: isLoadingEstimate ?? this.isLoadingEstimate,
      errorMessage: errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    currentLocation,
    pickupPoint,
    destinationPoint,
    nearbyCars,
    carClasses,
    routeEstimate,
    selectedCarClassId,
    isLoadingLocation,
    isLoadingCars,
    isLoadingCarClasses,
    isLoadingEstimate,
    errorMessage,
  ];
}
