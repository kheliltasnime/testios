import '../../repositories/auth_repository.dart';

class ResetPasswordParams {
  final String token;
  final String password;
  ResetPasswordParams({required this.token, required this.password});
}

class ResetPasswordUseCase {
  final AuthRepository repository;
  ResetPasswordUseCase(this.repository);
  Future<void> call(ResetPasswordParams params) async {
    return await repository.resetPassword(params.token, params.password);
  }
}
