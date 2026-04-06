import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../core/theme.dart';
import '../../../../core/router.dart';
import '../../../../core/constants.dart';
import '../../../../services/profile_service.dart';
import '../../../../services/pet_service.dart';

class GoogleSignupPetInfoPage extends StatefulWidget {
  final User user;

  const GoogleSignupPetInfoPage({super.key, required this.user});

  @override
  State<GoogleSignupPetInfoPage> createState() =>
      _GoogleSignupPetInfoPageState();
}

class _GoogleSignupPetInfoPageState extends State<GoogleSignupPetInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _petNameController = TextEditingController();
  final _petAgeController = TextEditingController();
  final _petBreedController = TextEditingController();
  final _petTypeController = TextEditingController();

  String _selectedPetType = 'Chien';
  bool _isLoading = false;
  String? _error;

  final List<String> _petTypes = [
    'Chien',
    'Chat',
    'Lapin',
    'Oiseau',
    'Poisson',
    'Autre',
  ];

  @override
  void dispose() {
    _petNameController.dispose();
    _petAgeController.dispose();
    _petBreedController.dispose();
    _petTypeController.dispose();
    super.dispose();
  }

  Future<void> _handleCompleteSignup() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final profileService = ProfileService(baseUrl: AppConstants.baseUrl);

      // 1. Check if email already exists (prevent duplicate signup)
      final emailExists = await profileService.checkEmailExists(
        widget.user.email ?? '',
      );

      if (emailExists) {
        setState(() {
          _error =
              'Cet email est déjà utilisé. Veuillez vous connecter avec "Sign in with Google".';
        });

        // Redirect to login after showing error
        await Future.delayed(const Duration(seconds: 3));
        if (mounted) {
          context.go(AppRouter.login);
        }
        return;
      }

      // 2. Sync Google profile (this will create backend token)
      final profileResult = await profileService.syncGoogleProfile(
        uid: widget.user.uid,
        email: widget.user.email ?? '',
        displayName: widget.user.displayName ?? '',
        photoURL: widget.user.photoURL,
      );

      // 2. Create pet information and sync with backend
      final petData = {
        'name': _petNameController.text.trim(),
        'species': _selectedPetType
            .toLowerCase(), // Changed from 'type' to 'species'
        'age': _petAgeController.text.trim(),
        'breed': _petBreedController.text.trim(),
        'ownerId': widget.user.uid,
        'createdAt': DateTime.now().toIso8601String(),
      };

      // 3. Use PetService to create pet
      final petService = PetService(baseUrl: AppConstants.baseUrl);
      final petResult = await petService.createPet(petData);

      if (petResult['success']) {
        // Pet created successfully on backend
        await petService.savePetLocally(petResult['pet']);

        setState(() {
          _error = 'Animal créé avec succès!';
        });
      } else {
        // Save locally if backend fails
        await petService.savePetLocally(petData);

        setState(() {
          _error =
              'Animal sauvegardé localement (erreur: ${petResult['error']})';
        });
      }

      // 4. Mark signup as complete
      await prefs.setBool('googleSignupComplete', true);

      // 5. Navigate to dashboard after a short delay to show success message
      await Future.delayed(const Duration(seconds: 2));
      if (mounted) {
        context.go(AppRouter.dashboard);
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur lors de l\'inscription: ${e.toString()}';
      });
    }

    setState(() {
      _isLoading = false;
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
                    // User info card
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.9),
                        borderRadius: BorderRadius.circular(15),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: const Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          // User avatar
                          CircleAvatar(
                            radius: 30,
                            backgroundImage: widget.user.photoURL != null
                                ? NetworkImage(widget.user.photoURL!)
                                : null,
                            child: widget.user.photoURL == null
                                ? Icon(
                                    Icons.person,
                                    size: 30,
                                    color: AppTheme.primaryColor,
                                  )
                                : null,
                          ),
                          const SizedBox(width: 16),
                          // User info
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Bienvenue!',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                Text(
                                  widget.user.displayName ?? 'Utilisateur',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                                Text(
                                  widget.user.email ?? '',
                                  style: GoogleFonts.poppins(
                                    fontSize: 12,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 30),

                    // Title
                    Text(
                      'Informations sur votre animal',
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 8),

                    Text(
                      'Dites-nous en plus sur votre compagnon',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.white.withOpacity(0.9),
                      ),
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: 40),

                    // Pet form
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
                          // Pet type dropdown
                          DropdownButtonFormField<String>(
                            value: _selectedPetType,
                            decoration: InputDecoration(
                              labelText: 'Type d\'animal',
                              labelStyle: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.pets,
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
                            items: _petTypes.map((String type) {
                              return DropdownMenuItem<String>(
                                value: type,
                                child: Text(type),
                              );
                            }).toList(),
                            onChanged: (String? newValue) {
                              setState(() {
                                _selectedPetType = newValue!;
                              });
                            },
                          ),

                          const SizedBox(height: 20),

                          // Pet name
                          TextFormField(
                            controller: _petNameController,
                            decoration: InputDecoration(
                              labelText: 'Nom de l\'animal',
                              labelStyle: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.tag,
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
                                return 'Veuillez entrer le nom de votre animal';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Pet age
                          TextFormField(
                            controller: _petAgeController,
                            decoration: InputDecoration(
                              labelText: 'Âge',
                              labelStyle: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.cake,
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
                                return 'Veuillez entrer l\'âge de votre animal';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 20),

                          // Pet breed
                          TextFormField(
                            controller: _petBreedController,
                            decoration: InputDecoration(
                              labelText: 'Race',
                              labelStyle: TextStyle(
                                color: AppTheme.textSecondary,
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.category,
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
                                return 'Veuillez entrer la race de votre animal';
                              }
                              return null;
                            },
                          ),

                          const SizedBox(height: 30),

                          // Error message
                          if (_error != null) ...[
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTheme.error.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: AppTheme.error.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    color: AppTheme.error,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _error!,
                                      style: GoogleFonts.poppins(
                                        color: AppTheme.error,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],

                          // Complete signup button
                          SizedBox(
                            width: double.infinity,
                            height: 50,
                            child: ElevatedButton(
                              onPressed: _isLoading
                                  ? null
                                  : _handleCompleteSignup,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                                elevation: 0,
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
                                      'Terminer l\'inscription',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
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
