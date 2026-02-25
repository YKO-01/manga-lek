import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors
  static const Color primary = Color(0xFFFF6B35);
  static const Color primaryLight = Color(0xFFFF8A5B);
  static const Color primaryDark = Color(0xFFE55A2B);
  
  // Background Colors - Dark Theme
  static const Color backgroundDark = Color(0xFF0D0D0D);
  static const Color surfaceDark = Color(0xFF1A1A1A);
  static const Color cardDark = Color(0xFF242424);
  
  // Background Colors - Light Theme
  static const Color backgroundLight = Color(0xFFF5F5F5);
  static const Color surfaceLight = Color(0xFFFFFFFF);
  static const Color cardLight = Color(0xFFFFFFFF);
  
  // Text Colors
  static const Color textPrimaryDark = Color(0xFFFFFFFF);
  static const Color textSecondaryDark = Color(0xFFB3B3B3);
  static const Color textTertiaryDark = Color(0xFF808080);
  
  static const Color textPrimaryLight = Color(0xFF1A1A1A);
  static const Color textSecondaryLight = Color(0xFF666666);
  static const Color textTertiaryLight = Color(0xFF999999);
  
  // Status Colors
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFFB300);
  static const Color error = Color(0xFFE53935);
  static const Color info = Color(0xFF2196F3);
  
  // Gradient Colors
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  
  static const LinearGradient darkOverlay = LinearGradient(
    colors: [Colors.transparent, Color(0xCC000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  
  // Genre Colors
  static const Map<String, Color> genreColors = {
    'Action': Color(0xFFE53935),
    'Adventure': Color(0xFF43A047),
    'Comedy': Color(0xFFFFB300),
    'Drama': Color(0xFF8E24AA),
    'Fantasy': Color(0xFF3949AB),
    'Horror': Color(0xFF212121),
    'Mystery': Color(0xFF5D4037),
    'Romance': Color(0xFFE91E63),
    'Sci-Fi': Color(0xFF00ACC1),
    'Slice of Life': Color(0xFF7CB342),
    'Sports': Color(0xFFFF7043),
    'Supernatural': Color(0xFF7E57C2),
  };
  
  static Color getGenreColor(String genre) {
    return genreColors[genre] ?? primary;
  }
}
