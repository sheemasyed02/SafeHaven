import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/supabase_service.dart';

class DebugScreen extends ConsumerStatefulWidget {
  const DebugScreen({super.key});

  @override
  ConsumerState<DebugScreen> createState() => _DebugScreenState();
}

class _DebugScreenState extends ConsumerState<DebugScreen> {
  String _debugInfo = 'No info yet';
  bool _isLoading = false;

  void _testSupabaseConnection() async {
    setState(() {
      _isLoading = true;
      _debugInfo = 'Testing connection...';
    });

    try {
      final supabase = SupabaseService.instance;
      final client = supabase.client;
      
      // Test basic connection
      setState(() {
        _debugInfo = '''
Connection Test:
Auth State: ${supabase.isAuthenticated}
Current User: ${supabase.currentUser?.email ?? 'None'}
Client Initialized: ${client.auth.currentUser != null ? 'Yes' : 'No'}
''';
      });
    } catch (e) {
      setState(() {
        _debugInfo = 'Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _testSignUp() async {
    setState(() {
      _isLoading = true;
      _debugInfo = 'Testing signup...';
    });

    try {
      final supabase = SupabaseService.instance;
      final response = await supabase.signUp(
        email: 'test@example.com',
        password: 'testpassword123',
      );
      
      setState(() {
        _debugInfo = '''
Signup Test:
Success: ${response.user != null}
User ID: ${response.user?.id ?? 'None'}
Email: ${response.user?.email ?? 'None'}
Error: ${response.user == null ? 'User is null' : 'None'}
''';
      });
    } catch (e) {
      setState(() {
        _debugInfo = 'Signup Error: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Debug Supabase'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              onPressed: _isLoading ? null : _testSupabaseConnection,
              child: const Text('Test Connection'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _isLoading ? null : _testSignUp,
              child: const Text('Test Signup'),
            ),
            const SizedBox(height: 16),
            if (_isLoading)
              const Center(child: CircularProgressIndicator())
            else
              Expanded(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: SingleChildScrollView(
                    child: Text(
                      _debugInfo,
                      style: const TextStyle(fontFamily: 'monospace'),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
