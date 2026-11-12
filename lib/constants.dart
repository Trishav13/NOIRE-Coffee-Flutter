import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  static const Color primary = Color(0xFF66734F);
  static const Color background = Color(0xFF101510);
  static const Color cardBackground = Color(0xFF1A241D);
  static const Color secondaryText = Color(0xFFB5B8AA);
  static const Color white = Color(0xFFF5F0E6);
  static const Color cream = Color(0xFFEFE9DD);
  static const Color accent = Color(0xFFC9A879);
}

class AppStyles {
  static TextStyle heading = GoogleFonts.dmSerifDisplay(fontSize: 38, color: AppColors.white);
  static TextStyle subHeading = GoogleFonts.poppins(fontSize: 20, fontWeight: FontWeight.w700, color: AppColors.white);
  static TextStyle body = GoogleFonts.poppins(fontSize: 14, color: AppColors.secondaryText);
  static TextStyle price = GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.accent);
}
