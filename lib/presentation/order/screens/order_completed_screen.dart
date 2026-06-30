import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:taxi_passenger/domain/models/models.dart';

class OrderCompletedScreen extends StatelessWidget {
  const OrderCompletedScreen({super.key, required this.order});

  final Order order;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Поездка завершена')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${order.price.toStringAsFixed(0)} ₽',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 12),
              Text('${order.pickup.address} -> ${order.destination.address}'),
              const SizedBox(height: 12),
              Text('Оплата: ${order.paymentMethod}'),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Оценить поездку'),
              ),
              const SizedBox(height: 12),
              FilledButton.tonal(
                onPressed: () => context.go('/home'),
                child: const Text('Повторить маршрут'),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.go('/home'),
                child: const Text('На главный экран'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
