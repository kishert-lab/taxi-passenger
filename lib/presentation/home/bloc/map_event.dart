part of 'map_bloc.dart';

sealed class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

class MapCurrentLocationRequested extends MapEvent {
  const MapCurrentLocationRequested();
}

class MapCarClassesRequested extends MapEvent {
  const MapCarClassesRequested();
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

class MapRouteEstimateRequested extends MapEvent {
  const MapRouteEstimateRequested();
}

class MapCarClassSelected extends MapEvent {
  const MapCarClassSelected(this.carClassId);

  final String carClassId;

  @override
  List<Object?> get props => [carClassId];
}
