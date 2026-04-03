import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../../../../core/router.dart';
import '../../../../core/theme.dart';
import '../../../../core/constants.dart';

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
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.storageTokenKey);

      if (token == null) {
        setState(() {
          _error = 'Non connecté';
          _isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.pets}'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          _userPets = List<Map<String, dynamic>>.from(data['pets'] ?? []);
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = 'Erreur lors du chargement des animaux';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Erreur: $e';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        title: const Text('Mes Animaux'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: AppTheme.onPrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              context.go(AppRouter.addPet);
            },
          ),
        ],
      ),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return Center(
        child: CircularProgressIndicator(color: AppTheme.primaryColor),
      );
    }

    if (_error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, size: 64, color: AppTheme.error),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadUserPets,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      );
    }

    if (_userPets.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.pets, size: 64, color: AppTheme.primaryColor),
            const SizedBox(height: 16),
            Text(
              'Vous n\'avez pas encore d\'animal',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Ajoutez votre premier animal pour commencer',
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context.go(AppRouter.addPet);
              },
              icon: const Icon(Icons.add),
              label: const Text('Ajouter un animal'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: AppTheme.onPrimary,
              ),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUserPets,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _userPets.length,
        itemBuilder: (context, index) {
          final pet = _userPets[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Icon(Icons.pets, color: AppTheme.primaryColor, size: 30),
              ),
              title: Text(
                pet['name'] ?? 'Inconnu',
                style: Theme.of(
                  context,
                ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 4),
                  Text(
                    'Espèce: ${pet['species'] ?? 'Non spécifié'}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'Poids: ${pet['weight']?.toString() ?? '?'} kg',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  if (pet['specialNeeds'] != null &&
                      pet['specialNeeds'].isNotEmpty) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Notes: ${pet['specialNeeds']}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
              trailing: Icon(
                Icons.chevron_right,
                color: AppTheme.textSecondary,
              ),
              onTap: () {
                // TODO: Naviguer vers les détails de l'animal
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Détails de ${pet['name']} bientôt disponibles!',
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
