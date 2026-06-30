import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:taxi_passenger/data/repositories/geo_repository.dart';
import 'package:taxi_passenger/domain/models/models.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc({required GeoRepository geoRepository})
      : _geoRepository = geoRepository,
        super(const MapState()) {
    on<MapCurrentLocationRequested>(_onCurrentLocationRequested);
    on<MapPickupUpdated>(_onPickupUpdated);
    on<MapDestinationUpdated>(_onDestinationUpdated);
    on<MapNearbyCarsRequested>(_onNearbyCarsRequested);
    on<MapRouteEstimateRequested>(_onRouteEstimateRequested);
    on<MapTariffSelected>(_onTariffSelected);
  }

  final GeoRepository _geoRepository;

  Future<void> _onCurrentLocationRequested(
    MapCurrentLocationRequested event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(isLoadingLocation: true, errorMessage: null));
    try {
      final point = await _geoRepository.loadCurrentLocation();
      emit(
        state.copyWith(
          isLoadingLocation: false,
          currentLocation: point,
          pickupPoint: state.pickupPoint ?? point,
        ),
      );
    } catch (_) {
      emit(
        state.copyWith(
          isLoadingLocation: false,
          errorMessage: 'Не удалось получить геопозицию',
        ),
      );
    }
  }

  Future<void> _onPickupUpdated(
    MapPickupUpdated event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(pickupPoint: event.point, errorMessage: null));
  }

  Future<void> _onDestinationUpdated(
    MapDestinationUpdated event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(destinationPoint: event.point, errorMessage: null));
  }

  Future<void> _onNearbyCarsRequested(
    MapNearbyCarsRequested event,
    Emitter<MapState> emit,
  ) async {
    if (state.pickupPoint == null || state.destinationPoint == null) {
      emit(state.copyWith(errorMessage: 'Укажите адреса маршрута'));
      return;
    }

    emit(state.copyWith(isLoadingCars: true, errorMessage: null));
    try {
      final cars = await _geoRepository.loadNearbyCars(
        pickup: state.pickupPoint!,
        destination: state.destinationPoint!,
      );
      emit(
        state.copyWith(
          isLoadingCars: false,
          nearbyCars: cars,
          errorMessage: cars.isEmpty ? 'Поблизости нет свободных машин' : null,
        ),
      );
    } catch (_) {
      emit(state.copyWith(isLoadingCars: false, errorMessage: 'Ошибка соединения'));
    }
  }

  Future<void> _onRouteEstimateRequested(
    MapRouteEstimateRequested event,
    Emitter<MapState> emit,
  ) async {
    if (state.pickupPoint == null || state.destinationPoint == null) {
      emit(state.copyWith(errorMessage: 'Укажите адреса маршрута'));
      return;
    }

    emit(state.copyWith(isLoadingEstimate: true, errorMessage: null));
    try {
      final estimate = await _geoRepository.loadRouteEstimate(
        pickup: state.pickupPoint!,
        destination: state.destinationPoint!,
      );
      emit(
        state.copyWith(
          isLoadingEstimate: false,
          routeEstimate: estimate,
          selectedTariffId: state.selectedTariffId.isNotEmpty
              ? state.selectedTariffId
              : (estimate.tariffs.isNotEmpty ? estimate.tariffs.first.id : ''),
        ),
      );
    } catch (_) {
      emit(state.copyWith(isLoadingEstimate: false, errorMessage: 'Ошибка соединения'));
    }
  }

  Future<void> _onTariffSelected(
    MapTariffSelected event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(selectedTariffId: event.tariffId));
  }
}
