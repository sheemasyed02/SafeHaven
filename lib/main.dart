import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'services/supabase_service.dart';
import 'utils/app_theme.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    // Initialize Supabase
    await Supabase.initialize(
      url: 'https://xuyzomlepudifwfbxmrl.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh1eXpvbWxlcHVkaWZ3ZmJ4bXJsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc0OTMwMjMsImV4cCI6MjA3MzA2OTAyM30.ST5z0h3iYmiTLcBrowYLj3_fnAKZ2lXDRBmxKNr9xxY',
    );

    // Initialize Supabase service
    SupabaseService.initialize();
    
    print('Supabase initialized successfully');
  } catch (e) {
    print('Error initializing Supabase: $e');
    // Continue anyway - we'll handle this in the app
  }

  runApp(const ProviderScope(child: SafeHavenApp()));
}



class SafeHavenApp extends ConsumerWidget {
  const SafeHavenApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    try {
      final router = ref.watch(routerProvider);

      return MaterialApp.router(
        title: 'SafeHaven',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        darkTheme: AppTheme.darkTheme,
        themeMode: ThemeMode.system,
        routerConfig: router,
      );
    } catch (e) {
      print('Error building app: $e');
      // Fallback UI
      return MaterialApp(
        title: 'SafeHaven',
        theme: AppTheme.lightTheme,
        home: Scaffold(
          appBar: AppBar(title: const Text('SafeHaven')),
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                const Text('App initialization failed'),
                const SizedBox(height: 8),
                Text('Error: $e'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    // Try to restart the app
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/',
                      (route) => false,
                    );
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          ),
        ),
      );
    }
  }
}
