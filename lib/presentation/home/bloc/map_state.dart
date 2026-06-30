part of 'map_bloc.dart';

class MapState extends Equatable {
  const MapState({
    this.currentLocation,
    this.pickupPoint,
    this.destinationPoint,
    this.nearbyCars = const [],
    this.routeEstimate,
    this.selectedTariffId = '',
    this.isLoadingLocation = false,
    this.isLoadingCars = false,
    this.isLoadingEstimate = false,
    this.errorMessage,
  });

  final GeoPoint? currentLocation;
  final GeoPoint? pickupPoint;
  final GeoPoint? destinationPoint;
  final List<NearbyCar> nearbyCars;
  final RouteEstimate? routeEstimate;
  final String selectedTariffId;
  final bool isLoadingLocation;
  final bool isLoadingCars;
  final bool isLoadingEstimate;
  final String? errorMessage;

  MapState copyWith({
    GeoPoint? currentLocation,
    GeoPoint? pickupPoint,
    GeoPoint? destinationPoint,
    List<NearbyCar>? nearbyCars,
    RouteEstimate? routeEstimate,
    String? selectedTariffId,
    bool? isLoadingLocation,
    bool? isLoadingCars,
    bool? isLoadingEstimate,
    String? errorMessage,
  }) {
    return MapState(
      currentLocation: currentLocation ?? this.currentLocation,
      pickupPoint: pickupPoint ?? this.pickupPoint,
      destinationPoint: destinationPoint ?? this.destinationPoint,
      nearbyCars: nearbyCars ?? this.nearbyCars,
      routeEstimate: routeEstimate ?? this.routeEstimate,
      selectedTariffId: selectedTariffId ?? this.selectedTariffId,
      isLoadingLocation: isLoadingLocation ?? this.isLoadingLocation,
      isLoadingCars: isLoadingCars ?? this.isLoadingCars,
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
        routeEstimate,
        selectedTariffId,
        isLoadingLocation,
        isLoadingCars,
        isLoadingEstimate,
        errorMessage,
      ];
}
