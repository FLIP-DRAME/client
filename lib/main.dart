import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'app_router.dart';
import 'common/drame_text_styles.dart';
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
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'DRAME',
      routerConfig: appRouter,
      theme: ThemeData(
        fontFamily: DrameTextStyles.fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.black,
          primary: Colors.black,
          secondary: Colors.black,
        ),
        focusColor: const Color(0xFFE5E7EB),
        textSelectionTheme: const TextSelectionThemeData(
          cursorColor: Color(0xFFE5E7EB),
          selectionHandleColor: Color(0xFFE5E7EB),
        ),
        filledButtonTheme: FilledButtonThemeData(
          style: FilledButton.styleFrom(
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          ),
        ),
        useMaterial3: true,
      ),
    );
  }
}
//연습용
