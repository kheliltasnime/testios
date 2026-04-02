import '../../repositories/auth_repository.dart';

class NoParams {}

class LogoutUseCase {
  final AuthRepository repository;

  LogoutUseCase(this.repository);

  Future<void> call(NoParams params) async {
    return await repository.logout();
  }
}
