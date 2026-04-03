class AppConstants {
  static const String appName = 'PlutoVets';
  static const String appVersion = '1.0.0';

  static const String baseUrl = 'http://localhost:3000/api';
  static const String wsUrl = 'http://localhost:3000';

  static const Duration timeout = Duration(seconds: 30);
  static const Duration connectTimeout = Duration(seconds: 10);

  static const String storageTokenKey = 'auth_token';
  static const String storageRefreshTokenKey = 'refresh_token';
  static const String storageUserKey = 'user_data';
  static const String storageFcmTokenKey = 'fcm_token';

  static const int maxFileSize = 5 * 1024 * 1024;
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'gif',
  ];
  static const List<String> supportedDocumentFormats = ['pdf', 'doc', 'docx'];

  static const String defaultDateFormat = 'yyyy-MM-dd';
  static const String defaultTimeFormat = 'HH:mm';
  static const String defaultDateTimeFormat = 'yyyy-MM-dd HH:mm';

  static const List<String> petSpecies = [
    'chien',
    'chat',
    'lapin',
    'oiseau',
    'rongeur',
  ];
  static const List<String> dogBreeds = [
    'Golden Retriever',
    'Berger Allemand',
    'Caniche',
    'Bulldog',
    'Labrador',
    'Beagle',
    'Husky',
    'Yorkshire',
    'Boxer',
    'Chihuahua',
  ];
  static const List<String> catBreeds = [
    'Siamois',
    'Persan',
    'European',
    'Maine Coon',
    'Bengal',
    'Ragdoll',
    'British Shorthair',
    'Sphynx',
    'Scottish Fold',
    'Abyssin',
  ];

  static const List<String> bookingStatuses = [
    'pending',
    'confirmed',
    'cancelled',
    'completed',
  ];
  static const List<String> serviceCategories = [
    'consultation',
    'toilettage',
    'vaccination',
    'urgence',
    'dressage',
  ];

  static const int paginationDefaultLimit = 10;
  static const int paginationMaxLimit = 50;

  static const String privacyPolicyUrl = 'https://www.plutovets.com/privacy';
  static const String termsOfServiceUrl = 'https://www.plutovets.com/terms';
  static const String supportEmail = 'support@plutovets.com';
  static const String supportPhone = '01 23 45 67 89';
}

class ApiEndpoints {
  static const String auth = '/auth';
  static const String register = '$auth/register';
  static const String login = '$auth/login';
  static const String refresh = '$auth/refresh';
  static const String forgotPassword = '$auth/forgot-password';
  static const String resetPassword = '$auth/reset-password';

  static const String pets = '/pets';
  static String vaccinations(String petId) => '$pets/$petId/vaccinations';
  static String medicalRecords(String petId) => '$pets/$petId/medical-records';

  static const String bookings = '/bookings';
  static const String services = '$bookings/services';
  static String availability(String serviceId) =>
      '$bookings/availability/$serviceId';

  static const String users = '/users';
  static const String profile = '$users/profile';
  static const String dashboard = '$users/dashboard';
  static const String notifications = '$users/notifications';
  static const String search = '$users/search';
  static const String fcmToken = '$users/fcm-token';

  static const String external = '/external';
  static const String articles = '$external/articles';
  static const String campaigns = '$external/campaigns';
  static String veterinaryData(String petId) =>
      '$external/veterinary-data/$petId';
  static String syncVaccinations(String petId) =>
      '$external/sync-vaccinations/$petId';
  static const String emergencyContacts = '$external/emergency-contacts';

  static String petId(String id) => '/pets/$id';
  static String bookingId(String id) => '/bookings/$id';
  static String serviceId(String id) => '$bookings/services/$id';
  static String notificationId(String id) => '$users/notifications/$id';
}

class ErrorMessages {
  static const String networkError =
      'Erreur de connexion. Veuillez vérifier votre réseau.';
  static const String serverError =
      'Erreur serveur. Veuillez réessayer plus tard.';
  static const String unauthorized = 'Non autorisé. Veuillez vous connecter.';
  static const String forbidden = 'Accès refusé.';
  static const String notFound = 'Ressource non trouvée.';
  static const String timeout = 'Délai d\'attente dépassé.';
  static const String unknownError = 'Une erreur inconnue est survenue.';

  static const String invalidEmail = 'Adresse email invalide.';
  static const String invalidPassword = 'Mot de passe invalide.';
  static const String passwordMismatch =
      'Les mots de passe ne correspondent pas.';
  static const String weakPassword =
      'Le mot de passe doit contenir au moins 8 caractères.';
  static const String emailRequired = 'L\'adresse email est requise.';
  static const String passwordRequired = 'Le mot de passe est requis.';
  static const String nameRequired = 'Le nom est requis.';

  static const String petNotFound = 'Animal non trouvé.';
  static const String bookingNotFound = 'Réservation non trouvée.';
  static const String serviceNotFound = 'Service non trouvé.';
  static const String vaccinationRequired =
      'Vaccination requise pour ce service.';
  static const String bookingConflict = 'Conflit de réservation.';
  static const String cancellationTooLate =
      'Annulation impossible moins de 24h avant le rendez-vous.';
}

class SuccessMessages {
  static const String loginSuccess = 'Connexion réussie.';
  static const String registerSuccess = 'Inscription réussie.';
  static const String profileUpdated = 'Profil mis à jour avec succès.';
  static const String passwordReset = 'Mot de passe réinitialisé avec succès.';
  static const String petCreated = 'Animal ajouté avec succès.';
  static const String petUpdated = 'Animal mis à jour avec succès.';
  static const String petDeleted = 'Animal supprimé avec succès.';
  static const String bookingCreated = 'Réservation créée avec succès.';
  static const String bookingUpdated = 'Réservation mise à jour avec succès.';
  static const String bookingCancelled = 'Réservation annulée avec succès.';
  static const String vaccinationAdded = 'Vaccination ajoutée avec succès.';
  static const String medicalRecordAdded =
      'Dossier médical ajouté avec succès.';
  static const String notificationRead = 'Notification marquée comme lue.';
}
