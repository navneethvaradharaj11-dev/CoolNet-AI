import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'views/dashboard_view.dart';

void main() {
  runApp(const CoolNetApp());
}

class CoolNetApp extends StatelessWidget {
  const CoolNetApp({super.key});

  @override
  Widget build(BuildContext context) {
    const background = Color(0xFF080F1C);
    const surface = Color(0xFF101B2B);
    const border = Color(0xFF23334A);
    const accent = Color(0xFF38BDF8);

    final base = ThemeData.dark(useMaterial3: true);

    return MaterialApp(
      title: 'CoolNet AI | Heat-Grid Intelligence',
      debugShowCheckedModeBanner: false,
      theme: base.copyWith(
        scaffoldBackgroundColor: background,
        cardColor: surface,
        dividerColor: border,
        textTheme: GoogleFonts.interTextTheme(base.textTheme),
        colorScheme: base.colorScheme.copyWith(
          primary: accent,
          secondary: const Color(0xFF2DD4BF),
          surface: surface,
          error: const Color(0xFFFB7185),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFF0B1524),
          hintStyle: const TextStyle(color: Color(0xFF64748B)),
          contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: border),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: accent, width: 1.4),
          ),
        ),
      ),
      home: const DashboardView(),
    );
  }
}
