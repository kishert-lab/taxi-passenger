import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:taxi_passenger/core/errors/app_exception.dart';
import 'package:taxi_passenger/data/repositories/car_class_repository.dart';
import 'package:taxi_passenger/data/repositories/geo_repository.dart';
import 'package:taxi_passenger/domain/models/models.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc({
    required CarClassRepository carClassRepository,
    required GeoRepository geoRepository,
  }) : _carClassRepository = carClassRepository,
       _geoRepository = geoRepository,
       super(const MapState()) {
    on<MapCurrentLocationRequested>(_onCurrentLocationRequested);
    on<MapCarClassesRequested>(_onCarClassesRequested);
    on<MapPickupUpdated>(_onPickupUpdated);
    on<MapDestinationUpdated>(_onDestinationUpdated);
    on<MapRouteEstimateRequested>(_onRouteEstimateRequested);
    on<MapCarClassSelected>(_onCarClassSelected);
  }

  final CarClassRepository _carClassRepository;
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

  Future<void> _onCarClassesRequested(
    MapCarClassesRequested event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(isLoadingCarClasses: true, errorMessage: null));
    try {
      final carClasses = await _carClassRepository.loadCarClasses();
      final selectedCarClassId = state.selectedCarClassId.isNotEmpty
          ? state.selectedCarClassId
          : (carClasses.isNotEmpty ? carClasses.first.id : '');

      emit(
        state.copyWith(
          isLoadingCarClasses: false,
          carClasses: carClasses,
          selectedCarClassId: selectedCarClassId,
          errorMessage: null,
        ),
      );

      if (selectedCarClassId.isNotEmpty &&
          state.pickupPoint != null &&
          state.destinationPoint != null) {
        add(const MapRouteEstimateRequested());
      }
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingCarClasses: false,
          carClasses: const [],
          errorMessage: error is AppException
              ? error.message
              : 'Ошибка соединения',
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

  Future<void> _onRouteEstimateRequested(
    MapRouteEstimateRequested event,
    Emitter<MapState> emit,
  ) async {
    if (state.pickupPoint == null || state.destinationPoint == null) {
      emit(state.copyWith(errorMessage: 'Укажите адреса маршрута'));
      return;
    }
    if (state.selectedCarClassId.isEmpty) {
      emit(state.copyWith(errorMessage: 'Выберите класс автомобиля'));
      return;
    }

    emit(
      state.copyWith(
        isLoadingEstimate: true,
        clearRouteEstimate: true,
        errorMessage: null,
      ),
    );
    try {
      final estimate = await _geoRepository.loadRouteEstimate(
        carClassId: state.selectedCarClassId,
        pickup: state.pickupPoint!,
        destination: state.destinationPoint!,
      );
      emit(
        state.copyWith(
          isLoadingEstimate: false,
          routeEstimate: estimate,
          selectedCarClassId: estimate.carClassId.isNotEmpty
              ? estimate.carClassId
              : state.selectedCarClassId,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingEstimate: false,
          clearRouteEstimate: true,
          errorMessage: error is AppException
              ? error.message
              : 'Ошибка соединения',
        ),
      );
    }
  }

  Future<void> _onCarClassSelected(
    MapCarClassSelected event,
    Emitter<MapState> emit,
  ) async {
    final previousPickupPoint = state.pickupPoint;
    final previousDestinationPoint = state.destinationPoint;

    emit(
      state.copyWith(
        selectedCarClassId: event.carClassId,
        clearRouteEstimate: true,
        errorMessage: null,
      ),
    );

    if (previousPickupPoint != null && previousDestinationPoint != null) {
      add(const MapRouteEstimateRequested());
    }
  }
}
