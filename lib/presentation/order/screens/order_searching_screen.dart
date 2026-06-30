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
        context.read<OrderBloc>().add(OrderActiveUpdated(state.activeOrder));
        final order = state.activeOrder;
        if (order == null) {
          return;
        }

        if (order.status == OrderStatus.assigned ||
            order.status == OrderStatus.driverArriving ||
            order.status == OrderStatus.driverWaiting) {
          context.go('/order/active');
        } else if (order.status == OrderStatus.cancelled ||
            order.status == OrderStatus.failed) {
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
                  return const Center(child: Text('Активный заказ не найден'));
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
                    const SizedBox(height: 12),
                    OrderStatusCard(
                      order: order,
                      extraText: 'Ожидаем назначение водителя',
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
