import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:taxi_passenger/data/services/backend_availability_service.dart';

class ServiceUnavailableScreen extends StatelessWidget {
  const ServiceUnavailableScreen({super.key, required this.service});

  final BackendAvailabilityService service;

  @override
  Widget build(BuildContext context) {
    final lastCheckedAt = service.lastCheckedAt;
    final lastCheckedLabel = lastCheckedAt == null
        ? 'Проверка подключения выполняется'
        : 'Последняя проверка: ${DateFormat('dd.MM.yyyy HH:mm').format(lastCheckedAt)}';

    return ColoredBox(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.cloud_off_outlined,
                  size: 64,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(height: 16),
                Text(
                  'Сервис временно недоступен',
                  style: Theme.of(context).textTheme.headlineSmall,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  'Приложение автоматически повторяет проверку доступности каждые 5 минут.',
                  style: Theme.of(context).textTheme.bodyMedium,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                Text(
                  lastCheckedLabel,
                  style: Theme.of(context).textTheme.bodySmall,
                  textAlign: TextAlign.center,
                ),
                if (service.errorMessage != null) ...[
                  const SizedBox(height: 12),
                  Text(
                    service.errorMessage!,
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.error,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
                const SizedBox(height: 24),
                FilledButton(
                  onPressed: service.checkNow,
                  child: const Text('Проверить сейчас'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
