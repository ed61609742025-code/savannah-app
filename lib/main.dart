import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'providers/app_state.dart';
import 'screens/main_navigation_shell.dart';
import 'theme/app_theme.dart';

import 'services/supabase_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Supabase (with fallback demo cloud mode)
  await SupabaseService().initialize();

  // Set system navigation & status bar colors for Serengeti Nocturne theme
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppTheme.surface,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AppState()),
        ChangeNotifierProvider(create: (_) => SupabaseService()),
      ],
      child: const SavannahApp(),
    ),
  );
}

class SavannahApp extends StatelessWidget {
  const SavannahApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Savannah • Wildlife Streaming & Conservation',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme(),
      home: const MainNavigationShell(),
    );
  }
}
