import 'package:flutter/material.dart';

class AppColors {
  // Primary Colors - Soft Green (Modern & Professional)
  static const Color primary = Color(0xFF2E7D32); // Dark Green
  static const Color primaryLight = Color(0xFF4CAF50); // Medium Green
  static const Color primaryDark = Color(0xFF1B5E20); // Deep Green
  static const Color accent = Color(0xFF66BB6A); // Soft Green

  // Alternative: Uncomment untuk ganti warna
  // Teal/Blue-Green (Modern & Clean)
  // static const Color primary = Color(0xFF00897B);
  // static const Color primaryLight = Color(0xFF26A69A);
  // static const Color primaryDark = Color(0xFF00695C);
  // static const Color accent = Color(0xFF4DB6AC);

  // Deep Blue (Corporate & Professional)
  // static const Color primary = Color(0xFF1565C0);
  // static const Color primaryLight = Color(0xFF1976D2);
  // static const Color primaryDark = Color(0xFF0D47A1);
  // static const Color accent = Color(0xFF42A5F5);

  // Legacy colors (deprecated, use primary instead)
  @Deprecated('Use primary instead')
  static const Color maroon = Color(0xFF2E7D32);
  @Deprecated('Use primaryLight instead')
  static const Color crimson = Color(0xFF4CAF50);
  @Deprecated('Use primaryDark instead')
  static const Color darkRed = Color(0xFF1B5E20);
  @Deprecated('Use accent instead')
  static const Color lightRed = Color(0xFF66BB6A);

  // Status Colors
  static const Color success = Color(0xFF2E7D32); // Dark Green
  static const Color warning = Color(0xFFF57C00); // Orange
  static const Color danger = Color(0xFFC62828); // Dark Red
  static const Color info = Color(0xFF1976D2); // Blue

  // Priority Colors
  static const Color critical = Color(0xFFD32F2F); // Red
  static const Color high = Color(0xFFFF6F00); // Deep Orange
  static const Color medium = Color(0xFFF57C00); // Orange
  static const Color low = Color(0xFF2E7D32); // Green (Primary)

  // Status Badge Colors
  static const Color completed = Color(0xFF2E7D32); // Green
  static const Color inProgress = Color(0xFF1976D2); // Blue
  static const Color assigned = Color(0xFFF57C00); // Orange
  static const Color pending = Color(0xFFEF6C00); // Dark Orange
  static const Color cancelled = Color(0xFFC62828); // Dark Red

  // Background Colors
  static const Color background = Color(0xFFF9FAFB); // Light gray background
  static const Color cardBackground = Colors.white;
  static const Color divider = Color(0xFFE0E0E0);

  // Text Colors
  static const Color textPrimary = Color(0xFF212121);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
}
