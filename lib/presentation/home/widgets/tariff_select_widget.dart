import 'package:flutter/material.dart';
import 'package:taxi_passenger/core/theme/app_colors.dart';
import 'package:taxi_passenger/domain/models/models.dart';

class TariffSelectWidget extends StatelessWidget {
  const TariffSelectWidget({
    super.key,
    required this.tariffs,
    required this.selectedTariffId,
    required this.onSelected,
  });

  final List<Tariff> tariffs;
  final String selectedTariffId;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) {
    if (tariffs.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 98,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: tariffs.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final tariff = tariffs[index];
          final selected = tariff.id == selectedTariffId;

          return GestureDetector(
            onTap: () => onSelected(tariff.id),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 150,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: selected ? AppColors.taxiGold : Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: selected ? AppColors.taxiGoldDeep : AppColors.line,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    tariff.name,
                    style: TextStyle(
                      color: selected
                          ? AppColors.midnight
                          : AppColors.midnightSoft,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    tariff.description,
                    style: TextStyle(
                      color: selected ? AppColors.midnightSoft : AppColors.skyline,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
