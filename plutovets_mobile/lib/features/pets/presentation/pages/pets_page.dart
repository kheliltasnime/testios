import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../../../core/router.dart';
import '../../../../core/theme.dart';
import '../../../../core/constants.dart';
import '../../../../services/pet_service.dart';

class PetsScreen extends StatefulWidget {
  const PetsScreen({super.key});

  @override
  State<PetsScreen> createState() => _PetsScreenState();
}

class _PetsScreenState extends State<PetsScreen> {
  List<Map<String, dynamic>> _userPets = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadUserPets();
  }

  Future<void> _loadUserPets() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final petService = PetService(baseUrl: AppConstants.baseUrl);

      // First try to get pets from backend
      final backendPets = await petService.getUserPets();

      // Also check for local pets (from Google signup)
      final localPet = await petService.getLocalPet();

      List<Map<String, dynamic>> allPets = [];

      // Add backend pets
      allPets.addAll(backendPets);

      // Add local pet if not already in backend pets
      if (localPet != null) {
        final existsInBackend = backendPets.any(
          (pet) =>
              pet['id'] == localPet['id'] ||
              (pet['name'] == localPet['name'] &&
                  pet['ownerId'] == localPet['ownerId']),
        );

        if (!existsInBackend) {
          allPets.add(localPet);

          // Try to sync local pet with backend
          await petService.syncLocalPet();
        }
      }

      setState(() {
        _userPets = allPets;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Erreur de chargement: ${e.toString()}';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.loginGradient),
        child: SafeArea(
          child: Column(
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(20),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: () => context.go('/dashboard'),
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                    ),
                    Expanded(
                      child: Text(
                        'My Pets',
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: () => context.go('/dashboard'),
                      icon: Icon(Icons.home, color: Colors.white),
                    ),
                  ],
                ),
              ),

              // Content
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      // Stats Card
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Total',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '${_userPets.length} pet${_userPets.length > 1 ? 's' : ''}',
                                  style: GoogleFonts.poppins(
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold,
                                    color: AppTheme.primaryColor,
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppTheme.primaryColor.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Icon(
                                Icons.pets,
                                size: 30,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Add Pet Button
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: () => context.go('/pets/add'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.primaryColor,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.add),
                              const SizedBox(width: 8),
                              Text(
                                'Add a pet',
                                style: GoogleFonts.poppins(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Pets List
                      if (_isLoading)
                        Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: CircularProgressIndicator(
                              color: AppTheme.primaryColor,
                            ),
                          ),
                        )
                      else if (_error != null)
                        Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.error_outline,
                                  size: 48,
                                  color: AppTheme.error,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  _error!,
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    color: AppTheme.error,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                ElevatedButton(
                                  onPressed: _loadUserPets,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primaryColor,
                                    foregroundColor: Colors.white,
                                  ),
                                  child: const Text('Retry'),
                                ),
                              ],
                            ),
                          ),
                        )
                      else if (_userPets.isEmpty)
                        Container(
                          padding: const EdgeInsets.all(40),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Center(
                            child: Column(
                              children: [
                                Icon(
                                  Icons.pets_outlined,
                                  size: 64,
                                  color: AppTheme.textSecondary,
                                ),
                                const SizedBox(height: 16),
                                Text(
                                  'No pets registered',
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: AppTheme.textSecondary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Add your first pet to get started',
                                  style: GoogleFonts.poppins(
                                    fontSize: 14,
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        )
                      else
                        Column(
                          children: _userPets.map((pet) {
                            return _buildPetCard(pet);
                          }).toList(),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPetCard(Map<String, dynamic> pet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                // Pet Avatar
                Container(
                  width: 60,
                  height: 60,
                  decoration: BoxDecoration(
                    color: _getSpeciesColor(pet['species']).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: Icon(
                    _getSpeciesIcon(pet['species']),
                    size: 30,
                    color: _getSpeciesColor(pet['species']),
                  ),
                ),
                const SizedBox(width: 16),

                // Pet Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pet['name'] ?? 'Unknown Name',
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${pet['species'] ?? 'Unknown Species'} • ${pet['breed'] ?? 'Unknown Breed'}',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${pet['age'] ?? '?'} years old • ${pet['weight'] ?? '?'} kg',
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),

                // Action Button
                PopupMenuButton<String>(
                  icon: Icon(Icons.more_vert, color: AppTheme.textSecondary),
                  onSelected: (value) {
                    if (value == 'view') {
                      // Navigate to pet details
                    } else if (value == 'edit') {
                      // Navigate to edit pet
                    } else if (value == 'delete') {
                      // Show delete confirmation
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility, color: AppTheme.textSecondary),
                          const SizedBox(width: 8),
                          Text('View'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit, color: AppTheme.textSecondary),
                          const SizedBox(width: 8),
                          Text('Edit'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: AppTheme.error),
                          const SizedBox(width: 8),
                          Text('Delete'),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Pet Details
            if (pet['specialNeeds'] != null &&
                pet['specialNeeds'].toString().isNotEmpty)
              Container(
                margin: const EdgeInsets.only(top: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.inputBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.medical_services,
                      color: AppTheme.primaryColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        pet['specialNeeds'],
                        style: GoogleFonts.poppins(
                          fontSize: 14,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Color _getSpeciesColor(String? species) {
    switch (species?.toLowerCase()) {
      case 'chien':
        return AppTheme.petDog;
      case 'chat':
        return AppTheme.petCat;
      case 'lapin':
        return AppTheme.petRabbit;
      case 'oiseau':
        return AppTheme.petBird;
      case 'rongeur':
        return AppTheme.petRodent;
      default:
        return AppTheme.primaryColor;
    }
  }

  IconData _getSpeciesIcon(String? species) {
    switch (species?.toLowerCase()) {
      case 'chien':
        return Icons.pets;
      case 'chat':
        return Icons.cruelty_free;
      case 'lapin':
        return Icons.catching_pokemon;
      case 'oiseau':
        return Icons.flight;
      case 'rongeur':
        return Icons.pest_control_rodent;
      default:
        return Icons.pets;
    }
  }
}
