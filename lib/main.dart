import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app_router.dart';
import 'common/drame_text_styles.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load();
  await Supabase.initialize(
    url: dotenv.env['SUPABASE_URL']!,
    anonKey: dotenv.env['SUPABASE_PUBLISHABLE_KEY']!,
  );
  runApp(const ProviderScope(child: DrameApp()));
}

class DrameApp extends StatelessWidget {
  const DrameApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: '모두의 드론',
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
