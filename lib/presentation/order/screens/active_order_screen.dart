import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxi_passenger/domain/models/models.dart';
import 'package:taxi_passenger/presentation/home/widgets/map_placeholder.dart';
import 'package:taxi_passenger/presentation/order/bloc/order_bloc.dart';
import 'package:taxi_passenger/presentation/order/bloc/order_realtime_bloc.dart';
import 'package:taxi_passenger/presentation/order/widgets/order_status_card.dart';

class ActiveOrderScreen extends StatelessWidget {
  const ActiveOrderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderRealtimeBloc, OrderRealtimeState>(
      listener: (context, state) {
        final event = state.lastEvent;
        if (event == null) {
          return;
        }
        context.read<OrderBloc>().add(OrderActiveUpdated(event.order));
        if (event.order.status == OrderStatus.inProgress) {
          context.go('/order/trip');
        } else if (event.order.status == OrderStatus.completed) {
          context.go('/order/completed', extra: event.order);
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Активный заказ')),
        body: SafeArea(
          child: BlocBuilder<OrderBloc, OrderState>(
            builder: (context, state) {
              final order = state.activeOrder;
              if (order == null) {
                return const Center(child: Text('Заказ не найден'));
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
                        driverLocation:
                            context.watch<OrderRealtimeBloc>().state.driverLocation,
                      ),
                    ),
                    const SizedBox(height: 16),
                    OrderStatusCard(
                      order: order,
                      extraText:
                          '${order.driver?.name ?? 'Водитель'} • ${order.car?.brand ?? ''} ${order.car?.model ?? ''} ${order.car?.plateNumber ?? ''}',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: FilledButton.tonal(
                            onPressed: () {},
                            child: const Text('Позвонить водителю'),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              context.read<OrderBloc>().add(const OrderCancelRequested());
                              context.go('/home');
                            },
                            child: const Text('Отменить заказ'),
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
