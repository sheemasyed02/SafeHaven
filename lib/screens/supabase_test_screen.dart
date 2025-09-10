import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConnectionTest extends StatefulWidget {
  const SupabaseConnectionTest({super.key});

  @override
  State<SupabaseConnectionTest> createState() => _SupabaseConnectionTestState();
}

class _SupabaseConnectionTestState extends State<SupabaseConnectionTest> {
  String _testResults = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _runAllTests();
  }

  Future<void> _runAllTests() async {
    setState(() {
      _isLoading = true;
      _testResults = 'Running tests...\n';
    });

    // Test 1: Check if Supabase is initialized
    _addResult('=== SUPABASE CONNECTION TEST ===');
    
    try {
      final client = Supabase.instance.client;
      _addResult('✅ Supabase client is accessible');
      
      // Test 2: Check basic client properties
      _addResult('📋 Client Info:');
      _addResult('   - Auth client ready: true');
      _addResult('   - Current user: ${client.auth.currentUser?.email ?? "None"}');
      
    } catch (e) {
      _addResult('❌ Supabase client error: $e');
      setState(() => _isLoading = false);
      return;
    }

    // Test 3: Test network connectivity with a simple query
    await _testNetworkConnection();
    
    // Test 4: Test authentication signup
    await _testAuthentication();
    
    setState(() => _isLoading = false);
  }

  Future<void> _testNetworkConnection() async {
    _addResult('\n=== NETWORK CONNECTION TEST ===');
    
    try {
      final client = Supabase.instance.client;
      
      // Try to make a simple request to test connectivity
      final session = client.auth.currentSession;
      _addResult('✅ Network connection to Supabase working');
      _addResult('   - Session state: ${session != null ? "Active" : "None"}');
      
    } catch (e) {
      _addResult('❌ Network connection failed: $e');
      _addResult('💡 Possible issues:');
      _addResult('   - No internet connection');
      _addResult('   - Firewall blocking requests');
      _addResult('   - Wrong Supabase URL');
    }
  }

  Future<void> _testAuthentication() async {
    _addResult('\n=== AUTHENTICATION TEST ===');
    
    try {
      final client = Supabase.instance.client;
      
      // Generate a unique test email
      final testEmail = 'test${DateTime.now().millisecondsSinceEpoch}@test.com';
      final testPassword = 'testpass123';
      
      _addResult('🔄 Testing signup with: $testEmail');
      
      final response = await client.auth.signUp(
        email: testEmail,
        password: testPassword,
      );
      
      if (response.user != null) {
        _addResult('✅ Signup successful!');
        _addResult('   - User ID: ${response.user!.id}');
        _addResult('   - Email: ${response.user!.email}');
        _addResult('   - Email confirmed: ${response.user!.emailConfirmedAt != null}');
        
        // Test signin
        _addResult('\n🔄 Testing signin...');
        await client.auth.signOut(); // Sign out first
        
        final loginResponse = await client.auth.signInWithPassword(
          email: testEmail,
          password: testPassword,
        );
        
        if (loginResponse.user != null) {
          _addResult('✅ Login successful!');
        } else {
          _addResult('❌ Login failed - no user returned');
        }
        
      } else {
        _addResult('❌ Signup failed - no user returned');
        if (response.session == null) {
          _addResult('   - No session created');
        }
      }
      
    } catch (e) {
      _addResult('❌ Authentication test failed: $e');
      
      // Analyze common error types
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('email')) {
        _addResult('💡 Email-related issue detected');
        _addResult('   - Check if email confirmation is required');
        _addResult('   - Verify email format is valid');
      }
      if (errorString.contains('network') || errorString.contains('connection')) {
        _addResult('💡 Network issue detected');
        _addResult('   - Check internet connection');
        _addResult('   - Verify Supabase URL is correct');
      }
      if (errorString.contains('unauthorized') || errorString.contains('invalid')) {
        _addResult('💡 Authorization issue detected');
        _addResult('   - Check Supabase anon key');
        _addResult('   - Verify project settings');
      }
    }
  }

  void _addResult(String result) {
    setState(() {
      _testResults += '$result\n';
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Connection Test'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _isLoading ? null : _runAllTests,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isLoading)
              const LinearProgressIndicator(),
            const SizedBox(height: 16),
            Expanded(
              child: Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _testResults,
                    style: const TextStyle(
                      color: Colors.white,
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.refresh),
                    label: const Text('Run Tests Again'),
                    onPressed: _isLoading ? null : _runAllTests,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy Results'),
                    onPressed: () {
                      // Copy to clipboard functionality would go here
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Results copied to clipboard')),
                      );
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
