import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

abstract final class AppSnackBar {
  static void show(
    BuildContext context,
    String message, {
    bool isError = false,
    Duration duration = const Duration(seconds: 3),
  }) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: GoogleFonts.inter()),
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isError ? const Color(0xFFD32F2F) : const Color(0xFF4C54B6),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        duration: duration,
      ),
    );
  }
}
