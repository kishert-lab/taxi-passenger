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
    context.read<MapBloc>().add(const MapCarClassesRequested());
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

    mapBloc.add(const MapRouteEstimateRequested());
  }

  void _createOrder(MapState mapState) {
    final pickup = mapState.pickupPoint;
    final destination = mapState.destinationPoint;
    if (pickup == null ||
        destination == null ||
        mapState.selectedCarClassId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Укажите адреса маршрута и класс автомобиля'),
        ),
      );
      return;
    }

    context.read<OrderBloc>().add(
      OrderCreateRequested(
        pickup: pickup,
        destination: destination,
        carClassId: _selectedCarClassCode(mapState),
      ),
    );
  }

  String _selectedCarClassCode(MapState mapState) {
    final selected = mapState.carClasses.where(
      (carClass) => carClass.id == mapState.selectedCarClassId,
    );
    if (selected.isEmpty) {
      return mapState.selectedCarClassId;
    }

    final carClass = selected.first;
    return carClass.code.isNotEmpty ? carClass.code : carClass.id;
  }

  void _openOrderByStatus(Order order) {
    switch (order.status) {
      case OrderStatus.searching:
        context.go('/order/searching');
      case OrderStatus.assigned:
      case OrderStatus.driverArriving:
      case OrderStatus.driverWaiting:
        context.go('/order/active');
      case OrderStatus.inProgress:
        context.go('/order/trip');
      case OrderStatus.completed:
        context.go('/order/completed', extra: order);
      case OrderStatus.cancelled:
      case OrderStatus.failed:
        context.go('/home');
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderBloc, OrderState>(
      listenWhen: (previous, current) =>
          previous.activeOrder != current.activeOrder &&
          current.activeOrder != null,
      listener: (context, state) {
        final order = state.activeOrder;
        if (order != null) {
          _openOrderByStatus(order);
        }
      },
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
              return LayoutBuilder(
                builder: (context, constraints) {
                  final mapHeight = constraints.maxHeight >= 760
                      ? 280.0
                      : (constraints.maxHeight * 0.26).clamp(180.0, 280.0);

                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        SizedBox(
                          height: mapHeight,
                          child: MapPlaceholder(
                            currentLocation: state.currentLocation,
                            pickupPoint: state.pickupPoint,
                            destinationPoint: state.destinationPoint,
                            nearbyCars: state.nearbyCars,
                          ),
                        ),
                        const SizedBox(height: 16),
                        Expanded(
                          child: SingleChildScrollView(
                            child: Card(
                              child: Padding(
                                padding: const EdgeInsets.all(18),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    _AddressTile(
                                      title: 'Откуда',
                                      value:
                                          state.pickupPoint?.address ??
                                          'Выберите точку посадки',
                                      onTap: () => _selectAddress(
                                        AddressSearchMode.pickup,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    _AddressTile(
                                      title: 'Куда',
                                      value:
                                          state.destinationPoint?.address ??
                                          'Выберите точку назначения',
                                      onTap: () => _selectAddress(
                                        AddressSearchMode.destination,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Класс автомобиля',
                                      style: Theme.of(
                                        context,
                                      ).textTheme.titleSmall,
                                    ),
                                    const SizedBox(height: 12),
                                    if (state.isLoadingCarClasses)
                                      const Center(
                                        child: CircularProgressIndicator(),
                                      )
                                    else if (state.carClasses.isEmpty)
                                      Text(
                                        'Классы автомобилей пока не загружены',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodyMedium,
                                      )
                                    else
                                      CarClassSelectWidget(
                                        carClasses: state.carClasses,
                                        selectedCarClassId:
                                            state.selectedCarClassId,
                                        onSelected: (carClassId) {
                                          context.read<MapBloc>().add(
                                            MapCarClassSelected(carClassId),
                                          );
                                        },
                                      ),
                                    const SizedBox(height: 16),
                                    if (state.isLoadingEstimate)
                                      const FullScreenLoader(
                                        message: 'Считаем маршрут...',
                                      )
                                    else if (state.routeEstimate != null)
                                      _RouteEstimateView(
                                        estimate: state.routeEstimate!,
                                      ),
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
                          ),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}

class _RouteEstimateView extends StatelessWidget {
  const _RouteEstimateView({required this.estimate});

  final RouteEstimate estimate;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (!estimate.available) {
      return Text(
        estimate.message.isNotEmpty
            ? estimate.message
            : 'Расчет цены сейчас недоступен',
        style: theme.textTheme.bodyMedium?.copyWith(
          color: theme.colorScheme.error,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          estimate.priceLabel,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Подача ~${estimate.etaMinutes} мин',
          style: theme.textTheme.bodyMedium,
        ),
        const SizedBox(height: 4),
        Text(
          estimate.message.isNotEmpty
              ? estimate.message
              : 'Итоговая стоимость может измениться после назначения водителя',
          style: theme.textTheme.bodySmall,
        ),
      ],
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
                  Text(value, maxLines: 3, overflow: TextOverflow.ellipsis),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
