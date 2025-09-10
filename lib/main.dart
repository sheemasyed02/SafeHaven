import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'widgets/auth_wrapper.dart';
import 'services/map_service.dart';
import 'services/supabase_service.dart';
// import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize services
  await _initializeServices();
  
  runApp(
    const ProviderScope(
      child: SafeHavenApp(),
    ),
  );
}

Future<void> _initializeServices() async {
  try {
    print('Initializing Supabase...'); // Debug logging
    await SupabaseService.instance.initialize(
      url: 'https://xuyzomlepudifwfbxmrl.supabase.co',
      anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Inh1eXpvbWxlcHVkaWZ3ZmJ4bXJsIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NTc0OTMwMjMsImV4cCI6MjA3MzA2OTAyM30.ST5z0h3iYmiTLcBrowYLj3_fnAKZ2lXDRBmxKNr9xxY',
    );
    print('Supabase initialized successfully'); // Debug logging

    // TODO: Replace with your actual OneSignal App ID
    // await NotificationService.instance.initialize('49783777-40d1-4d08-8b7f-1a503d3aab64');

    // Initialize map service
    MapService.instance.initializeController();
    print('All services initialized'); // Debug logging
  } catch (e) {
    print('Error initializing services: $e'); // Debug logging
    rethrow;
  }
}

class SafeHavenApp extends StatelessWidget {
  const SafeHavenApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SafeHaven',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 179, 179, 86),
          brightness: Brightness.light,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      darkTheme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color.fromARGB(255, 192, 209, 100),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const AuthWrapper(),
      debugShowCheckedModeBanner: false,
    );
  }
}
