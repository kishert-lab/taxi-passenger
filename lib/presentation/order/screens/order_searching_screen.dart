import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:taxi_passenger/domain/models/models.dart';
import 'package:taxi_passenger/presentation/order/bloc/order_bloc.dart';
import 'package:taxi_passenger/presentation/order/bloc/order_realtime_bloc.dart';
import 'package:taxi_passenger/presentation/order/widgets/order_status_card.dart';

class OrderSearchingScreen extends StatelessWidget {
  const OrderSearchingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<OrderRealtimeBloc, OrderRealtimeState>(
      listener: (context, state) {
        final event = state.lastEvent;
        if (event == null) {
          return;
        }
        context.read<OrderBloc>().add(OrderActiveUpdated(event.order));
        if (event.order.status == OrderStatus.assigned ||
            event.order.status == OrderStatus.driverArriving) {
          context.go('/order/active');
        } else if (event.order.status == OrderStatus.cancelled) {
          context.go('/home');
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Поиск водителя')),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: BlocBuilder<OrderBloc, OrderState>(
              builder: (context, state) {
                final order = state.activeOrder;
                if (order == null) {
                  return const Center(child: Text('Водитель не найден'));
                }
                return Column(
                  children: [
                    const SizedBox(height: 32),
                    const SizedBox(
                      width: 72,
                      height: 72,
                      child: CircularProgressIndicator(strokeWidth: 6),
                    ),
                    const SizedBox(height: 24),
                    OrderStatusCard(
                      order: order,
                      extraText: 'Ожидаем события order.searching / order.assigned',
                    ),
                    const Spacer(),
                    OutlinedButton(
                      onPressed: () {
                        context.read<OrderBloc>().add(const OrderCancelRequested());
                        context.go('/home');
                      },
                      child: const Text('Отменить заказ'),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
