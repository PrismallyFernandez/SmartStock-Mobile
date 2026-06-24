import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// Marca minimalista de SmartStock: un cuadrado redondeado con el acento azul
/// y el icono de inventario. Sin imagenes externas para mantener el peso bajo.
class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.primary,
        borderRadius: BorderRadius.circular(size * 0.28),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withValues(alpha: 0.35),
            blurRadius: size * 0.4,
            offset: Offset(0, size * 0.12),
          ),
        ],
      ),
      child: Icon(
        Icons.inventory_2_rounded,
        color: AppColors.white,
        size: size * 0.55,
      ),
    );
  }
}
