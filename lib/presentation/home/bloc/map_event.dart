part of 'map_bloc.dart';

sealed class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class MapCurrentLocationRequested extends MapEvent {
  const MapCurrentLocationRequested();
}

class MapPickupUpdated extends MapEvent {
  const MapPickupUpdated(this.point);

  final GeoPoint point;

  @override
  List<Object?> get props => [point];
}

class MapDestinationUpdated extends MapEvent {
  const MapDestinationUpdated(this.point);

  final GeoPoint point;

  @override
  List<Object?> get props => [point];
}

class MapNearbyCarsRequested extends MapEvent {
  const MapNearbyCarsRequested();
}

class MapRouteEstimateRequested extends MapEvent {
  const MapRouteEstimateRequested();
}

class MapTariffSelected extends MapEvent {
  const MapTariffSelected(this.tariffId);

  final String tariffId;

  @override
  List<Object?> get props => [tariffId];
}
