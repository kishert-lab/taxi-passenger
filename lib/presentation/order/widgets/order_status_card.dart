import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taxi_passenger/domain/models/models.dart';

class OrderStatusCard extends StatelessWidget {
  const OrderStatusCard({
    super.key,
    required this.order,
    this.extraText,
  });

  final Order order;
  final String? extraText;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              orderStatusLabel(order.status),
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text('${order.pickup.address} -> ${order.destination.address}'),
            const SizedBox(height: 8),
            Text('Создан ${DateFormat('dd.MM.yyyy HH:mm').format(order.createdAt)}'),
            Text('Стоимость: ${order.priceValue.toStringAsFixed(0)} ₽'),
            if (extraText != null) ...[
              const SizedBox(height: 8),
              Text(extraText!),
            ],
          ],
        ),
      ),
    );
  }
}
