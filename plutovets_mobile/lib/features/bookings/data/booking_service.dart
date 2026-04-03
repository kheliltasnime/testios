import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'models/booking_models.dart';
import '../../../../core/constants.dart';

class BookingService {
  final String _baseUrl = AppConstants.baseUrl;
  final String _tokenKey = AppConstants.storageTokenKey;

  Future<List<Map<String, dynamic>>> getAvailability(
    String serviceId, {
    DateTime? date,
  }) async {
    final dateString = date?.toIso8601String().split('T')[0];

    final response = await http.get(
      Uri.parse(
        '$_baseUrl/bookings/availability/$serviceId${dateString != null ? '?date=$dateString' : ''}',
      ),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${await _getToken()}',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return List<Map<String, dynamic>>.from(data['availableSlots'] ?? []);
    } else {
      throw Exception('Failed to load availability');
    }
  }

  Future<List<Service>> getServices() async {
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/bookings/services'),
        headers: {'Content-Type': 'application/json'},
      );

      print('Response status: ${response.statusCode}');
      print('Response body: ${response.body}');

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print('Parsed data: $data');

        if (data is Map && data.containsKey('services')) {
          final services = (data['services'] as List)
              .map((service) => Service.fromJson(service))
              .toList();
          print('Services count: ${services.length}');
          return services;
        } else {
          throw Exception('Invalid response format: missing services key');
        }
      } else {
        throw Exception('Failed to load services: ${response.statusCode}');
      }
    } catch (e) {
      print('Error in getServices: $e');
      throw Exception('Failed to load services: $e');
    }
  }

  Future<Booking> createBooking({
    required String petId,
    required String serviceId,
    required DateTime bookingDate,
    String? notes,
    required String location,
  }) async {
    final token = await _getToken();
    final response = await http.post(
      Uri.parse('$_baseUrl/bookings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'petId': petId,
        'serviceId': serviceId,
        'bookingDate': bookingDate.toIso8601String(),
        'notes': notes,
        'location': location,
      }),
    );

    if (response.statusCode == 201 || response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Booking.fromJson(data['booking']);
    } else {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to create booking');
    }
  }

  Future<List<Booking>> getUserBookings() async {
    final token = await _getToken();
    if (token == null) {
      throw Exception('Non connecté');
    }

    final response = await http.get(
      Uri.parse('$_baseUrl/bookings'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final bookings = (data['bookings'] as List)
          .map((booking) => Booking.fromJson(booking))
          .toList();
      return bookings;
    } else if (response.statusCode == 401) {
      throw Exception('Session expirée - veuillez vous reconnecter');
    } else {
      throw Exception('Failed to load bookings');
    }
  }

  Future<Booking> getBookingById(String bookingId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/bookings/$bookingId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_getToken()}',
      },
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return Booking.fromJson(data['booking']);
    } else {
      throw Exception('Failed to load booking');
    }
  }

  Future<void> cancelBooking(String bookingId) async {
    final response = await http.put(
      Uri.parse('$_baseUrl/bookings/$bookingId/cancel'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer ${_getToken()}',
      },
    );

    if (response.statusCode != 200) {
      final error = jsonDecode(response.body);
      throw Exception(error['error'] ?? 'Failed to cancel booking');
    }
  }

  Future<String?> _getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      return null;
    }
  }
}
