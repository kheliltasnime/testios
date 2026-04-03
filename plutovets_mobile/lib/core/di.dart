import 'package:get_it/get_it.dart';
import 'package:injectable/injectable.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

import '../data/datasources/remote/api_service.dart';
import '../data/datasources/local/storage_service.dart';
import '../data/repositories/auth_repository_impl.dart';
import '../data/repositories/pet_repository_impl.dart';
import '../data/repositories/booking_repository_impl.dart';
import '../data/repositories/user_repository_impl.dart';
import '../data/repositories/external_repository_impl.dart';

import '../domain/repositories/auth_repository.dart';
import '../domain/repositories/pet_repository.dart';
import '../domain/repositories/booking_repository.dart';
import '../domain/repositories/user_repository.dart';
import '../domain/repositories/external_repository.dart';

import '../domain/usecases/auth/login_usecase.dart';
import '../domain/usecases/auth/register_usecase.dart';
import '../domain/usecases/auth/logout_usecase.dart';
import '../domain/usecases/auth/forgot_password_usecase.dart';
import '../domain/usecases/auth/reset_password_usecase.dart';
import '../domain/usecases/auth/get_current_user_usecase.dart';

import '../domain/usecases/pets/get_pets_usecase.dart';
import '../domain/usecases/pets/get_pet_details_usecase.dart';
import '../domain/usecases/pets/create_pet_usecase.dart';
import '../domain/usecases/pets/update_pet_usecase.dart';
import '../domain/usecases/pets/delete_pet_usecase.dart';
import '../domain/usecases/pets/add_vaccination_usecase.dart';
import '../domain/usecases/pets/add_medical_record_usecase.dart';

import '../domain/usecases/bookings/get_bookings_usecase.dart';
import '../domain/usecases/bookings/get_booking_details_usecase.dart';
import '../domain/usecases/bookings/create_booking_usecase.dart';
import '../domain/usecases/bookings/update_booking_usecase.dart';
import '../domain/usecases/bookings/cancel_booking_usecase.dart';
import '../domain/usecases/bookings/get_services_usecase.dart';
import '../domain/usecases/bookings/get_availability_usecase.dart';

import '../domain/usecases/user/get_dashboard_usecase.dart';
import '../domain/usecases/user/get_notifications_usecase.dart';
import '../domain/usecases/user/mark_notification_read_usecase.dart';
import '../domain/usecases/user/search_usecase.dart';

import '../domain/usecases/external/get_articles_usecase.dart';
import '../domain/usecases/external/get_campaigns_usecase.dart';
import '../domain/usecases/external/get_veterinary_data_usecase.dart';
import '../domain/usecases/external/sync_vaccinations_usecase.dart';
import '../domain/usecases/external/get_emergency_contacts_usecase.dart';

import '../presentation/bloc/auth/auth_bloc.dart';
import '../presentation/bloc/pets/pets_bloc.dart';
import '../presentation/bloc/bookings/bookings_bloc.dart';
import '../presentation/bloc/user/user_bloc.dart';
import '../presentation/bloc/external/external_bloc.dart';

import '../services/notification_service.dart';
import '../services/socket_service.dart';
import '../services/fcm_service.dart';

final getIt = GetIt.instance;

@InjectableInit()
Future<void> configureDependencies() async {
  await getIt.init();
}

@module
abstract class DIModule {
  @preResolve
  Future<SharedPreferences> get prefs => SharedPreferences.getInstance();

  @lazySingleton
  FlutterSecureStorage get secureStorage => const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
    iOptions: IOSOptions(
      accessibility: KeychainAccessibility.first_unlock_this_device,
    ),
  );

  @lazySingleton
  ImagePicker get imagePicker => ImagePicker();

  @lazySingleton
  Dio get dio {
    final dio = Dio();
    dio.options.baseUrl = 'http://localhost:3000/api';
    dio.options.connectTimeout = const Duration(seconds: 10);
    dio.options.receiveTimeout = const Duration(seconds: 30);
    dio.options.sendTimeout = const Duration(seconds: 30);
    
    dio.interceptors.add(LogInterceptor(
      requestBody: true,
      responseBody: true,
      requestHeader: true,
      responseHeader: false,
      error: true,
      logPrint: (obj) {
        print(obj);
      },
    ));

    dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final storageService = getIt<StorageService>();
        final token = await storageService.getToken();
        
        if (token != null) {
          options.headers['Authorization'] = 'Bearer $token';
        }
        
        handler.next(options);
      },
      onError: (error, handler) async {
        if (error.response?.statusCode == 401) {
          final storageService = getIt<StorageService>();
          final refreshToken = await storageService.getRefreshToken();
          
          if (refreshToken != null) {
            try {
              final response = await dio.post(
                '/auth/refresh',
                data: {'refreshToken': refreshToken},
              );
              
              final newToken = response.data['tokens']['accessToken'];
              await storageService.saveToken(newToken);
              
              error.requestOptions.headers['Authorization'] = 'Bearer $newToken';
              handler.resolve(await dio.fetch(error.requestOptions));
              return;
            } catch (e) {
              await storageService.clearAll();
            }
          }
        }
        
        handler.next(error);
      },
    ));

    return dio;
  }

  @lazySingleton
  IO.Socket get socket {
    final socket = IO.io('http://localhost:3000', <String, dynamic>{
      'autoConnect': false,
      'transports': ['websocket'],
    });
    
    return socket;
  }

  @lazySingleton
  StorageService get storageService => StorageServiceImpl(getIt<FlutterSecureStorage>(), getIt<SharedPreferences>());

  @lazySingleton
  ApiService get apiService => ApiServiceImpl(getIt<Dio>());

  @lazySingleton
  AuthRepository get authRepository => AuthRepositoryImpl(getIt<ApiService>(), getIt<StorageService>());

  @lazySingleton
  PetRepository get petRepository => PetRepositoryImpl(getIt<ApiService>());

  @lazySingleton
  BookingRepository get bookingRepository => BookingRepositoryImpl(getIt<ApiService>());

  @lazySingleton
  UserRepository get userRepository => UserRepositoryImpl(getIt<ApiService>());

  @lazySingleton
  ExternalRepository get externalRepository => ExternalRepositoryImpl(getIt<ApiService>());

  @lazySingleton
  LoginUseCase get loginUseCase => LoginUseCase(getIt<AuthRepository>());

  @lazySingleton
  RegisterUseCase get registerUseCase => RegisterUseCase(getIt<AuthRepository>());

  @lazySingleton
  LogoutUseCase get logoutUseCase => LogoutUseCase(getIt<AuthRepository>());

  @lazySingleton
  ForgotPasswordUseCase get forgotPasswordUseCase => ForgotPasswordUseCase(getIt<AuthRepository>());

  @lazySingleton
  ResetPasswordUseCase get resetPasswordUseCase => ResetPasswordUseCase(getIt<AuthRepository>());

  @lazySingleton
  GetCurrentUserUseCase get getCurrentUserUseCase => GetCurrentUserUseCase(getIt<AuthRepository>());

  @lazySingleton
  GetPetsUseCase getPetsUseCase => GetPetsUseCase(getIt<PetRepository>());

  @lazySingleton
  GetPetDetailsUseCase getPetDetailsUseCase => GetPetDetailsUseCase(getIt<PetRepository>());

  @lazySingleton
  CreatePetUseCase createPetUseCase => CreatePetUseCase(getIt<PetRepository>());

  @lazySingleton
  UpdatePetUseCase updatePetUseCase => UpdatePetUseCase(getIt<PetRepository>());

  @lazySingleton
  DeletePetUseCase deletePetUseCase => DeletePetUseCase(getIt<PetRepository>());

  @lazySingleton
  AddVaccinationUseCase addVaccinationUseCase => AddVaccinationUseCase(getIt<PetRepository>());

  @lazySingleton
  AddMedicalRecordUseCase addMedicalRecordUseCase => AddMedicalRecordUseCase(getIt<PetRepository>());

  @lazySingleton
  GetBookingsUseCase getBookingsUseCase => GetBookingsUseCase(getIt<BookingRepository>());

  @lazySingleton
  GetBookingDetailsUseCase getBookingDetailsUseCase => GetBookingDetailsUseCase(getIt<BookingRepository>());

  @lazySingleton
  CreateBookingUseCase createBookingUseCase => CreateBookingUseCase(getIt<BookingRepository>());

  @lazySingleton
  UpdateBookingUseCase updateBookingUseCase => UpdateBookingUseCase(getIt<BookingRepository>());

  @lazySingleton
  CancelBookingUseCase cancelBookingUseCase => CancelBookingUseCase(getIt<BookingRepository>());

  @lazySingleton
  GetServicesUseCase getServicesUseCase => GetServicesUseCase(getIt<BookingRepository>());

  @lazySingleton
  GetAvailabilityUseCase getAvailabilityUseCase => GetAvailabilityUseCase(getIt<BookingRepository>());

  @lazySingleton
  GetDashboardUseCase getDashboardUseCase => GetDashboardUseCase(getIt<UserRepository>());

  @lazySingleton
  GetNotificationsUseCase getNotificationsUseCase => GetNotificationsUseCase(getIt<UserRepository>());

  @lazySingleton
  MarkNotificationReadUseCase markNotificationReadUseCase => MarkNotificationReadUseCase(getIt<UserRepository>());

  @lazySingleton
  SearchUseCase searchUseCase => SearchUseCase(getIt<UserRepository>());

  @lazySingleton
  GetArticlesUseCase getArticlesUseCase => GetArticlesUseCase(getIt<ExternalRepository>());

  @lazySingleton
  GetCampaignsUseCase getCampaignsUseCase => GetCampaignsUseCase(getIt<ExternalRepository>());

  @lazySingleton
  GetVeterinaryDataUseCase getVeterinaryDataUseCase => GetVeterinaryDataUseCase(getIt<ExternalRepository>());

  @lazySingleton
  SyncVaccinationsUseCase syncVaccinationsUseCase => SyncVaccinationsUseCase(getIt<ExternalRepository>());

  @lazySingleton
  GetEmergencyContactsUseCase getEmergencyContactsUseCase => GetEmergencyContactsUseCase(getIt<ExternalRepository>());

  @lazySingleton
  AuthBloc get authBloc => AuthBloc(
    loginUseCase: getIt<LoginUseCase>(),
    registerUseCase: getIt<RegisterUseCase>(),
    logoutUseCase: getIt<LogoutUseCase>(),
    forgotPasswordUseCase: getIt<ForgotPasswordUseCase>(),
    resetPasswordUseCase: getIt<ResetPasswordUseCase>(),
    getCurrentUserUseCase: getIt<GetCurrentUserUseCase>(),
  );

  @lazySingleton
  PetsBloc get petsBloc => PetsBloc(
    getPetsUseCase: getIt<GetPetsUseCase>(),
    getPetDetailsUseCase: getIt<GetPetDetailsUseCase>(),
    createPetUseCase: getIt<CreatePetUseCase>(),
    updatePetUseCase: getIt<UpdatePetUseCase>(),
    deletePetUseCase: getIt<DeletePetUseCase>(),
    addVaccinationUseCase: getIt<AddVaccinationUseCase>(),
    addMedicalRecordUseCase: getIt<AddMedicalRecordUseCase>(),
  );

  @lazySingleton
  BookingsBloc get bookingsBloc => BookingsBloc(
    getBookingsUseCase: getIt<GetBookingsUseCase>(),
    getBookingDetailsUseCase: getIt<GetBookingDetailsUseCase>(),
    createBookingUseCase: getIt<CreateBookingUseCase>(),
    updateBookingUseCase: getIt<UpdateBookingUseCase>(),
    cancelBookingUseCase: getIt<CancelBookingUseCase>(),
    getServicesUseCase: getIt<GetServicesUseCase>(),
    getAvailabilityUseCase: getIt<GetAvailabilityUseCase>(),
  );

  @lazySingleton
  UserBloc get userBloc => UserBloc(
    getDashboardUseCase: getIt<GetDashboardUseCase>(),
    getNotificationsUseCase: getIt<GetNotificationsUseCase>(),
    markNotificationReadUseCase: getIt<MarkNotificationReadUseCase>(),
    searchUseCase: getIt<SearchUseCase>(),
  );

  @lazySingleton
  ExternalBloc get externalBloc => ExternalBloc(
    getArticlesUseCase: getIt<GetArticlesUseCase>(),
    getCampaignsUseCase: getIt<GetCampaignsUseCase>(),
    getVeterinaryDataUseCase: getIt<GetVeterinaryDataUseCase>(),
    syncVaccinationsUseCase: getIt<SyncVaccinationsUseCase>(),
    getEmergencyContactsUseCase: getIt<GetEmergencyContactsUseCase>(),
  );

  @lazySingleton
  NotificationService get notificationService => NotificationServiceImpl();

  @lazySingleton
  SocketService get socketService => SocketServiceImpl(getIt<IO.Socket>());

  @lazySingleton
  FcmService get fcmService => FcmServiceImpl(getIt<NotificationService>());
}
