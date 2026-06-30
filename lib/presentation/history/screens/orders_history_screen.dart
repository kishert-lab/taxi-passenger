import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';
import 'package:taxi_passenger/core/widgets/app_state_widgets.dart';
import 'package:taxi_passenger/domain/models/models.dart';
import 'package:taxi_passenger/presentation/order/bloc/order_bloc.dart';

class OrdersHistoryScreen extends StatefulWidget {
  const OrdersHistoryScreen({super.key});

  @override
  State<OrdersHistoryScreen> createState() => _OrdersHistoryScreenState();
}

class _OrdersHistoryScreenState extends State<OrdersHistoryScreen> {
  @override
  void initState() {
    super.initState();
    context.read<OrderBloc>().add(const OrderHistoryRequested());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('История заказов')),
      body: SafeArea(
        child: BlocBuilder<OrderBloc, OrderState>(
          builder: (context, state) {
            if (state.isLoadingHistory) {
              return const FullScreenLoader();
            }
            if (state.errorMessage != null && state.history.isEmpty) {
              return Center(child: ErrorText(state.errorMessage!));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.history.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final order = state.history[index];
                return _HistoryTile(order: order);
              },
            );
          },
        ),
      ),
    );
  }
}

class _HistoryTile extends StatelessWidget {
  const _HistoryTile({required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text('${order.pickup.address} -> ${order.destination.address}'),
        subtitle: Text(DateFormat('dd.MM.yyyy').format(order.createdAt)),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text('${order.price.toStringAsFixed(0)} ₽'),
            Text(orderStatusLabel(order.status)),
          ],
        ),
      ),
    );
  }
}
