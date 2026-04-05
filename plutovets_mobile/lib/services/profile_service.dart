import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../core/constants.dart';

class ProfileService {
  final String baseUrl;

  ProfileService({required this.baseUrl});

  // Sync Google user data with backend profile
  Future<Map<String, dynamic>> syncGoogleProfile({
    required String uid,
    required String email,
    required String displayName,
    String? photoURL,
  }) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString(AppConstants.storageTokenKey);

      final response = await http.post(
        Uri.parse('$baseUrl/api/auth/sync-google-profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'uid': uid,
          'email': email,
          'displayName': displayName,
          'photoURL': photoURL,
          'loginMethod': 'google',
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final body = jsonDecode(response.body);
        
        // Update local user data with backend profile
        await prefs.setString(
          AppConstants.storageUserKey,
          jsonEncode(body['user']),
        );
        
        return {
          'success': true,
          'user': body['user'],
        };
      } else {
        // If backend sync fails, still save locally
        final userData = {
          'id': uid,
          'email': email,
          'displayName': displayName,
          'photoURL': photoURL,
          'firstName': _extractFirstName(displayName),
          'lastName': _extractLastName(displayName),
          'loginMethod': 'google',
          'isProfileComplete': true,
        };
        
        await prefs.setString(
          AppConstants.storageUserKey,
          jsonEncode(userData),
        );
        
        return {
          'success': false,
          'user': userData,
          'message': 'Backend sync failed, saved locally',
        };
      }
    } catch (e) {
      // Save locally if network fails
      final userData = {
        'id': uid,
        'email': email,
        'displayName': displayName,
        'photoURL': photoURL,
        'firstName': _extractFirstName(displayName),
        'lastName': _extractLastName(displayName),
        'loginMethod': 'google',
        'isProfileComplete': true,
      };
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        AppConstants.storageUserKey,
        jsonEncode(userData),
      );
      
      return {
        'success': false,
        'user': userData,
        'message': 'Network error, saved locally',
      };
    }
  }

  // Extract first name from display name
  String _extractFirstName(String? displayName) {
    if (displayName == null || displayName.isEmpty) return '';
    
    final parts = displayName.trim().split(' ');
    return parts.isNotEmpty ? parts.first : '';
  }

  // Extract last name from display name
  String _extractLastName(String? displayName) {
    if (displayName == null || displayName.isEmpty) return '';
    
    final parts = displayName.trim().split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : '';
  }

  // Get current user profile
  Future<Map<String, dynamic>?> getCurrentProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString(AppConstants.storageUserKey);
      
      if (userDataString != null) {
        return jsonDecode(userDataString);
      }
      return null;
    } catch (e) {
      return null;
    }
  }
}
