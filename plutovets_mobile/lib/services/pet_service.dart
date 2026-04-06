import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class PetService {
  final String baseUrl;

  PetService({required this.baseUrl});

  // Create a new pet
  Future<Map<String, dynamic>> createPet(Map<String, dynamic> petData) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.storageTokenKey);

      print('Creating pet with token: $token');
      print('Pet data: ${jsonEncode(petData)}');

      final response = await http.post(
        Uri.parse('${AppConstants.baseUrl}${ApiEndpoints.pets}'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(petData),
      );

      print('Pet creation response status: ${response.statusCode}');
      print('Pet creation response body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final createdPet = body['pet'];

        // Save pet locally for immediate display
        await savePetLocally(createdPet);

        return {'success': true, 'pet': createdPet};
      } else {
        return {
          'success': false,
          'error':
              'Failed to create pet: ${response.statusCode} - ${response.body}',
        };
      }
    } catch (e) {
      print('Pet creation error: ${e.toString()}');
      return {'success': false, 'error': 'Network error: ${e.toString()}'};
    }
  }

  // Get all pets for the current user
  Future<List<Map<String, dynamic>>> getUserPets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.storageTokenKey);

      final response = await http.get(
        Uri.parse(
          '${AppConstants.baseUrl}${ApiEndpoints.pets}?page=1&limit=10',
        ),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final body = jsonDecode(response.body);
        final backendPets = List<Map<String, dynamic>>.from(body['pets']);

        // Check if we have local pets that need syncing
        final localPet = await getLocalPet();

        if (localPet != null) {
          // Check if local pet exists in backend
          final existsInBackend = backendPets.any(
            (pet) =>
                pet['name'] == localPet['name'] &&
                pet['ownerId'] == localPet['ownerId'],
          );

          if (!existsInBackend) {
            // Try to sync local pet
            final syncResult = await syncLocalPet();
            if (syncResult['success']) {
              // Refresh pets after sync
              final newResponse = await http.get(
                Uri.parse(
                  '${AppConstants.baseUrl}${ApiEndpoints.pets}?page=1&limit=10',
                ),
                headers: {
                  'Content-Type': 'application/json',
                  'Authorization': 'Bearer $token',
                },
              );

              if (newResponse.statusCode == 200) {
                final newBody = jsonDecode(newResponse.body);
                return List<Map<String, dynamic>>.from(newBody['pets']);
              }
            }
          }
        }

        return backendPets;
      } else {
        // Fallback to local storage
        return await _getLocalPets();
      }
    } catch (e) {
      // Fallback to local storage
      return await _getLocalPets();
    }
  }

  // Save pet locally
  Future<void> savePetLocally(Map<String, dynamic> petData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userPet', jsonEncode(petData));
  }

  // Get local pet
  Future<Map<String, dynamic>?> getLocalPet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final petString = prefs.getString('userPet');

      if (petString != null) {
        return jsonDecode(petString);
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  // Get all local pets
  Future<List<Map<String, dynamic>>> _getLocalPets() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final petString = prefs.getString('userPet');

      if (petString != null) {
        final pet = jsonDecode(petString);
        return [pet]; // Return as list for consistency
      }
      return [];
    } catch (e) {
      return [];
    }
  }

  // Sync local pet with backend
  Future<Map<String, dynamic>> syncLocalPet() async {
    try {
      final localPet = await getLocalPet();

      if (localPet != null) {
        final result = await createPet(localPet);

        if (result['success']) {
          // Update local pet with backend data
          await savePetLocally(result['pet']);
          return result;
        }
      }

      return {'success': false, 'error': 'No local pet to sync'};
    } catch (e) {
      return {'success': false, 'error': 'Sync failed: ${e.toString()}'};
    }
  }
}
