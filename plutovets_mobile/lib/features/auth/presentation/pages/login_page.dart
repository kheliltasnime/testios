import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme.dart';
import '../../../../core/router.dart';
import '../../../../core/constants.dart';
import '../../../../services/auth_service.dart';
import '../../../../services/api_auth_service.dart';
import '../../../../services/profile_service.dart';

class SimpleLoginScreen extends StatefulWidget {
  const SimpleLoginScreen({super.key});

  @override
  State<SimpleLoginScreen> createState() => _SimpleLoginScreenState();
}

class _SimpleLoginScreenState extends State<SimpleLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  bool _isLoading = false;
  bool _isGoogleLoading = false;
  String? _error;
  final AuthService _firebaseAuthService = AuthService();
  final ApiAuthService _apiAuthService = ApiAuthService(
    baseUrl: AppConstants.baseUrl,
  );
  final ProfileService _profileService = ProfileService(
    baseUrl: AppConstants.baseUrl,
  );

  Future<void> _handleLogin() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    final result = await _apiAuthService.login(
      _email.text.trim(),
      _password.text,
    );
    setState(() {
      _isLoading = false;
    });
    if (result['statusCode'] == 200 || result['statusCode'] == 201) {
      // Sauvegarder le token et les données utilisateur
      final prefs = await SharedPreferences.getInstance();
      final body = result['body'];

      await prefs.setString(
        AppConstants.storageTokenKey,
        body['tokens']['accessToken'],
      );
      await prefs.setString(
        AppConstants.storageRefreshTokenKey,
        body['tokens']['refreshToken'],
      );
      await prefs.setString(
        AppConstants.storageUserKey,
        jsonEncode(body['user']),
      );

      context.go(AppRouter.dashboard);
    } else {
      setState(() {
        _error = result['body']['error'] ?? 'Erreur de connexion';
      });
    }
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
      _error = null;
    });

    try {
      final user = await _firebaseAuthService.signInWithGoogle();

      if (user != null) {
        // Check if email exists in backend (not just local storage)
        final profileService = ProfileService(baseUrl: AppConstants.baseUrl);
        final emailExists = await profileService.checkEmailExists(
          user.email ?? '',
        );

        if (emailExists) {
          // Existing user - sync profile and go to dashboard
          await _profileService.syncGoogleProfile(
            uid: user.uid,
            email: user.email ?? '',
            displayName: user.displayName ?? '',
            photoURL: user.photoURL,
          );

          if (mounted) {
            context.go(AppRouter.dashboard);
          }
        } else {
          // New user - redirect to pet info page
          if (mounted) {
            context.go(AppRouter.googleSignupPetInfo, extra: user);
          }
        }
      } else {
        // Firebase failed - use mock authentication for testing
        final prefs = await SharedPreferences.getInstance();

        // Save token like classic login
        await prefs.setString(
          AppConstants.storageTokenKey,
          'mock_google_token_12345',
        );

        // Sync mock profile
        final profileResult = await _profileService.syncGoogleProfile(
          uid: 'mock_user_12345',
          email: 'test.user@gmail.com',
          displayName: 'Test User',
          photoURL: 'https://via.placeholder.com/150',
        );

        setState(() {
          _error = profileResult['message'] ?? 'Mock profile created';
        });

        // Still navigate to dashboard for testing
        await Future.delayed(const Duration(seconds: 2));
        if (mounted) {
          context.go(AppRouter.dashboard);
        }
      }
    } catch (e) {
      setState(() {
        _error = 'Google sign-in failed: ${e.toString()}';
      });
    }

    setState(() {
      _isGoogleLoading = false;
    });
  }

  Future<void> _handleGoogleSignUp() async {
    setState(() {
      _isGoogleLoading = true;
      _error = null;
    });

    try {
      final user = await _firebaseAuthService.signInWithGoogle();

      if (user != null) {
        // Check if email already exists before redirecting
        final profileService = ProfileService(baseUrl: AppConstants.baseUrl);
        final emailExists = await profileService.checkEmailExists(
          user.email ?? '',
        );

        if (emailExists) {
          setState(() {
            _error =
                'This email is already used. Please sign in with "Sign in with Google".';
          });
          // Stay on login page - don't redirect
          // Just show the error message and let user try "Sign in with Google"
        } else {
          // New user - redirect to pet info page for signup
          if (mounted) {
            context.go(AppRouter.googleSignupPetInfo, extra: user);
          }
        }
      } else {
        setState(() {
          _error = 'Google sign-up failed - please try again';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Google sign-up failed: ${e.toString()}';
      });
    }

    setState(() {
      _isGoogleLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.loginGradient),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(32.0),
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Logo et titre
                    Column(
                      children: [
                        // Logo moderne avec icônes vétérinaires
                        Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(25),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.1),
                                blurRadius: 20,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Stack(
                            children: [
                              Center(
                                child: Icon(
                                  Icons.pets,
                                  size: 50,
                                  color: AppTheme.primaryColor,
                                ),
                              ),
                              // Icônes stylisées pour représenter chiens et chats
                              Positioned(
                                top: 15,
                                left: 20,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: AppTheme.secondaryColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.home,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              Positioned(
                                bottom: 15,
                                right: 20,
                                child: Container(
                                  width: 20,
                                  height: 20,
                                  decoration: BoxDecoration(
                                    color: AppTheme.primaryColor,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Icon(
                                    Icons.favorite,
                                    size: 12,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Titre principal
                        Text(
                          'PlutoVets',
                          style: GoogleFonts.poppins(
                            fontSize: 32,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),

                        // Slogan
                        Text(
                          'Your trusted veterinary app',
                          style: GoogleFonts.poppins(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.9),
                            fontWeight: FontWeight.w400,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),

                    const SizedBox(height: 50),

                    // Formulaire de connexion
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 30,
                            offset: const Offset(0, 15),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Email field
                          TextFormField(
                            controller: _email,
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: AppTheme.primaryColor,
                              ),
                              filled: true,
                              fillColor: AppTheme.inputBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.primaryColor,
                                  width: 2,
                                ),
                              ),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your email';
                              }
                              if (!value.contains('@')) {
                                return 'Please enter a valid email';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Password field
                          TextFormField(
                            controller: _password,
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'Password',
                              labelStyle: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: AppTheme.primaryColor,
                              ),
                              filled: true,
                              fillColor: AppTheme.inputBackground,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.primaryColor.withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: AppTheme.primaryColor,
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Please enter your password';
                              }
                              if (value.length < 6) {
                                return 'Password must be at least 6 characters';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 12),

                          // Forgot password
                          Align(
                            alignment: Alignment.centerRight,
                            child: TextButton(
                              onPressed: () {
                                // TODO: Implement forgot password
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text('Feature coming soon!'),
                                  ),
                                );
                              },
                              child: Text(
                                'Forgot password?',
                                style: GoogleFonts.poppins(
                                  color: AppTheme.primaryColor,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),

                          const SizedBox(height: 30),

                          // Login button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading ? null : _handleLogin,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : Text(
                                      'Sign In',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),

                          // Error message
                          if (_error != null) ...[
                            const SizedBox(height: 16),
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.error.withOpacity(0.3),
                                ),
                              ),
                              child: SingleChildScrollView(
                                scrollDirection: Axis.horizontal,
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.error_outline,
                                      color: AppTheme.error,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 8),
                                    Flexible(
                                      child: Text(
                                        _error!,
                                        style: GoogleFonts.poppins(
                                          color: AppTheme.error,
                                          fontSize: 14,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Google Sign-In Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton.icon(
                        onPressed: _isGoogleLoading
                            ? null
                            : _handleGoogleSignIn,
                        icon: _isGoogleLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: AppTheme.primaryColor,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                Icons.login_rounded,
                                size: 20,
                                color: AppTheme.primaryColor,
                              ),
                        label: Text(
                          'Sign in with Google',
                          style: AppTheme.buttonStyle.copyWith(
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppTheme.primaryColor,
                          side: BorderSide(
                            color: AppTheme.primaryColor,
                            width: 2,
                          ),
                          elevation: 2,
                          shadowColor: AppTheme.primaryColor.withOpacity(0.2),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Google Sign-Up Button
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton.icon(
                        onPressed: _isGoogleLoading
                            ? null
                            : _handleGoogleSignUp,
                        icon: _isGoogleLoading
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                Icons.person_add_rounded,
                                size: 20,
                                color: Colors.white,
                              ),
                        label: Text(
                          'Sign up with Google',
                          style: AppTheme.buttonStyle,
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primaryColor,
                          foregroundColor: Colors.white,
                          elevation: 2,
                          shadowColor: AppTheme.primaryColor.withOpacity(0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 16,
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Sign up link
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Don't have an account? ",
                          style: GoogleFonts.poppins(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: 14,
                          ),
                        ),
                        TextButton(
                          onPressed: () {
                            context.go('/auth/register');
                          },
                          child: Text(
                            'Sign Up',
                            style: GoogleFonts.poppins(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              decoration: TextDecoration.underline,
                              decorationColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
