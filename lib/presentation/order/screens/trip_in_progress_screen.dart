import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxi_passenger/domain/models/models.dart';
import 'package:taxi_passenger/presentation/home/widgets/map_placeholder.dart';
import 'package:taxi_passenger/presentation/order/bloc/order_bloc.dart';
import 'package:taxi_passenger/presentation/order/bloc/order_realtime_bloc.dart';
import 'package:taxi_passenger/presentation/order/widgets/order_status_card.dart';

class TripInProgressScreen extends StatelessWidget {
  const TripInProgressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderRealtimeBloc, OrderRealtimeState>(
      listener: (context, state) {
        context.read<OrderBloc>().add(OrderActiveUpdated(state.activeOrder));
        final order = state.activeOrder;
        if (order?.status == OrderStatus.completed && order != null) {
          context.go('/order/completed', extra: order);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Поездка')),
        body: SafeArea(
          child: BlocBuilder<OrderBloc, OrderState>(
            builder: (context, state) {
              final order = state.activeOrder;
              if (order == null) {
                return const Center(child: Text('Поездка не найдена'));
              }

              return Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    Expanded(
                      child: MapPlaceholder(
                        currentLocation: order.pickup,
                        pickupPoint: order.pickup,
                        destinationPoint: order.destination,
                        nearbyCars: const [],
                        driverLocation: context
                            .watch<OrderRealtimeBloc>()
                            .state
                            .driverLocation,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OrderStatusCard(
                      order: order,
                      extraText: 'Прибытие ~${order.etaMinutes} мин',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: () {},
                            child: const Text('Связь с водителем'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: () {},
                            child: const Text('Поддержка'),
                          ),
                        ),
                      ],
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
