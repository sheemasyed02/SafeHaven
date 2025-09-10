import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupabaseConfigChecker extends StatefulWidget {
  const SupabaseConfigChecker({super.key});

  @override
  State<SupabaseConfigChecker> createState() => _SupabaseConfigCheckerState();
}

class _SupabaseConfigCheckerState extends State<SupabaseConfigChecker> {
  final _emailController = TextEditingController(text: 'test@example.com');
  final _passwordController = TextEditingController(text: 'password123');
  String _output = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _checkConfiguration();
  }

  void _addOutput(String message) {
    setState(() {
      _output += '$message\n';
    });
    print(message); // Also print to console
  }

  void _clearOutput() {
    setState(() {
      _output = '';
    });
  }

  Future<void> _checkConfiguration() async {
    _clearOutput();
    _addOutput('=== SUPABASE CONFIGURATION CHECK ===');
    _addOutput('Time: ${DateTime.now()}');
    
    try {
      final client = Supabase.instance.client;
      _addOutput('✅ Supabase client initialized');
      
      // Check current session
      final session = client.auth.currentSession;
      _addOutput('Current session: ${session != null ? "Active" : "None"}');
      
      final user = client.auth.currentUser;
      _addOutput('Current user: ${user?.email ?? "None"}');
      
    } catch (e) {
      _addOutput('❌ Configuration error: $e');
    }
  }

  Future<void> _testSignup() async {
    if (_isLoading) return;
    
    setState(() => _isLoading = true);
    
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    _addOutput('\n=== TESTING SIGNUP ===');
    _addOutput('Email: $email');
    _addOutput('Password: ${password.replaceAll(RegExp('.'), '*')}');
    
    try {
      final client = Supabase.instance.client;
      
      _addOutput('🔄 Attempting signup...');
      
      final response = await client.auth.signUp(
        email: email,
        password: password,
      );
      
      _addOutput('\n📋 SIGNUP RESPONSE:');
      _addOutput('User: ${response.user != null ? "✅ Created" : "❌ Null"}');
      
      if (response.user != null) {
        final user = response.user!;
        _addOutput('User ID: ${user.id}');
        _addOutput('Email: ${user.email}');
        _addOutput('Email confirmed: ${user.emailConfirmedAt != null}');
        _addOutput('Phone confirmed: ${user.phoneConfirmedAt != null}');
        _addOutput('Created at: ${user.createdAt}');
        _addOutput('Last sign in: ${user.lastSignInAt ?? "Never"}');
      }
      
      _addOutput('Session: ${response.session != null ? "✅ Created" : "❌ Null"}');
      
      if (response.session != null) {
        _addOutput('Access token: ${response.session!.accessToken.substring(0, 20)}...');
      }
      
      // Check for common issues
      if (response.user != null && response.user!.emailConfirmedAt == null) {
        _addOutput('\n⚠️  EMAIL NOT CONFIRMED!');
        _addOutput('This user exists but email is not confirmed.');
        _addOutput('Solutions:');
        _addOutput('1. Disable email confirmation in Supabase settings');
        _addOutput('2. Or confirm email manually in Supabase dashboard');
        _addOutput('3. Or set up email delivery in Supabase');
      }
      
    } catch (e) {
      _addOutput('\n❌ SIGNUP FAILED: $e');
      
      // Analyze error
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('duplicate') || errorStr.contains('already')) {
        _addOutput('\n💡 USER ALREADY EXISTS!');
        _addOutput('Try signing in instead, or use a different email.');
        
        // Test signin
        await _testSignin();
      } else if (errorStr.contains('invalid') && errorStr.contains('email')) {
        _addOutput('\n💡 EMAIL FORMAT ISSUE!');
        _addOutput('Check email format and try again.');
      } else if (errorStr.contains('weak') || errorStr.contains('password')) {
        _addOutput('\n💡 PASSWORD ISSUE!');
        _addOutput('Password might be too weak or not meet requirements.');
      } else if (errorStr.contains('network') || errorStr.contains('connection')) {
        _addOutput('\n💡 NETWORK ISSUE!');
        _addOutput('Check internet connection and Supabase URL.');
      }
    }
    
    setState(() => _isLoading = false);
  }

  Future<void> _testSignin() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    
    _addOutput('\n=== TESTING SIGNIN ===');
    _addOutput('🔄 Attempting signin...');
    
    try {
      final client = Supabase.instance.client;
      
      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );
      
      _addOutput('\n📋 SIGNIN RESPONSE:');
      _addOutput('User: ${response.user != null ? "✅ Found" : "❌ Null"}');
      
      if (response.user != null) {
        _addOutput('Login successful! User authenticated.');
      }
      
    } catch (e) {
      _addOutput('\n❌ SIGNIN FAILED: $e');
      
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('invalid') && errorStr.contains('credentials')) {
        _addOutput('\n💡 WRONG CREDENTIALS!');
        _addOutput('Email or password is incorrect.');
      } else if (errorStr.contains('email') && errorStr.contains('confirm')) {
        _addOutput('\n💡 EMAIL NOT CONFIRMED!');
        _addOutput('User exists but email needs confirmation.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Supabase Config Checker'),
        actions: [
          IconButton(
            icon: const Icon(Icons.copy),
            onPressed: () {
              Clipboard.setData(ClipboardData(text: _output));
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Output copied to clipboard')),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Input section
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _emailController,
                  decoration: const InputDecoration(
                    labelText: 'Test Email',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 8),
                TextField(
                  controller: _passwordController,
                  decoration: const InputDecoration(
                    labelText: 'Test Password',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _testSignup,
                        child: _isLoading 
                          ? const SizedBox(
                              height: 16,
                              width: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Text('Test Signup'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _testSignin,
                        child: const Text('Test Signin'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    ElevatedButton(
                      onPressed: _checkConfiguration,
                      child: const Icon(Icons.refresh),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Output section
          Expanded(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.black87,
                borderRadius: BorderRadius.circular(8),
              ),
              child: SingleChildScrollView(
                child: SelectableText(
                  _output.isEmpty ? 'Output will appear here...' : _output,
                  style: const TextStyle(
                    color: Colors.white,
                    fontFamily: 'monospace',
                    fontSize: 12,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
}
