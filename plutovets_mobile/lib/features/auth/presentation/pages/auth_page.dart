import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/router.dart';
import '../../../../core/theme.dart';

class AuthScreen extends StatelessWidget {
  const AuthScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.pets, size: 72, color: AppTheme.primaryColor),
              const SizedBox(height: 16),
              Text(
                'PlutoVets',
                style: Theme.of(context).textTheme.headlineMedium,
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () => context.go('/auth/login'),
                  child: const Text('Connexion'),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () => context.go('/auth/register'),
                  child: const Text('Inscription'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => context.go(AppRouter.forgotPassword),
                child: const Text('Mot de passe oublie'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
