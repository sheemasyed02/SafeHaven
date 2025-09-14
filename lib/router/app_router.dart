import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../models/user_profile.dart';
import '../services/supabase_service.dart';
import '../screens/home/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/register_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/user/profile_screen.dart';
import '../screens/dashboard/customer_dashboard_screen.dart';
import '../screens/dashboard/provider_dashboard_screen.dart';
import '../screens/provider/provider_registration_screen.dart';
import '../screens/customer/customer_browse_screen.dart';
import '../screens/customer/booking_screen.dart';

// Enhanced router with role-based authentication
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authStateProvider);
  
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) async {
      final user = authState.user;
      final isLoginRoute = state.matchedLocation == '/login';
      final isRegisterRoute = state.matchedLocation == '/register';
      final isSplashRoute = state.matchedLocation == '/';
      final isHomeRoute = state.matchedLocation == '/home';

      // If not authenticated and trying to access protected route
      if (user == null && !isLoginRoute && !isRegisterRoute && !isSplashRoute && !isHomeRoute) {
        return '/login';
      }

      // If authenticated and on auth/splash routes, redirect to appropriate dashboard
      if (user != null && (isLoginRoute || isRegisterRoute || isSplashRoute)) {
        try {
          final profile = await SupabaseService.instance.getCurrentUserProfile();
          if (profile != null) {
            // Use current mode for routing
            switch (profile.currentMode) {
              case UserRole.customer:
                return '/customer-dashboard';
              case UserRole.provider:
                return '/provider-dashboard';
            }
          }
          // If no profile or error, go to home to let user set up profile
          return '/home';
        } catch (e) {
          // If profile fetch fails, go to home
          return '/home';
        }
      }

      return null; // No redirect needed
    },
    routes: [
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/register',
        name: 'register',
        builder: (context, state) => const RegisterScreen(),
      ),
      GoRoute(
        path: '/home',
        name: 'home',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/customer-dashboard',
        name: 'customer-dashboard',
        builder: (context, state) => const RoleGuard(
          allowedRole: UserRole.customer,
          child: CustomerDashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/provider-dashboard',
        name: 'provider-dashboard',
        builder: (context, state) => const RoleGuard(
          allowedRole: UserRole.provider,
          child: ProviderDashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/profile',
        name: 'profile',
        builder: (context, state) => const AuthGuard(
          child: ProfileScreen(),
        ),
      ),
      GoRoute(
        path: '/provider-registration',
        name: 'provider-registration',
        builder: (context, state) {
          final userProfile = state.extra as UserProfile?;
          if (userProfile == null) {
            return const Scaffold(
              body: Center(
                child: Text('Invalid access to provider registration'),
              ),
            );
          }
          return AuthGuard(
            child: ProviderRegistrationScreen(userProfile: userProfile),
          );
        },
      ),
      GoRoute(
        path: '/customer-browse',
        name: 'customer-browse',
        builder: (context, state) => const RoleGuard(
          allowedRole: UserRole.customer,
          child: CustomerBrowseScreen(),
        ),
      ),
      GoRoute(
        path: '/booking',
        name: 'booking',
        builder: (context, state) {
          final provider = state.extra as UserProfile?;
          if (provider == null) {
            return const Scaffold(
              body: Center(
                child: Text('Invalid access to booking'),
              ),
            );
          }
          return RoleGuard(
            allowedRole: UserRole.customer,
            child: BookingScreen(provider: provider),
          );
        },
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      appBar: AppBar(title: const Text('Page Not Found')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text('Page Not Found', style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('The page "${state.matchedLocation}" was not found.'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => context.go('/'),
              child: const Text('Go Home'),
            ),
          ],
        ),
      ),
    ),
  );
});

// Guard widget that ensures user is authenticated
class AuthGuard extends ConsumerWidget {
  final Widget child;

  const AuthGuard({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    if (authState.user == null) {
      // User not authenticated, show login screen
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return child;
  }
}

// Guard widget that ensures user has the correct role
class RoleGuard extends ConsumerWidget {
  final UserRole allowedRole;
  final Widget child;

  const RoleGuard({
    super.key,
    required this.allowedRole,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    final profileAsync = ref.watch(currentUserProfileProvider);

    // Check if user is authenticated
    if (authState.user == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        context.go('/login');
      });
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return profileAsync.when(
      data: (profile) {
        if (profile == null) {
          // Profile not found, redirect to login
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go('/login');
          });
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (profile.currentMode != allowedRole) {
          // Wrong role, redirect to appropriate dashboard
          WidgetsBinding.instance.addPostFrameCallback((_) {
            switch (profile.currentMode) {
              case UserRole.customer:
                context.go('/customer-dashboard');
                break;
              case UserRole.provider:
                context.go('/provider-dashboard');
                break;
            }
          });
          
          return Scaffold(
            body: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.lock_outline, size: 64, color: Colors.orange),
                  const SizedBox(height: 16),
                  Text(
                    'Access Denied',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  const Text('Redirecting to your dashboard...'),
                  const SizedBox(height: 16),
                  const CircularProgressIndicator(),
                ],
              ),
            ),
          );
        }

        // User has correct role, show the protected content
        return child;
      },
      loading: () => const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Loading...'),
            ],
          ),
        ),
      ),
      error: (error, stackTrace) {
        // Error loading profile, redirect to login
        WidgetsBinding.instance.addPostFrameCallback((_) {
          context.go('/login');
        });
        return Scaffold(
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(
                  'Error Loading Profile',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('Error: $error'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/login'),
                  child: const Text('Go to Login'),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}