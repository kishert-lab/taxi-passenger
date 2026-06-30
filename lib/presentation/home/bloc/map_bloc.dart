import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:taxi_passenger/core/config/passenger_app_config.dart';
import 'package:taxi_passenger/core/errors/app_exception.dart';
import 'package:taxi_passenger/data/repositories/geo_repository.dart';
import 'package:taxi_passenger/domain/models/models.dart';

part 'map_event.dart';
part 'map_state.dart';

class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc({required GeoRepository geoRepository})
    : _geoRepository = geoRepository,
      super(MapState(selectedTariffId: PassengerAppConfig.defaultTariffId)) {
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
          errorMessage:
              'РќРµ СѓРґР°Р»РѕСЃСЊ РїРѕР»СѓС‡РёС‚СЊ РіРµРѕРїРѕР·РёС†РёСЋ',
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
      emit(
        state.copyWith(
          errorMessage: 'РЈРєР°Р¶РёС‚Рµ Р°РґСЂРµСЃР° РјР°СЂС€СЂСѓС‚Р°',
        ),
      );
      return;
    }

    emit(
      state.copyWith(
        isLoadingCars: true,
        nearbyCars: const [],
        errorMessage: null,
      ),
    );
    try {
      final cars = await _geoRepository.loadNearbyCars(
        pickup: state.pickupPoint!,
        destination: state.destinationPoint!,
      );
      emit(
        state.copyWith(
          isLoadingCars: false,
          nearbyCars: cars,
          errorMessage: null,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingCars: false,
          nearbyCars: const [],
          errorMessage: error is AppException
              ? error.message
              : 'РћС€РёР±РєР° СЃРѕРµРґРёРЅРµРЅРёСЏ',
        ),
      );
    }
  }

  Future<void> _onRouteEstimateRequested(
    MapRouteEstimateRequested event,
    Emitter<MapState> emit,
  ) async {
    if (state.pickupPoint == null || state.destinationPoint == null) {
      emit(
        state.copyWith(
          errorMessage: 'РЈРєР°Р¶РёС‚Рµ Р°РґСЂРµСЃР° РјР°СЂС€СЂСѓС‚Р°',
        ),
      );
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
      final pickup = state.pickupPoint!;
      final destination = state.destinationPoint!;
      final cityId = destination.cityId ?? pickup.cityId ?? '';
      final tariffId = state.selectedTariffId.isNotEmpty
          ? state.selectedTariffId
          : PassengerAppConfig.defaultTariffId;

      final estimate = await _geoRepository.loadRouteEstimate(
        cityId: cityId,
        tariffId: tariffId,
        pickup: pickup,
        destination: destination,
      );
      emit(
        state.copyWith(
          isLoadingEstimate: false,
          routeEstimate: estimate,
          selectedTariffId: estimate.tariffId.isNotEmpty
              ? estimate.tariffId
              : tariffId,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingEstimate: false,
          clearRouteEstimate: true,
          errorMessage: error is AppException
              ? error.message
              : 'РћС€РёР±РєР° СЃРѕРµРґРёРЅРµРЅРёСЏ',
        ),
      );
    }
  }

  Future<void> _onTariffSelected(
    MapTariffSelected event,
    Emitter<MapState> emit,
  ) async {
    emit(state.copyWith(selectedTariffId: event.tariffId));
  }
}
