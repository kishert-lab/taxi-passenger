import 'package:flutter/material.dart';
import 'package:taxi_passenger/core/theme/app_colors.dart';
import 'package:taxi_passenger/domain/models/models.dart';

class MapPlaceholder extends StatelessWidget {
  const MapPlaceholder({
    super.key,
    required this.currentLocation,
    required this.pickupPoint,
    required this.destinationPoint,
    required this.nearbyCars,
    this.driverLocation,
  });

  final GeoPoint? currentLocation;
  final GeoPoint? pickupPoint;
  final GeoPoint? destinationPoint;
  final List<NearbyCar> nearbyCars;
  final GeoPoint? driverLocation;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [AppColors.midnightSoft, AppColors.midnight],
        ),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: _MapPatternPainter(),
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: _MapPin(label: 'Вы', color: AppColors.taxiGold),
          ),
          if (pickupPoint != null)
            const Positioned(
              top: 90,
              left: 80,
              child: _MapPin(label: 'A', color: AppColors.taxiGoldDeep),
            ),
          if (destinationPoint != null)
            const Positioned(
              bottom: 120,
              right: 60,
              child: _MapPin(label: 'B', color: Colors.white),
            ),
          for (final car in nearbyCars.take(4))
            Positioned(
              top: 100 + nearbyCars.indexOf(car) * 44,
              right: 28 + nearbyCars.indexOf(car) * 18,
              child: const Icon(
                Icons.local_taxi,
                color: AppColors.taxiGold,
              ),
            ),
          if (driverLocation != null)
            const Positioned(
              bottom: 40,
              left: 40,
              child: Icon(
                Icons.directions_car,
                color: Colors.white,
                size: 30,
              ),
            ),
        ],
      ),
    );
  }
}

class _MapPin extends StatelessWidget {
  const _MapPin({
    required this.label,
    this.color = AppColors.taxiGoldDeep,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final textColor = color == Colors.white ? AppColors.midnight : Colors.white;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _MapPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.skyline.withValues(alpha: 0.35)
      ..strokeWidth = 2;

    for (var i = 0.0; i < size.width; i += 42) {
      canvas.drawLine(Offset(i, 0), Offset(i + 50, size.height), paint);
    }
    for (var j = 24.0; j < size.height; j += 58) {
      canvas.drawLine(Offset(0, j), Offset(size.width, j - 12), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
