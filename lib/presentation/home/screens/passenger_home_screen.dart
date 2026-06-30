import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxi_passenger/core/theme/app_colors.dart';
import 'package:taxi_passenger/core/widgets/app_state_widgets.dart';
import 'package:taxi_passenger/domain/models/models.dart';
import 'package:taxi_passenger/presentation/home/bloc/map_bloc.dart';
import 'package:taxi_passenger/presentation/home/screens/address_search_screen.dart';
import 'package:taxi_passenger/presentation/home/widgets/map_placeholder.dart';
import 'package:taxi_passenger/presentation/home/widgets/tariff_select_widget.dart';
import 'package:taxi_passenger/presentation/order/bloc/order_bloc.dart';
import 'package:taxi_passenger/presentation/order/bloc/order_realtime_bloc.dart';

class PassengerHomeScreen extends StatefulWidget {
  const PassengerHomeScreen({super.key});

  @override
  State<PassengerHomeScreen> createState() => _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<MapBloc>().add(const MapCurrentLocationRequested());
  }

  Future<void> _selectAddress(AddressSearchMode mode) async {
    final point = await context.push<GeoPoint>('/address-search', extra: mode);
    if (point == null || !mounted) {
      return;
    }

    final mapBloc = context.read<MapBloc>();
    if (mode == AddressSearchMode.pickup) {
      mapBloc.add(MapPickupUpdated(point));
    } else {
      mapBloc.add(MapDestinationUpdated(point));
    }

    mapBloc
      ..add(const MapNearbyCarsRequested())
      ..add(const MapRouteEstimateRequested());
  }

  void _createOrder(MapState mapState) {
    final pickup = mapState.pickupPoint;
    final destination = mapState.destinationPoint;
    if (pickup == null ||
        destination == null ||
        mapState.selectedTariffId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Укажите адреса маршрута')),
      );
      return;
    }

    context.read<OrderBloc>().add(
          OrderCreateRequested(
            pickup: pickup,
            destination: destination,
            tariffId: mapState.selectedTariffId,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<OrderBloc, OrderState>(
          listenWhen: (previous, current) =>
              previous.activeOrder != current.activeOrder &&
              current.activeOrder != null,
          listener: (context, state) {
            context
                .read<OrderRealtimeBloc>()
                .add(const OrderRealtimeConnectRequested());
            context.go('/order/searching');
          },
        ),
      ],
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Пассажир'),
          actions: [
            IconButton(
              onPressed: () => context.push('/orders/history'),
              icon: const Icon(Icons.history),
            ),
            IconButton(
              onPressed: () => context.push('/profile'),
              icon: const Icon(Icons.person_outline),
            ),
          ],
        ),
        body: SafeArea(
          child: BlocBuilder<MapBloc, MapState>(
            builder: (context, state) {
              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(
                      child: MapPlaceholder(
                        currentLocation: state.currentLocation,
                        pickupPoint: state.pickupPoint,
                        destinationPoint: state.destinationPoint,
                        nearbyCars: state.nearbyCars,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(18),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _AddressTile(
                              title: 'Откуда',
                              value: state.pickupPoint?.address ??
                                  'Выберите точку посадки',
                              onTap: () => _selectAddress(AddressSearchMode.pickup),
                            ),
                            const SizedBox(height: 12),
                            _AddressTile(
                              title: 'Куда',
                              value: state.destinationPoint?.address ??
                                  'Выберите точку назначения',
                              onTap: () =>
                                  _selectAddress(AddressSearchMode.destination),
                            ),
                            const SizedBox(height: 16),
                            if (state.isLoadingCars || state.isLoadingEstimate)
                              const FullScreenLoader(
                                message: 'Считаем маршрут...',
                              )
                            else ...[
                              if (state.routeEstimate != null)
                                Text(
                                  'Подача ~${state.routeEstimate!.etaMinutes} мин, стоимость ~${state.routeEstimate!.price.toStringAsFixed(0)} ₽',
                                  style: Theme.of(context).textTheme.titleMedium,
                                ),
                              const SizedBox(height: 16),
                              TariffSelectWidget(
                                tariffs: state.routeEstimate?.tariffs ?? const [],
                                selectedTariffId: state.selectedTariffId,
                                onSelected: (tariffId) {
                                  context
                                      .read<MapBloc>()
                                      .add(MapTariffSelected(tariffId));
                                },
                              ),
                            ],
                            if (state.errorMessage != null) ...[
                              const SizedBox(height: 12),
                              ErrorText(state.errorMessage!),
                            ],
                            const SizedBox(height: 16),
                            BlocBuilder<OrderBloc, OrderState>(
                              builder: (context, orderState) {
                                return ElevatedButton(
                                  onPressed: orderState.isLoading
                                      ? null
                                      : () => _createOrder(state),
                                  child: orderState.isLoading
                                      ? const CircularProgressIndicator(
                                          color: AppColors.midnight,
                                        )
                                      : const Text('Заказать'),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

class _AddressTile extends StatelessWidget {
  const _AddressTile({
    required this.title,
    required this.value,
    required this.onTap,
  });

  final String title;
  final String value;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(18),
      child: Ink(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.mist,
          borderRadius: BorderRadius.circular(18),
        ),
        child: Row(
          children: [
            Icon(
              title == 'Откуда' ? Icons.my_location : Icons.place_outlined,
              color: AppColors.taxiGoldDeep,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: Theme.of(context).textTheme.labelMedium),
                  const SizedBox(height: 4),
                  Text(value, maxLines: 2, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
