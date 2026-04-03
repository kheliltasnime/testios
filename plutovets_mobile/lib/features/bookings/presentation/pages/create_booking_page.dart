import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/theme.dart';
import '../../../../core/router.dart';
import '../../../../core/constants.dart';
import '../../data/models/booking_models.dart';
import '../../data/booking_service.dart';

class CreateBookingScreen extends StatefulWidget {
  final String? petId;
  final String? serviceId;
  final String? bookingId;

  const CreateBookingScreen({
    super.key,
    this.petId,
    this.serviceId,
    this.bookingId,
  });

  @override
  State<CreateBookingScreen> createState() => _CreateBookingScreenState();
}

class _CreateBookingScreenState extends State<CreateBookingScreen> {
  final _formKey = GlobalKey<FormState>();
  final _notesController = TextEditingController();
  final _petNameController = TextEditingController();
  final _petSpeciesController = TextEditingController();
  final _petAgeController = TextEditingController();
  final _petWeightController = TextEditingController();
  final BookingService _bookingService = BookingService();

  bool _isLoading = false;
  List<Service> _services = [];
  Service? _selectedService;
  BookingLocation _selectedLocation = BookingLocation.clinic;
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;

  // User and Pet data
  Map<String, dynamic>? _userData;
  List<Map<String, dynamic>> _userPets = [];
  Map<String, dynamic>? _selectedPet;
  bool _addNewPet = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
    _loadServices();
  }

  @override
  void dispose() {
    _notesController.dispose();
    _petNameController.dispose();
    _petSpeciesController.dispose();
    _petAgeController.dispose();
    _petWeightController.dispose();
    super.dispose();
  }

  Future<void> _loadUserData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.storageTokenKey);
      final userString = prefs.getString(AppConstants.storageUserKey);

      if (token != null && userString != null) {
        final user = jsonDecode(userString);
        setState(() {
          _userData = user;
        });

        // Charger les animaux de l'utilisateur
        await _loadUserPets(token);
      } else {
        print('User not logged in - using demo mode');
        // En mode démo, on ne charge pas les animaux
        setState(() {
          _userData = {
            'firstName': 'Test',
            'lastName': 'User',
            'email': 'test@example.com',
            'phone': '0123456789',
          };
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      // Mode démo en cas d'erreur
      setState(() {
        _userData = {
          'firstName': 'Test',
          'lastName': 'User',
          'email': 'test@example.com',
          'phone': '0123456789',
        };
      });
    }
  }

  Future<void> _loadUserPets(String token) async {
    try {
      print('Loading user pets...');
      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.pets}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Pets response status: ${response.statusCode}');
      print('Pets response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Pets data: $data');
        setState(() {
          _userPets = List<Map<String, dynamic>>.from(data['pets'] ?? []);
          print('User pets loaded: ${_userPets.length} pets');
          if (_userPets.isNotEmpty && widget.petId == null) {
            _selectedPet = _userPets.first;
            print('Selected first pet: ${_selectedPet!['name']}');
          } else if (widget.petId != null) {
            _selectedPet = _userPets.firstWhere(
              (pet) => pet['id'] == widget.petId,
            );
            print('Selected pet by ID: ${_selectedPet!['name']}');
          }
        });
      } else {
        print('Failed to load pets: ${response.statusCode}');
      }
    } catch (e) {
      print('Error loading pets: $e');
    }
  }

  Future<void> _loadServices() async {
    try {
      print('Loading services...');
      final services = await _bookingService.getServices();
      print('Services loaded: ${services.length}');
      setState(() {
        _services = services;
        if (widget.serviceId != null) {
          _selectedService = services.firstWhere(
            (s) => s.id == widget.serviceId,
          );
        }
      });
    } catch (e) {
      print('Error loading services: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Erreur lors du chargement des services: ${e.toString()}',
            ),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    }
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now().add(const Duration(days: 1)),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime() async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<Map<String, dynamic>> _createNewPet(String token) async {
    try {
      print('Creating new pet...');
      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.pets}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'name': _petNameController.text.trim(),
          'species': _petSpeciesController.text.trim(),
          'breed': null, // Optionnel
          'weight': double.tryParse(_petWeightController.text.trim()),
          'birthDate': null, // Optionnel
          'specialNeeds': 'Age: ${_petAgeController.text.trim()} ans',
        }),
      );

      print('Pet creation response: ${response.statusCode}');
      print('Pet creation body: ${response.body}');

      if (response.statusCode == 201) {
        final data = jsonDecode(response.body);
        print('New pet ID: ${data['pet']['id']}');
        return data;
      } else {
        throw Exception(
          'Erreur lors de la création de l\'animal: ${response.body}',
        );
      }
    } catch (e) {
      print('Error creating pet: $e');
      throw Exception('Erreur: $e');
    }
  }

  Future<void> _createBooking() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedService == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner un service'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    if (_selectedDate == null || _selectedTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Veuillez sélectionner une date et une heure'),
          backgroundColor: AppTheme.error,
        ),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.storageTokenKey);

      if (token == null) {
        // Mode démo - simulation de réservation
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mode démo: Réservation simulée avec succès!'),
            backgroundColor: AppTheme.success,
          ),
        );
        context.go(AppRouter.dashboard);
        return;
      }

      String petId;

      // Créer un nouvel animal si nécessaire
      if (_addNewPet) {
        print('Adding new pet...');
        final newPet = await _createNewPet(token);
        petId = newPet['pet']['id'];
        print('Using new pet ID: $petId');
      } else if (_selectedPet != null) {
        petId = _selectedPet!['id'];
        print('Using existing pet ID: $petId');
      } else {
        throw Exception('Veuillez sélectionner un animal');
      }

      print('Pet ID for booking: $petId');
      print('Service ID: ${_selectedService!.id}');

      final bookingDate = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      await _bookingService.createBooking(
        petId: petId,
        serviceId: _selectedService!.id,
        bookingDate: bookingDate,
        notes: _notesController.text.trim().isEmpty
            ? null
            : _notesController.text.trim(),
        location: _selectedLocation.value,
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Rendez-vous créé avec succès!'),
            backgroundColor: AppTheme.success,
          ),
        );
        context.go(AppRouter.bookings);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: ${e.toString()}'),
            backgroundColor: AppTheme.error,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.bookingId != null;

    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: Text(
          isEdit ? 'Modifier le rendez-vous' : 'Prendre un rendez-vous',
        ),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.onPrimary,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // User info section
              if (_userData != null) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppTheme.primaryColor.withOpacity(0.3),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Informations du propriétaire',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Nom: ${_userData!['firstName']} ${_userData!['lastName']}',
                      ),
                      Text('Email: ${_userData!['email']}'),
                      if (_userData!['phone'] != null)
                        Text('Téléphone: ${_userData!['phone']}'),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
              ],

              // Pet selection
              Text(
                'Animal',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),

              // Toggle between existing pet and new pet
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Mes animaux'),
                      selected: !_addNewPet,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _addNewPet = false;
                          });
                        }
                      },
                      backgroundColor: AppTheme.inputBackground,
                      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: !_addNewPet
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Nouvel animal'),
                      selected: _addNewPet,
                      onSelected: (selected) {
                        if (selected) {
                          setState(() {
                            _addNewPet = true;
                          });
                        }
                      },
                      backgroundColor: AppTheme.inputBackground,
                      selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                      labelStyle: TextStyle(
                        color: _addNewPet
                            ? AppTheme.primaryColor
                            : AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Existing pet selection or new pet form
              if (_addNewPet) ...[
                // New pet form
                TextFormField(
                  controller: _petNameController,
                  decoration: const InputDecoration(
                    labelText: 'Nom de l\'animal',
                    filled: true,
                    fillColor: AppTheme.inputBackground,
                  ),
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Nom requis' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  value: _petSpeciesController.text.isEmpty
                      ? null
                      : _petSpeciesController.text,
                  decoration: const InputDecoration(
                    labelText: 'Espèce',
                    filled: true,
                    fillColor: AppTheme.inputBackground,
                  ),
                  items: const [
                    DropdownMenuItem(value: 'chien', child: Text('Chien')),
                    DropdownMenuItem(value: 'chat', child: Text('Chat')),
                    DropdownMenuItem(value: 'lapin', child: Text('Lapin')),
                    DropdownMenuItem(value: 'oiseau', child: Text('Oiseau')),
                    DropdownMenuItem(value: 'rongeur', child: Text('Rongeur')),
                  ],
                  onChanged: (value) {
                    _petSpeciesController.text = value ?? '';
                  },
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Espèce requise' : null,
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        controller: _petAgeController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Age (années)',
                          filled: true,
                          fillColor: AppTheme.inputBackground,
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Age requis';
                          final age = int.tryParse(v);
                          if (age == null || age < 0 || age > 30)
                            return 'Age invalide';
                          return null;
                        },
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextFormField(
                        controller: _petWeightController,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Poids (kg)',
                          filled: true,
                          fillColor: AppTheme.inputBackground,
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Poids requis';
                          final weight = double.tryParse(v);
                          if (weight == null || weight <= 0)
                            return 'Poids invalide';
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
              ] else ...[
                // Existing pet selection
                if (_userPets.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.info.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.info),
                    ),
                    child: Column(
                      children: [
                        Icon(Icons.info, color: AppTheme.info, size: 48),
                        const SizedBox(height: 8),
                        Text(
                          'Mode démo - Animaux disponibles',
                          style: TextStyle(
                            color: AppTheme.info,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Connectez-vous pour voir vos animaux ou ajoutez un nouvel animal',
                          style: TextStyle(color: AppTheme.info),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _addNewPet = true;
                            });
                          },
                          child: const Text('Ajouter un animal'),
                        ),
                      ],
                    ),
                  )
                else
                  DropdownButtonFormField<Map<String, dynamic>>(
                    value: _selectedPet,
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: AppTheme.inputBackground,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppTheme.primaryColor),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: AppTheme.primaryColor,
                          width: 2,
                        ),
                      ),
                    ),
                    hint: const Text('Sélectionnez un animal'),
                    items: _userPets.map((pet) {
                      return DropdownMenuItem(
                        value: pet,
                        child: Text(
                          '${pet['name']} - ${pet['species']} - ${pet['weight']?.toString() ?? '?'}kg',
                          style: const TextStyle(
                            fontWeight: FontWeight.w500,
                            fontSize: 13,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      );
                    }).toList(),
                    onChanged: (pet) {
                      setState(() {
                        _selectedPet = pet;
                      });
                    },
                  ),
              ],
              const SizedBox(height: 24),

              // Service selection
              const SizedBox(height: 20),
              Text(
                'Service',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              if (_services.isEmpty)
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.inputBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      CircularProgressIndicator(
                        color: AppTheme.primaryColor,
                        strokeWidth: 2,
                      ),
                      const SizedBox(width: 12),
                      Text(
                        'Chargement des services...',
                        style: TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                )
              else
                DropdownButtonFormField<Service>(
                  value: _selectedService,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppTheme.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(color: AppTheme.primaryColor),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide(
                        color: AppTheme.primaryColor,
                        width: 2,
                      ),
                    ),
                  ),
                  hint: const Text('Sélectionnez un service'),
                  items: _services.map((service) {
                    return DropdownMenuItem(
                      value: service,
                      child: Text(
                        '${service.name} - ${service.duration}min - ${service.price.toStringAsFixed(0)}€',
                        style: const TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 13,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    );
                  }).toList(),
                  onChanged: (service) {
                    setState(() {
                      _selectedService = service;
                    });
                  },
                ),

              const SizedBox(height: 24),

              // Location selection
              Text(
                'Lieu du rendez-vous',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: BookingLocation.values.map((location) {
                  return Expanded(
                    child: Padding(
                      padding: EdgeInsets.only(
                        right: location == BookingLocation.home ? 0 : 8,
                      ),
                      child: ChoiceChip(
                        label: Text(location.label),
                        selected: _selectedLocation == location,
                        onSelected: (selected) {
                          if (selected) {
                            setState(() {
                              _selectedLocation = location;
                            });
                          }
                        },
                        backgroundColor: AppTheme.inputBackground,
                        selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                        labelStyle: TextStyle(
                          color: _selectedLocation == location
                              ? AppTheme.primaryColor
                              : AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 24),

              // Date and Time selection
              Text(
                'Date et heure',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: InkWell(
                      onTap: _selectDate,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.inputBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primaryColor),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.calendar_today,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedDate != null
                                  ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                                  : 'Sélectionner une date',
                              style: TextStyle(
                                color: _selectedDate != null
                                    ? AppTheme.textPrimary
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: InkWell(
                      onTap: _selectTime,
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: AppTheme.inputBackground,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.primaryColor),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.access_time,
                              color: AppTheme.primaryColor,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              _selectedTime != null
                                  ? '${_selectedTime!.hour.toString().padLeft(2, '0')}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                                  : 'Sélectionner l\'heure',
                              style: TextStyle(
                                color: _selectedTime != null
                                    ? AppTheme.textPrimary
                                    : AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),

              // Notes
              Text(
                'Notes (optionnel)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppTheme.secondaryColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  hintText: 'Ajoutez des informations supplémentaires...',
                  filled: true,
                  fillColor: AppTheme.inputBackground,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.primaryColor),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppTheme.primaryColor,
                      width: 2,
                    ),
                  ),
                ),
                maxLines: 3,
              ),

              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _createBooking,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.onPrimary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(
                          color: AppTheme.onPrimary,
                        )
                      : Text(
                          isEdit ? 'Mettre à jour' : 'Confirmer le rendez-vous',
                          style: const TextStyle(fontWeight: FontWeight.w600),
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
