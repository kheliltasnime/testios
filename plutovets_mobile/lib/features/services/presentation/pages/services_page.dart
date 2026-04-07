import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';

class ServicesPage extends StatefulWidget {
  const ServicesPage({super.key});

  @override
  State<ServicesPage> createState() => _ServicesPageState();
}

class _ServicesPageState extends State<ServicesPage> {
  final List<Map<String, dynamic>> _services = [
    {
      'title': 'Dental Care',
      'description':
          'Professional dental cleaning and oral health maintenance for your pets',
      'icon': Icons.cleaning_services_rounded,
      'color': Color.fromRGBO(
        255,
        173,
        207,
        1,
      ), // rgb(255, 173, 207) - Rose clair
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
      'color': Color.fromRGBO(4, 0, 56, 1),
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
      'color': Color.fromRGBO(4, 0, 56, 1),
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
      'color': Color.fromRGBO(4, 0, 56, 1),
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
      'color': Color.fromRGBO(4, 0, 56, 1),
      'imagePath': 'assets/images/medical_visit.jpg',
    },
    {
      'title': 'Dietary Advice',
      'description':
          'Professional nutrition guidance and customized diet plans',
      'icon': Icons.restaurant_menu_rounded,
      'color': Color.fromRGBO(
        255,
        173,
        207,
        1,
      ), // rgb(255, 173, 207) - Rose clair
      'imagePath': 'assets/images/dietary_advice.jpg',
    },
    {
      'title': 'Before Trip',
      'description': 'Complete travel preparation and documentation services',
      'icon': Icons.flight_takeoff_rounded,
      'color': Color.fromRGBO(4, 0, 56, 1), // rgb(4, 0, 56) - Bleu foncé
      'imagePath': 'assets/images/before_trip.jpg',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          onPressed: () => context.go('/dashboard'),
          icon: Icon(
            Icons.arrow_back_ios,
            color: Color.fromRGBO(255, 173, 207, 1),
          ),
        ),
        title: Text(
          'Our Services',
          style: GoogleFonts.playfairDisplay(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color.fromRGBO(255, 173, 207, 1),
          ),
        ),
        centerTitle: true,
      ),
      body: Container(
        color: Colors.white,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header Section
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Color(0xFFFCE4EC), // Rose très clair
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Color(0xFFE91E63).withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Complete Veterinary Care',
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(255, 173, 207, 1),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We provide comprehensive medical services to keep your pets healthy and happy',
                      style: GoogleFonts.montserrat(
                        fontSize: 16,
                        color: Color.fromRGBO(255, 173, 207, 1),
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Services Grid
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.8,
                ),
                itemCount: _services.length,
                itemBuilder: (context, index) {
                  final service = _services[index];
                  return _buildServiceCard(service);
                },
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildServiceCard(Map<String, dynamic> service) {
    return InkWell(
      onTap: () {
        // TODO: Navigate to service details
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${service['title']} - Coming soon!'),
            backgroundColor: Color(0xFFE91E63), // Rose
          ),
        );
      },
      borderRadius: BorderRadius.circular(20),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: Color(0xFFE91E63).withOpacity(0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFE91E63).withOpacity(0.1),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Service Image
            Expanded(
              flex: 3,
              child: Container(
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(4, 0, 56, 1).withOpacity(0.1),
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                  child: Container(
                    width: double.infinity,
                    height: double.infinity,
                    color: Colors.grey.withOpacity(0.3),
                    child: Icon(
                      service['icon'],
                      color: Color.fromRGBO(4, 0, 56, 1),
                      size: 40,
                    ),
                  ),
                ),
              ),
            ),

            // Service Info
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      service['title'],
                      style: GoogleFonts.playfairDisplay(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color.fromRGBO(4, 0, 56, 1),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Expanded(
                      child: Text(
                        service['description'],
                        style: GoogleFonts.montserrat(
                          fontSize: 12,
                          color: Color.fromRGBO(255, 173, 207, 1),
                          height: 1.3,
                        ),
                        maxLines: 3,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(4, 0, 56, 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Learn More',
                        style: GoogleFonts.montserrat(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
