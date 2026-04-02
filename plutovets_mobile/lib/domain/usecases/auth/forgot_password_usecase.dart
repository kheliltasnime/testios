import '../../repositories/auth_repository.dart';

class ForgotPasswordParams {
  final String email;
  ForgotPasswordParams({required this.email});
}

class ForgotPasswordUseCase {
  final AuthRepository repository;
  ForgotPasswordUseCase(this.repository);
  Future<void> call(ForgotPasswordParams params) async {
    return await repository.forgotPassword(params.email);
  }
}
