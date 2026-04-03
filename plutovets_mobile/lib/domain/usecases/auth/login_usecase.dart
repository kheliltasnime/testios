import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class LoginParams {
  final String email;
  final String password;

  LoginParams({required this.email, required this.password});
}

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase(this.repository);

  Future<User> call(LoginParams params) async {
    return await repository.signIn(params.email, params.password);
  }
}
