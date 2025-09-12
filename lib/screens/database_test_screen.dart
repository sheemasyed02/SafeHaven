import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_provider.dart';
import '../services/supabase_service.dart';

class DatabaseTestScreen extends ConsumerStatefulWidget {
  const DatabaseTestScreen({super.key});

  @override
  ConsumerState<DatabaseTestScreen> createState() => _DatabaseTestScreenState();
}

class _DatabaseTestScreenState extends ConsumerState<DatabaseTestScreen> {
  List<String> _logs = [];
  bool _isLoading = false;

  void _addLog(String message) {
    setState(() {
      _logs.add('${DateTime.now().toLocal()}: $message');
    });
    print(message); // Also print to console
  }

  Future<void> _testDatabaseConnection() async {
    setState(() {
      _isLoading = true;
      _logs.clear();
    });

    try {
      _addLog('🔍 Testing database connection...');
      
      // Test 1: Check if we can connect to Supabase
      final client = SupabaseService.instance.client;
      _addLog('✅ Supabase client initialized');
      
      // Test 2: Check current user
      final user = ref.read(authProvider).user;
      if (user != null) {
        _addLog('✅ Current user: ${user.email} (ID: ${user.id})');
      } else {
        _addLog('❌ No authenticated user found');
        return;
      }
      
      // Test 3: Check RLS status
      _addLog('🔍 Checking Row Level Security status...');
      try {
        final rlsCheck = await client.rpc('check_rls_status');
        _addLog('📊 RLS Status: $rlsCheck');
      } catch (e) {
        _addLog('⚠️ Could not check RLS status: $e');
      }
      
      // Test 4: Test auth.uid() function
      _addLog('🔍 Testing auth.uid() function...');
      try {
        final authUidTest = await client.rpc('get_current_user_id');
        _addLog('🆔 auth.uid() returns: $authUidTest');
        if (authUidTest == user.id) {
          _addLog('✅ auth.uid() matches current user ID');
        } else {
          _addLog('❌ auth.uid() mismatch! Database sees: $authUidTest, App sees: ${user.id}');
        }
      } catch (e) {
        _addLog('⚠️ Could not test auth.uid(): $e');
      }
      
      // Test 5: Try to fetch user from users table
      _addLog('🔍 Testing users table access...');
      try {
        final userResponse = await client
            .from('users')
            .select('*')
            .eq('id', user.id)
            .maybeSingle();
        
        if (userResponse != null) {
          _addLog('✅ User found in users table: ${userResponse.toString()}');
          
          // Check what columns are available
          final columns = userResponse.keys.toList();
          _addLog('📋 Available columns: ${columns.join(', ')}');
          
          if (columns.contains('role')) {
            _addLog('✅ "role" column exists');
          } else {
            _addLog('❌ "role" column MISSING');
          }
          
          if (columns.contains('provider_type')) {
            _addLog('✅ "provider_type" column exists');
          } else {
            _addLog('❌ "provider_type" column MISSING');
          }
          
          if (columns.contains('name')) {
            _addLog('✅ "name" column exists');
          } else {
            _addLog('❌ "name" column MISSING (may be required)');
          }
          
        } else {
          _addLog('⚠️ User not found in users table, will try to create...');
          
          // Test 6: Try to create user record
          try {
            await client.from('users').upsert({
              'id': user.id,
              'email': user.email,
              'name': user.email.split('@')[0], // Use email prefix as default name
              'created_at': DateTime.now().toIso8601String(),
            });
            _addLog('✅ User record created in users table');
          } catch (e) {
            _addLog('❌ Failed to create user record: $e');
            if (e.toString().contains('23502') || e.toString().contains('not-null constraint')) {
              _addLog('🔍 NOT-NULL CONSTRAINT: Your users table has required fields missing');
              _addLog('📖 Check USERS_TABLE_FIX.md for column requirements');
            } else if (e.toString().contains('42501') || e.toString().contains('row-level security')) {
              _addLog('🔒 RLS POLICY ISSUE: Check RLS_POLICY_FIX.md for solution');
            }
          }
        }
      } catch (e) {
        _addLog('❌ Failed to access users table: $e');
        if (e.toString().contains('42501') || e.toString().contains('row-level security')) {
          _addLog('🔒 RLS POLICY ISSUE: Check RLS_POLICY_FIX.md for solution');
        }
      }
      
      // Test 7: Try to update role (the actual failing operation)
      _addLog('🔍 Testing role update (this is the failing operation)...');
      try {
        final updateResponse = await client
            .from('users')
            .update({'role': 'test_role'})
            .eq('id', user.id)
            .select();
        
        if (updateResponse.isNotEmpty) {
          _addLog('✅ Role update successful: ${updateResponse.toString()}');
          
          // Reset role to null
          await client
              .from('users')
              .update({'role': null})
              .eq('id', user.id);
          _addLog('✅ Role reset to null');
        } else {
          _addLog('❌ Role update failed - no response');
        }
      } catch (e) {
        _addLog('❌ Role update failed with error: $e');
        if (e.toString().contains('column') && e.toString().contains('does not exist')) {
          _addLog('🛠️ SOLUTION: Your users table is missing the "role" column!');
          _addLog('📖 Check DATABASE_DIAGNOSTIC.md for setup instructions');
        } else if (e.toString().contains('42501') || e.toString().contains('row-level security')) {
          _addLog('🔒 RLS POLICY ISSUE: Check RLS_POLICY_FIX.md for complete solution');
          _addLog('💡 Quick fix: Run the "Complete Setup Script" in RLS_POLICY_FIX.md');
        }
      }
      
      // Test 8: Try provider_type update
      _addLog('🔍 Testing provider_type update...');
      try {
        await client
            .from('users')
            .update({'provider_type': 'test_type'})
            .eq('id', user.id);
        _addLog('✅ Provider type update successful');
        
        // Reset provider_type to null
        await client
            .from('users')
            .update({'provider_type': null})
            .eq('id', user.id);
        _addLog('✅ Provider type reset to null');
      } catch (e) {
        _addLog('❌ Provider type update failed: $e');
        if (e.toString().contains('column') && e.toString().contains('does not exist')) {
          _addLog('🛠️ SOLUTION: Your users table is missing the "provider_type" column!');
          _addLog('📖 Check DATABASE_DIAGNOSTIC.md for setup instructions');
        } else if (e.toString().contains('42501') || e.toString().contains('row-level security')) {
          _addLog('🔒 RLS POLICY ISSUE: Check RLS_POLICY_FIX.md for complete solution');
        }
      }
      
      _addLog('🎉 Database connection test completed!');
      
    } catch (e) {
      _addLog('❌ Database test failed: $e');
      if (e.toString().contains('42501') || e.toString().contains('row-level security')) {
        _addLog('🔒 MAIN ISSUE: Row Level Security policy blocking access');
        _addLog('📖 SOLUTION: Check RLS_POLICY_FIX.md file for complete fix');
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _testUserRoleUpdate() async {
    final user = ref.read(authProvider).user;
    if (user == null) {
      _addLog('❌ No user to test with');
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      _addLog('Testing updateUserRole method...');
      await ref.read(authProvider.notifier).updateUserRole('customer');
      _addLog('✅ updateUserRole completed successfully');
      
      // Check if the update worked
      final updatedState = ref.read(authProvider);
      _addLog('Updated user role: ${updatedState.user?.role}');
      
    } catch (e) {
      _addLog('❌ updateUserRole failed: $e');
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
        title: const Text('Database Test'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Database Connection Test',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testDatabaseConnection,
                    child: const Text('Test Database'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _testUserRoleUpdate,
                    child: const Text('Test Role Update'),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 16),
            
            if (_isLoading)
              const Center(child: CircularProgressIndicator()),
            
            const Text(
              'Test Results:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[50],
                ),
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _logs.map((log) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        log,
                        style: TextStyle(
                          fontFamily: 'monospace',
                          fontSize: 12,
                          color: log.contains('❌') ? Colors.red :
                                 log.contains('✅') ? Colors.green :
                                 log.contains('⚠️') ? Colors.orange :
                                 Colors.black,
                        ),
                      ),
                    )).toList(),
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Quick Fix Instructions:',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '🔒 ROW LEVEL SECURITY (RLS) ERROR FIX:',
                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.red),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '1. Open Supabase Dashboard → Database → SQL Editor\n'
                    '2. Copy and run the "Complete Setup Script" from RLS_POLICY_FIX.md\n'
                    '3. This fixes the "violates row-level security policy" error\n'
                    '4. Run "Test Database" again to verify the fix\n'
                    '5. Try role selection in your app - should work now!',
                    style: TextStyle(fontSize: 12),
                  ),
                  SizedBox(height: 8),
                  Text(
                    '📋 OTHER ISSUES:',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '• Missing columns → Run commands from DATABASE_DIAGNOSTIC.md\n'
                    '• Connection issues → Check Supabase URL/keys in main.dart',
                    style: TextStyle(fontSize: 12),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
