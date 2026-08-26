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
    return MaterialApp(
      title: 'CoolNet AI - Compound Heat–Grid Intelligence',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF020617),
        cardColor: const Color(0xFF0F172A),
        textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF38BDF8),
          secondary: Color(0xFFA855F7),
          surface: Color(0xFF0F172A),
          error: Color(0xFFEF4444),
        ),
      ),
      home: const DashboardView(),
    );
  }
}
