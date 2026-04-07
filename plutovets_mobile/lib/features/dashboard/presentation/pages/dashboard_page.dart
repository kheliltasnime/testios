import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert';
import '../../../../core/router.dart';
import '../../../../core/theme.dart';
import '../../../../core/constants.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  List<Map<String, dynamic>> _userPets = [];
  bool _petsLoading = true;

  final List<Map<String, dynamic>> _services = [
    {
      'title': 'Dental Care',
      'description': 'Professional dental cleaning and oral health maintenance',
      'icon': Icons.cleaning_services_rounded,
      'color': Color.fromRGBO(255, 173, 207, 1),
      'imagePath': 'assets/images/dental_care.jpg',
    },
    {
      'title': 'Surgery',
      'description': 'Advanced surgical procedures and operations',
      'icon': Icons.medical_services_rounded,
      'color': Color.fromRGBO(255, 173, 207, 1),
      'imagePath': 'assets/images/surgery.jpg',
    },
    {
      'title': 'X-ray',
      'description': 'Digital radiography and diagnostic imaging',
      'icon': Icons.image_search_rounded,
      'color': Color.fromRGBO(255, 173, 207, 1),
      'imagePath': 'assets/images/xray.jpg',
    },
    {
      'title': 'Diagnostics',
      'description': 'Comprehensive health assessments and laboratory testing',
      'icon': Icons.search_rounded,
      'color': Color.fromRGBO(255, 173, 207, 1),
      'imagePath': 'assets/images/diagnostics.jpg',
    },
    {
      'title': 'Veterinary Consultation',
      'description': 'Professional medical consultations and examinations',
      'icon': Icons.person_rounded,
      'color': Color.fromRGBO(255, 173, 207, 1),
      'imagePath': 'assets/images/consultation.jpg',
    },
    {
      'title': 'Vaccination',
      'description': 'Essential immunization and preventive care services',
      'icon': Icons.vaccines_rounded,
      'color': Color.fromRGBO(255, 173, 207, 1),
      'imagePath': 'assets/images/vaccination.jpg',
    },
    {
      'title': 'Blood Sample',
      'description': 'Professional laboratory testing and blood analysis',
      'icon': Icons.opacity_rounded,
      'color': Color.fromRGBO(255, 173, 207, 1),
      'imagePath': 'assets/images/blood_sample.jpg',
    },
    {
      'title': 'Killing',
      'description': 'Humane euthanasia services',
      'icon': Icons.favorite_border_rounded,
      'color': Color.fromRGBO(255, 173, 207, 1),
      'imagePath': 'assets/images/euthanasia.jpg',
    },
    {
      'title': 'Inspection and Chip Marking',
      'description': 'Pet identification services with microchip implantation',
      'icon': Icons.pets_rounded,
      'color': Color.fromRGBO(255, 173, 207, 1),
      'imagePath': 'assets/images/chip_marking.jpg',
    },
    {
      'title': 'Chemical Castration',
      'description': 'Safe and effective sterilization procedures',
      'icon': Icons.healing_rounded,
      'color': Color.fromRGBO(255, 173, 207, 1),
      'imagePath': 'assets/images/castration.jpg',
    },
    {
      'title': 'Librela and Solensia',
      'description': 'Advanced parasite treatment and prevention solutions',
      'icon': Icons.bug_report_rounded,
      'color': Color.fromRGBO(255, 173, 207, 1),
      'imagePath': 'assets/images/librela_solensia.jpg',
    },
    {
      'title': 'Medical Visit',
      'description': 'Regular health check-ups and medical examinations',
      'icon': Icons.home_rounded,
      'color': Color.fromRGBO(255, 173, 207, 1),
      'imagePath': 'assets/images/medical_visit.jpg',
    },
    {
      'title': 'Dietary Advice',
      'description': 'Nutritional counseling and diet planning for pets',
      'icon': Icons.restaurant_rounded,
      'color': Color.fromRGBO(255, 173, 207, 1),
      'imagePath': 'assets/images/dietary_advice.jpg',
    },
    {
      'title': 'Before the Trip',
      'description': 'Travel preparation and health certification services',
      'icon': Icons.flight_rounded,
      'color': Color.fromRGBO(255, 173, 207, 1),
      'imagePath': 'assets/images/before_trip.jpg',
    },
  ];

  @override
  void initState() {
    super.initState();
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.storageTokenKey);
      final userString = prefs.getString(AppConstants.storageUserKey);

      if (token != null && userString != null) {
        final user = jsonDecode(userString);
        setState(() {
          _userData = user;
          _isLoading = false;
        });

        // Charger les animaux de l'utilisateur
        await _loadUserPets(token);
      } else {
        // Non connecté - rediriger vers la page de login
        if (mounted) {
          context.go('/auth/login');
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _loadUserPets(String token) async {
    try {
      setState(() {
        _petsLoading = true;
      });

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.pets}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      print('Dashboard pets response status: ${response.statusCode}');
      print('Dashboard pets response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Dashboard pets loaded: ${data['pets'].length} pets');

        setState(() {
          _userPets = List<Map<String, dynamic>>.from(data['pets']);
          _petsLoading = false;
        });
      } else {
        setState(() {
          _petsLoading = false;
        });
      }
    } catch (e) {
      print('Error loading pets: $e');
      setState(() {
        _petsLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.loginGradient),
          child: Center(child: CircularProgressIndicator(color: Colors.white)),
        ),
      );
    }

    if (_userData == null) {
      return Scaffold(
        body: Container(
          decoration: const BoxDecoration(gradient: AppTheme.loginGradient),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.login, size: 64, color: Colors.white),
                const SizedBox(height: 16),
                Text(
                  'Please log in',
                  style: GoogleFonts.poppins(fontSize: 18, color: Colors.white),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => context.go('/auth/login'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppTheme.primaryColor,
                  ),
                  child: const Text('Sign In'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header avec dégradé
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Hello, ${_userData!['firstName']}!',
                      style: GoogleFonts.poppins(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Your companions are waiting for you',
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: AppTheme.textSecondary,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),

              // Navigation rapide
              Row(
                children: [
                  Expanded(
                    child: _buildQuickActionCard(
                      'Mes Animaux',
                      Icons.pets,
                      () => context.go('/pets'),
                      AppTheme.secondaryColor,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildQuickActionCard(
                      'Réservations',
                      Icons.calendar_month,
                      () => context.go('/bookings'),
                      AppTheme.primaryColor,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section des animaux
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'My Pets',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        ),
                        Text(
                          '${_userPets.length} pet${_userPets.length > 1 ? 's' : ''}',
                          style: GoogleFonts.poppins(
                            fontSize: 14,
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    if (_petsLoading)
                      const Center(child: CircularProgressIndicator())
                    else if (_userPets.isEmpty)
                      Center(
                        child: Column(
                          children: [
                            Icon(
                              Icons.pets_outlined,
                              size: 48,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No pets registered',
                              style: GoogleFonts.poppins(
                                fontSize: 16,
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () => context.go('/pets'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryColor,
                                foregroundColor: Colors.white,
                              ),
                              child: const Text('Add a pet'),
                            ),
                          ],
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
              const SizedBox(height: 24),

              // Section des services
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Our Services',
                          style: GoogleFonts.poppins(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Color.fromRGBO(255, 173, 207, 1),
                          ),
                        ),
                        TextButton(
                          onPressed: () => context.go('/services'),
                          child: Text(
                            'Show All',
                            style: GoogleFonts.poppins(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Color.fromRGBO(255, 173, 207, 1),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Services horizontal carousel - multiple services
                    SizedBox(
                      height: 200,
                      child: ListView.builder(
                        scrollDirection: Axis.horizontal,
                        itemCount: _services.length,
                        itemBuilder: (context, index) {
                          final service = _services[index];
                          return Container(
                            width:
                                280, // Smaller width to show multiple services
                            margin: const EdgeInsets.only(right: 12),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 10,
                                  offset: const Offset(0, 5),
                                ),
                              ],
                            ),
                            child: Material(
                              color: Colors.transparent,
                              child: InkWell(
                                onTap: () {
                                  // TODO: Navigate to service details
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Service: ${service['title']} - Coming soon!',
                                      ),
                                      backgroundColor: Color.fromRGBO(
                                        255,
                                        173,
                                        207,
                                        1,
                                      ),
                                    ),
                                  );
                                },
                                borderRadius: BorderRadius.circular(16),
                                child: Padding(
                                  padding: const EdgeInsets.all(12),
                                  child: Row(
                                    children: [
                                      Container(
                                        width: 50,
                                        height: 50,
                                        decoration: BoxDecoration(
                                          color: Color.fromRGBO(
                                            255,
                                            173,
                                            207,
                                            1,
                                          ).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                        child: Icon(
                                          service['icon'] as IconData,
                                          size: 25,
                                          color: Color.fromRGBO(
                                            255,
                                            173,
                                            207,
                                            1,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              service['title'],
                                              style:
                                                  GoogleFonts.playfairDisplay(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Color.fromRGBO(
                                                      4,
                                                      0,
                                                      56,
                                                      1,
                                                    ),
                                                  ),
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              service['description'],
                                              style: GoogleFonts.montserrat(
                                                fontSize: 10,
                                                color: Color.fromRGBO(
                                                  4,
                                                  0,
                                                  56,
                                                  1,
                                                ),
                                                height: 1.3,
                                              ),
                                              maxLines: 2,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      Icon(
                                        Icons.arrow_forward_ios,
                                        color: Color.fromRGBO(4, 0, 56, 1),
                                        size: 20,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickActionCard(
    String title,
    IconData icon,
    VoidCallback onTap,
    Color color,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 8),
            Text(
              title,
              style: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPetCard(Map<String, dynamic> pet) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.primaryColor.withOpacity(0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: AppTheme.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Icon(Icons.pets, color: AppTheme.primaryColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  pet['name'] ?? 'Unknown Name',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${pet['species'] ?? 'Unknown Species'} • ${pet['age'] ?? 'Unknown Age'} years old',
                  style: GoogleFonts.poppins(
                    fontSize: 14,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.arrow_forward_ios, color: AppTheme.textSecondary),
        ],
      ),
    );
  }
}
