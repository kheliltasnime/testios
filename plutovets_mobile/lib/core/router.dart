import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../features/splash/presentation/pages/splash_page.dart';
import '../features/onboarding/presentation/pages/onboarding_page.dart';
import '../features/auth/presentation/pages/auth_page.dart';
import '../features/auth/presentation/pages/login_page.dart';
import '../features/auth/presentation/pages/register_page.dart';
import '../features/auth/presentation/pages/forgot_password_page.dart';
import '../features/auth/presentation/pages/google_signup_pet_info_page.dart';
import '../features/dashboard/presentation/pages/dashboard_page.dart';
import '../features/pets/presentation/pages/pets_page.dart';
import '../features/pets/presentation/pages/pet_details_page.dart';
import '../features/pets/presentation/pages/add_pet_page.dart';
import '../features/bookings/presentation/pages/bookings_page.dart';
import '../features/bookings/presentation/pages/booking_details_page.dart';
import '../features/bookings/presentation/pages/create_booking_page.dart';
import '../features/profile/presentation/pages/profile_page.dart';
import '../features/notifications/presentation/pages/notifications_page.dart';
import '../shell/presentation/widgets/main_navigation_shell.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppRouter {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String auth = '/auth';
  static const String login = 'login';
  static const String register = 'register';
  static const String forgotPassword = '/auth/forgot-password';

  static const String dashboard = '/dashboard';
  static const String googleSignupPetInfo = '/google-signup-pet-info';
  static const String pets = '/pets';
  static const String petDetails = ':petId';
  static const String addPet = 'add';
  static const String editPet = ':petId/edit';

  static const String bookings = '/bookings';
  static const String bookingDetails = ':bookingId';
  static const String createBooking = 'create';
  static const String editBooking = ':bookingId/edit';

  static const String profile = '/profile';
  static const String notifications = '/notifications';
  static const String settings = '/settings';
  static const String about = '/about';

  static final GoRouter router = GoRouter(
    initialLocation: dashboard,
    debugLogDiagnostics: true,
    routes: [
      GoRoute(
        path: splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: onboarding,
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: auth,
        name: 'auth',
        builder: (context, state) => const AuthScreen(),
        routes: [
          GoRoute(
            path: login,
            name: 'login',
            builder: (context, state) => const SimpleLoginScreen(),
          ),
          GoRoute(
            path: register,
            name: 'register',
            builder: (context, state) => const RegisterScreenImproved(),
          ),
        ],
      ),
      GoRoute(
        path: forgotPassword,
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: googleSignupPetInfo,
        name: 'google-signup-pet-info',
        builder: (context, state) {
          final user = state.extra as User;
          return GoogleSignupPetInfoPage(user: user);
        },
      ),
      GoRoute(
        path: dashboard,
        name: 'dashboard',
        builder: (context, state) =>
            const MainNavigation(child: DashboardScreen()),
      ),
      GoRoute(
        path: pets,
        name: 'pets',
        builder: (context, state) => const MainNavigation(child: PetsScreen()),
        routes: [
          GoRoute(
            path: 'add',
            name: 'add-pet',
            builder: (context, state) =>
                const MainNavigation(child: AddPetScreen()),
          ),
          GoRoute(
            path: ':petId',
            name: 'pet-details',
            builder: (context, state) {
              final petId = state.pathParameters['petId']!;
              return MainNavigation(child: PetDetailsScreen(petId: petId));
            },
          ),
          GoRoute(
            path: ':petId/edit',
            name: 'edit-pet',
            builder: (context, state) {
              final petId = state.pathParameters['petId']!;
              return MainNavigation(child: AddPetScreen(petId: petId));
            },
          ),
        ],
      ),
      GoRoute(
        path: bookings,
        name: 'bookings',
        builder: (context, state) =>
            const MainNavigation(child: BookingsScreen()),
        routes: [
          GoRoute(
            path: 'create',
            name: 'create-booking',
            builder: (context, state) {
              final petId = state.uri.queryParameters['petId'];
              final serviceId = state.uri.queryParameters['serviceId'];
              return CreateBookingScreen(petId: petId, serviceId: serviceId);
            },
          ),
          GoRoute(
            path: ':bookingId',
            name: 'booking-details',
            builder: (context, state) {
              final bookingId = state.pathParameters['bookingId']!;
              return MainNavigation(
                child: BookingDetailsScreen(bookingId: bookingId),
              );
            },
          ),
          GoRoute(
            path: ':bookingId/edit',
            name: 'edit-booking',
            builder: (context, state) {
              final bookingId = state.pathParameters['bookingId']!;
              return MainNavigation(
                child: CreateBookingScreen(bookingId: bookingId),
              );
            },
          ),
        ],
      ),
      GoRoute(
        path: profile,
        name: 'profile',
        builder: (context, state) =>
            const MainNavigation(child: ProfileScreen()),
      ),
      GoRoute(
        path: notifications,
        name: 'notifications',
        builder: (context, state) =>
            const MainNavigation(child: NotificationsScreen()),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Page non trouvée',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'La page que vous recherchez n\'existe pas.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => context.go(dashboard),
              child: const Text('Retour à l\'accueil'),
            ),
          ],
        ),
      ),
    ),
    redirect: (context, state) {
      // For now, let's bypass authentication and allow access to all routes
      // TODO: Implement proper authentication check when BLoC is ready
      return null;
    },
  );

  static void navigateToLogin(BuildContext context) {
    context.go(login);
  }

  static void navigateToRegister(BuildContext context) {
    context.go(register);
  }

  static void navigateToDashboard(BuildContext context) {
    context.go(dashboard);
  }

  static void navigateToPets(BuildContext context) {
    context.go(pets);
  }

  static void navigateToPetDetails(BuildContext context, String petId) {
    context.go('/pets/$petId');
  }

  static void navigateToAddPet(BuildContext context) {
    context.go('/pets/add');
  }

  static void navigateToEditPet(BuildContext context, String petId) {
    context.go('/pets/$petId/edit');
  }

  static void navigateToBookings(BuildContext context) {
    context.go(bookings);
  }

  static void navigateToBookingDetails(BuildContext context, String bookingId) {
    context.go('/bookings/$bookingId');
  }

  static void navigateToCreateBooking(
    BuildContext context, {
    String? petId,
    String? serviceId,
  }) {
    final queryParams = <String, String>{};
    if (petId != null) queryParams['petId'] = petId;
    if (serviceId != null) queryParams['serviceId'] = serviceId;

    context.go('/bookings/create', extra: queryParams);
  }

  static void navigateToProfile(BuildContext context) {
    context.go(profile);
  }

  static void navigateToNotifications(BuildContext context) {
    context.go(notifications);
  }

  static void navigateToForgotPassword(BuildContext context) {
    context.go(forgotPassword);
  }

  static void navigateBack(BuildContext context) {
    context.pop();
  }
}
