import 'package:flutter/material.dart';
import 'package:taxi_passenger/core/theme/app_colors.dart';
import 'package:taxi_passenger/domain/models/models.dart';

class CarClassSelectWidget extends StatelessWidget {
  const CarClassSelectWidget({
    super.key,
    required this.carClasses,
    required this.selectedCarClassId,
    required this.onSelected,
  });

  final List<CarClass> carClasses;
  final String selectedCarClassId;
  final ValueChanged<String> onSelected;

  String _buildSubtitle(CarClass carClass) {
    if (carClass.description.isNotEmpty) {
      return carClass.description;
    }

    if (carClass.minimumPrice.isNotEmpty) {
      return 'от ${carClass.minimumPrice}';
    }

    return carClass.basePrice;
  }

  @override
  Widget build(BuildContext context) {
    if (carClasses.isEmpty) {
      return const SizedBox.shrink();
    }

    return SizedBox(
      height: 98,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: carClasses.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          final carClass = carClasses[index];
          final selected = carClass.id == selectedCarClassId;

          return GestureDetector(
            onTap: () => onSelected(carClass.id),
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
                    carClass.name,
                    style: TextStyle(
                      color: selected
                          ? AppColors.midnight
                          : AppColors.midnightSoft,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _buildSubtitle(carClass),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: selected
                          ? AppColors.midnightSoft
                          : AppColors.skyline,
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
