import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'feat/main/ui/pages/main_page.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => DrameStore(),
      child: const DrameApp(),
    ),
  );
}

class DrameApp extends StatelessWidget {
  const DrameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DRAME',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          primary: const Color(0xFF111827),
          secondary: const Color(0xFFB7F36B),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: const Color(0xFF111827),
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),
        useMaterial3: true,
      ),
      home: const DrameHomePage(),
    );
  }
}
