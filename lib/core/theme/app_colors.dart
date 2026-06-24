import 'package:flutter/material.dart';

/// Paleta de marca de SmartStock Mobile (modo claro).
///
/// Colores aprobados para el proyecto:
/// - [primary]   #456EFD  -> acento / acciones principales
/// - [ink]       #050914  -> color de texto principal (navy de marca)
/// - [white]     #FFFFFF  -> superficies
///
/// Diseno minimalista y profesional: fondo claro, superficies blancas,
/// un unico acento azul y tipografia en navy.
class AppColors {
  AppColors._();

  static const Color primary = Color(0xFF456EFD);
  static const Color ink = Color(0xFF050914);
  static const Color white = Color(0xFFFFFFFF);

  // Fondos y superficies.
  static const Color background = Color(0xFFF5F7FB);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE5E9F2);

  // Texto.
  static const Color textPrimary = ink;
  static const Color textSecondary = Color(0xFF5B6477);
  static const Color textMuted = Color(0xFF939BAC);

  // Estados.
  static const Color success = Color(0xFF18A957);
  static const Color warning = Color(0xFFE08A00);
  static const Color danger = Color(0xFFDC3545);

  // Tinte suave del acento (fondos de iconos, chips, indicadores).
  static const Color primarySoft = Color(0xFFEAF0FF);
}
