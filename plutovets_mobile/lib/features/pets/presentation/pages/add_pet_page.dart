import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../../core/theme.dart';
import '../../../../core/constants.dart';
import '../../../../services/pet_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class AddPetScreen extends StatefulWidget {
  final String? petId;

  const AddPetScreen({super.key, this.petId});

  @override
  State<AddPetScreen> createState() => _AddPetScreenState();
}

class _AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _ageController = TextEditingController();
  final _breedController = TextEditingController();
  final _insuranceNumberController = TextEditingController();

  String _selectedSpecies = 'chien';
  bool _isNeutered = false;
  bool _isInsured = false;
  bool _isLoading = false;
  String? _error;

  @override
  void dispose() {
    _nameController.dispose();
    _ageController.dispose();
    _breedController.dispose();
    _insuranceNumberController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    if (!_formKey.currentState!.validate()) return;

    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      final userString = prefs.getString(AppConstants.storageUserKey);

      if (userString == null) {
        if (mounted) {
          setState(() {
            _error = 'User not connected';
          });
        }
        return;
      }

      final user = jsonDecode(userString);
      final petData = {
        'name': _nameController.text.trim(),
        'species': _selectedSpecies.toLowerCase(),
        'age': _ageController.text.trim(),
        'breed': _breedController.text.trim(),
        'isNeutered': _isNeutered,
        'isInsured': _isInsured,
        'insuranceNumber': _isInsured
            ? _insuranceNumberController.text.trim()
            : null,
        'ownerId': user['id'] ?? user['uid'],
        'createdAt': DateTime.now().toIso8601String(),
      };

      final petService = PetService(baseUrl: AppConstants.baseUrl);
      final result = await petService.createPet(petData);

      if (result['success']) {
        // Pet created successfully - navigate back to pets page with refresh
        if (mounted) {
          // Force refresh by going to dashboard first, then pets
          context.go('/dashboard');

          // Small delay to ensure data is synced
          await Future.delayed(const Duration(milliseconds: 500));

          // Then navigate to pets page
          if (mounted) {
            context.go('/pets');
          }
        }
      } else {
        if (mounted) {
          setState(() {
            _error = result['error'] ?? 'Error creating pet';
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error: ${e.toString()}';
        });
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.petId != null;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Edit Pet' : 'Add Pet',
          style: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
        backgroundColor: AppTheme.primaryColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.go('/pets'),
        ),
      ),
      body: Container(
        decoration: const BoxDecoration(gradient: AppTheme.loginGradient),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Card containing the form
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Color.fromRGBO(
                          255,
                          173,
                          207,
                          1,
                        ).withOpacity(0.2),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Color.fromRGBO(
                            255,
                            173,
                            207,
                            1,
                          ).withOpacity(0.1),
                          blurRadius: 15,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        // Name field
                        TextFormField(
                          controller: _nameController,
                          decoration: InputDecoration(
                            labelText: 'Pet Name',
                            labelStyle: TextStyle(
                              color: Color.fromRGBO(4, 0, 56, 1),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.pets,
                              color: Color.fromRGBO(255, 173, 207, 1),
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
                                color: Color.fromRGBO(
                                  255,
                                  173,
                                  207,
                                  1,
                                ).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Color.fromRGBO(255, 173, 207, 1),
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the pet name';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Species dropdown
                        DropdownButtonFormField<String>(
                          value: _selectedSpecies,
                          decoration: InputDecoration(
                            labelText: 'Species',
                            labelStyle: TextStyle(
                              color: Color.fromRGBO(4, 0, 56, 1),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.category,
                              color: Color.fromRGBO(255, 173, 207, 1),
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
                                color: Color.fromRGBO(
                                  255,
                                  173,
                                  207,
                                  1,
                                ).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Color.fromRGBO(255, 173, 207, 1),
                                width: 2,
                              ),
                            ),
                          ),
                          items: AppConstants.petSpecies.map((species) {
                            return DropdownMenuItem(
                              value: species,
                              child: Text(
                                species[0].toUpperCase() + species.substring(1),
                                style: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: AppTheme.textPrimary,
                                ),
                              ),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedSpecies = value!;
                            });
                          },
                        ),

                        const SizedBox(height: 20),

                        // Age field
                        TextFormField(
                          controller: _ageController,
                          decoration: InputDecoration(
                            labelText: 'Age',
                            labelStyle: TextStyle(
                              color: Color.fromRGBO(4, 0, 56, 1),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.cake,
                              color: Color.fromRGBO(255, 173, 207, 1),
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
                                color: Color.fromRGBO(
                                  255,
                                  173,
                                  207,
                                  1,
                                ).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Color.fromRGBO(255, 173, 207, 1),
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the pet age';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Breed field
                        TextFormField(
                          controller: _breedController,
                          decoration: InputDecoration(
                            labelText: 'Breed',
                            labelStyle: TextStyle(
                              color: Color.fromRGBO(4, 0, 56, 1),
                              fontSize: 14,
                            ),
                            prefixIcon: Icon(
                              Icons.pets_outlined,
                              color: Color.fromRGBO(255, 173, 207, 1),
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
                                color: Color.fromRGBO(
                                  255,
                                  173,
                                  207,
                                  1,
                                ).withOpacity(0.3),
                                width: 1,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide(
                                color: Color.fromRGBO(255, 173, 207, 1),
                                width: 2,
                              ),
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.trim().isEmpty) {
                              return 'Please enter the pet breed';
                            }
                            return null;
                          },
                        ),

                        const SizedBox(height: 20),

                        // Neutered checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _isNeutered,
                              onChanged: (value) {
                                setState(() {
                                  _isNeutered = value ?? false;
                                });
                              },
                              activeColor: AppTheme.primaryColor,
                            ),
                            Text('Neutered/Spayed', style: AppTheme.bodyStyle),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Insured checkbox
                        Row(
                          children: [
                            Checkbox(
                              value: _isInsured,
                              onChanged: (value) {
                                setState(() {
                                  _isInsured = value ?? false;
                                });
                              },
                              activeColor: AppTheme.primaryColor,
                            ),
                            Text('Insured', style: AppTheme.bodyStyle),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Insurance number field (only show if insured)
                        if (_isInsured)
                          TextFormField(
                            controller: _insuranceNumberController,
                            decoration: InputDecoration(
                              labelText: 'Insurance Number',
                              labelStyle: TextStyle(
                                color: Color.fromRGBO(4, 0, 56, 1),
                                fontSize: 14,
                              ),
                              prefixIcon: Icon(
                                Icons.health_and_safety,
                                color: Color.fromRGBO(255, 173, 207, 1),
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
                                  color: Color.fromRGBO(
                                    255,
                                    173,
                                    207,
                                    1,
                                  ).withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              focusedBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide(
                                  color: Color.fromRGBO(255, 173, 207, 1),
                                  width: 2,
                                ),
                              ),
                            ),
                            validator: (value) {
                              if (_isInsured &&
                                  (value == null || value.trim().isEmpty)) {
                                return 'Please enter the insurance number';
                              }
                              return null;
                            },
                          ),

                        const SizedBox(height: 30),

                        // Error message
                        if (_error != null)
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.red.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              _error!,
                              style: GoogleFonts.poppins(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),

                        const SizedBox(height: 20),

                        // Submit button
                        SizedBox(
                          width: double.infinity,
                          height: 50,
                          child: ElevatedButton(
                            onPressed: _isLoading ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Color.fromRGBO(255, 173, 207, 1),
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              elevation: 2,
                            ),
                            child: _isLoading
                                ? const Center(
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                : Text(
                                    isEdit ? 'Update' : 'Add Pet',
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
    );
  }
}
