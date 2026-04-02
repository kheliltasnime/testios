import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/theme.dart';
import '../../../../core/router.dart';
import '../../../../core/constants.dart';

class RegisterScreenImproved extends StatefulWidget {
  const RegisterScreenImproved({super.key});

  @override
  State<RegisterScreenImproved> createState() => _RegisterScreenImprovedState();
}

class _RegisterScreenImprovedState extends State<RegisterScreenImproved> {
  final _formKey = GlobalKey<FormState>();
  final _firstName = TextEditingController();
  final _lastName = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  // Pet fields
  final _petName = TextEditingController();
  final _petSpecies = TextEditingController();
  final _petBreed = TextEditingController();
  final _petAge = TextEditingController();
  final _petWeight = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _firstName.dispose();
    _lastName.dispose();
    _email.dispose();
    _phone.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    _petName.dispose();
    _petSpecies.dispose();
    _petBreed.dispose();
    _petAge.dispose();
    _petWeight.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final registerRes = await http.post(
        Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.register}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'firstName': _firstName.text.trim(),
          'lastName': _lastName.text.trim(),
          'email': _email.text.trim(),
          'phone': _phone.text.trim().isEmpty ? null : _phone.text.trim(),
          'password': _password.text,
        }),
      );

      if (registerRes.statusCode < 200 || registerRes.statusCode >= 300) {
        final body = jsonDecode(registerRes.body);
        String errorMessage = body['error'] ?? 'Echec creation du compte';
        
        // Gestion spéciale pour l'email déjà existant
        if (registerRes.statusCode == 409 || errorMessage.toLowerCase().contains('email already registered')) {
          errorMessage = 'Cet email est déjà utilisé. Veuillez vous connecter ou utiliser un autre email.';
        }
        
        throw Exception(errorMessage);
      }

      final registerBody = jsonDecode(registerRes.body);
      final accessToken = registerBody['tokens']?['accessToken'] as String?;
      if (accessToken == null || accessToken.isEmpty) {
        throw Exception('Token manquant apres inscription');
      }

      final petRes = await http.post(
        Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.pets}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $accessToken',
        },
        body: jsonEncode({
          'name': _petName.text.trim(),
          'species': _petSpecies.text.trim(),
          'breed': _petBreed.text.trim().isEmpty ? null : _petBreed.text.trim(),
          'weight': double.tryParse(_petWeight.text.trim()),
          // backend accepte birthDate; on le laisse null pour le moment.
          'birthDate': null,
          'specialNeeds': 'Age: ${_petAge.text.trim()} ans',
        }),
      );

      if (petRes.statusCode < 200 || petRes.statusCode >= 300) {
        final body = jsonDecode(petRes.body);
        throw Exception(body['error'] ?? 'Compte cree mais echec creation animal');
      }

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Compte et animal crees avec succes'),
          backgroundColor: AppTheme.success,
        ),
      );
      context.go(AppRouter.dashboard);
    } catch (e) {
      if (!mounted) return;
      String errorMessage = e.toString().replaceFirst('Exception: ', '');
      
      // Vérifier si c'est une erreur d'email déjà existant
      if (errorMessage.toLowerCase().contains('déjà utilisé') || 
          errorMessage.toLowerCase().contains('already used') ||
          errorMessage.toLowerCase().contains('already registered')) {
        
        // Afficher un dialogue spécial pour l'email déjà existant
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Email déjà utilisé'),
              content: const Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Cet email est déjà utilisé dans notre système.'),
                  SizedBox(height: 8),
                  Text('Veuillez utiliser un autre email pour créer votre compte.'),
                ],
              ),
              actions: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Fermer le dialogue
                    // Effacer le champ email pour permettre d'en saisir un nouveau
                    _email.clear();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: AppTheme.onPrimary,
                  ),
                  child: const Text('OK'),
                ),
              ],
            );
          },
        );
      } else {
        // Afficher l'erreur normale dans un SnackBar
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
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
    return Scaffold(
      appBar: AppBar(title: const Text('Inscription')),
      body: SafeArea(
        child: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                TextFormField(
                  controller: _firstName,
                  decoration: const InputDecoration(labelText: 'Prenom'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Prenom requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _lastName,
                  decoration: const InputDecoration(labelText: 'Nom'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Nom requis' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _email,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Email requis';
                    final ok = RegExp(r'^[\w\-\.]+@([\w\-]+\.)+[\w\-]{2,4}$').hasMatch(v);
                    return ok ? null : 'Email invalide';
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _phone,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Telephone (optionnel)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _password,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe',
                    suffixIcon: IconButton(
                      onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                      icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Mot de passe requis';
                    if (v.length < 8) return 'Minimum 8 caracteres';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _confirmPassword,
                  obscureText: _obscureConfirmPassword,
                  decoration: InputDecoration(
                    labelText: 'Confirmer mot de passe',
                    suffixIcon: IconButton(
                      onPressed: () => setState(
                        () => _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                      icon: Icon(
                        _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
                      ),
                    ),
                  ),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Confirmation requise';
                    if (v != _password.text) return 'Les mots de passe ne correspondent pas';
                    return null;
                  },
                ),

                const SizedBox(height: 20),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Informations de votre animal',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _petName,
                  decoration: const InputDecoration(labelText: 'Nom de l\'animal'),
                  validator: (v) => (v == null || v.isEmpty) ? 'Nom animal requis' : null,
                ),
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _petSpecies.text.isEmpty ? null : _petSpecies.text,
                  decoration: const InputDecoration(labelText: 'Espece'),
                  items: const [
                    DropdownMenuItem(value: 'chien', child: Text('Chien')),
                    DropdownMenuItem(value: 'chat', child: Text('Chat')),
                    DropdownMenuItem(value: 'lapin', child: Text('Lapin')),
                    DropdownMenuItem(value: 'oiseau', child: Text('Oiseau')),
                    DropdownMenuItem(value: 'rongeur', child: Text('Rongeur')),
                  ],
                  onChanged: (value) => _petSpecies.text = value ?? '',
                  validator: (v) => (v == null || v.isEmpty) ? 'Espece requise' : null,
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _petBreed,
                  decoration: const InputDecoration(labelText: 'Race (optionnel)'),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _petAge,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Age (annees)'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Age requis';
                    final age = int.tryParse(v);
                    if (age == null || age < 0 || age > 30) return 'Age invalide (0-30)';
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _petWeight,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Poids (kg)'),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Poids requis';
                    final w = double.tryParse(v);
                    if (w == null || w <= 0 || w > 100) return 'Poids invalide (0-100)';
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _register,
                    child: _isLoading
                        ? const CircularProgressIndicator(color: AppTheme.onPrimary)
                        : const Text('Creer mon compte et mon animal'),
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
