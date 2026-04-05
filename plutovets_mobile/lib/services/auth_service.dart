import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Sign in with Google using popup (web)
  Future<User?> signInWithGoogle() async {
    try {
      // Create a GoogleAuthProvider
      final GoogleAuthProvider googleProvider = GoogleAuthProvider();

      // Add scopes if needed
      googleProvider.addScope('email');
      googleProvider.addScope('profile');

      // Sign in with popup (correct method for web)
      final UserCredential userCredential = await _auth.signInWithPopup(
        googleProvider,
      );

      return userCredential.user;
    } catch (e) {
      developer.log('Google Sign-In Error: $e');

      // If Firebase fails, create a mock user for testing
      if (e.toString().contains('api-key-not-valid') ||
          e.toString().contains('not implemented') ||
          e.toString().contains('signInWithProvider')) {
        developer.log(
          'Firebase method not available - using mock user for testing',
        );
        // Return null to trigger fallback handling
        return null;
      }

      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      developer.log('Sign Out Error: $e');
      // Continue even if sign out fails
    }
  }

  // Get auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;
}
