import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/router.dart';
import '../../../../core/theme.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingItem> _items = [
    OnboardingItem(
      title: 'Bienvenue chez PlutoVets',
      description: 'Votre application mobile pour gerer la sante de vos animaux de compagnie',
      icon: Icons.pets,
      color: AppTheme.primaryColor,
    ),
    OnboardingItem(
      title: 'Suivi medical complet',
      description: 'Gerez carnet de sante, vaccinations et antecedents medicaux',
      icon: Icons.medical_services,
      color: AppTheme.success,
    ),
    OnboardingItem(
      title: 'Reservations simplifiees',
      description: 'Reservez des services en quelques clics',
      icon: Icons.calendar_today,
      color: AppTheme.secondaryColor,
    ),
  ];

  void _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_completed', true);
    if (mounted) context.go(AppRouter.auth);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                onPageChanged: (index) => setState(() => _currentPage = index),
                itemCount: _items.length,
                itemBuilder: (context, index) => OnboardingPage(item: _items[index]),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: _currentPage == _items.length - 1
                    ? _completeOnboarding
                    : () => _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        ),
                child: Text(_currentPage == _items.length - 1 ? 'Commencer' : 'Suivant'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingPage extends StatelessWidget {
  final OnboardingItem item;

  const OnboardingPage({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(item.icon, size: 120, color: item.color),
          const SizedBox(height: 24),
          Text(item.title, style: Theme.of(context).textTheme.headlineSmall, textAlign: TextAlign.center),
          const SizedBox(height: 12),
          Text(item.description, style: Theme.of(context).textTheme.bodyMedium, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class OnboardingItem {
  final String title;
  final String description;
  final IconData icon;
  final Color color;

  const OnboardingItem({
    required this.title,
    required this.description,
    required this.icon,
    required this.color,
  });
}
