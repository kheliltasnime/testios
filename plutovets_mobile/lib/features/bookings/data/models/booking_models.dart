class Service {
  final String id;
  final String name;
  final String description;
  final int duration; // en minutes
  final double price;
  final bool isActive;

  Service({
    required this.id,
    required this.name,
    required this.description,
    required this.duration,
    required this.price,
    required this.isActive,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      duration: json['duration_minutes'] ?? 30,
      price: double.tryParse(json['price']?.toString() ?? '0') ?? 0.0,
      isActive: json['is_active'] ?? true,
    );
  }
}

class Booking {
  final String id;
  final String petId;
  final String serviceId;
  final DateTime bookingDate;
  final String status;
  final String? notes;
  final String location; // 'clinic' ou 'home'
  final DateTime createdAt;
  final Service? service;
  final String? petName;
  final String? serviceName;

  Booking({
    required this.id,
    required this.petId,
    required this.serviceId,
    required this.bookingDate,
    required this.status,
    this.notes,
    required this.location,
    required this.createdAt,
    this.service,
    this.petName,
    this.serviceName,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      id: json['id'].toString(),
      petId: json['pet_id'].toString(),
      serviceId: json['service_id'].toString(),
      bookingDate: DateTime.parse(json['booking_date']),
      status: json['status'] ?? 'pending',
      notes: json['notes'],
      location: json['location'] ?? 'clinic',
      createdAt: DateTime.parse(json['created_at']),
      service: json['service'] != null
          ? Service.fromJson(json['service'])
          : null,
      petName: json['pet_name'],
      serviceName: json['service_name'] ?? json['service']?['name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'petId': petId,
      'serviceId': serviceId,
      'bookingDate': bookingDate.toIso8601String(),
      'notes': notes,
      'location': location,
    };
  }
}

enum BookingStatus {
  pending('pending', 'En attente'),
  confirmed('confirmed', 'Confirmé'),
  cancelled('cancelled', 'Annulé'),
  completed('completed', 'Terminé');

  const BookingStatus(this.value, this.label);
  final String value;
  final String label;
}

enum BookingLocation {
  clinic('clinic', 'À la clinique'),
  home('home', 'À domicile');

  const BookingLocation(this.value, this.label);
  final String value;
  final String label;
}
