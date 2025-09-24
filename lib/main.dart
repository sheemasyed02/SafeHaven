import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_service.dart';
import 'utils/app_theme.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Supabase.initialize(
      url: 'https://xuyzomlepudifwfbxmrl.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh1eXpvbWxlcHVkaWZ3ZmJ4bXJsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc0OTMwMjMsImV4cCI6MjA3MzA2OTAyM30.ST5z0h3iYmiTLcBrowYLj3_fnAKZ2lXDRBmxKNr9xxY',
    );

    // Initialize Supabase service
    SupabaseService.initialize();
  } catch (e) {
    // Continue anyway - we'll handle this in the app
  }

  runApp(const ProviderScope(child: SafeHavenApp()));
}



class SafeHavenApp extends ConsumerWidget {
  const SafeHavenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'SafeHaven',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      routerConfig: router,
    );
  }
}

