import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class RegisterParams {
  final String email;
  final String password;
  final String firstName;
  final String lastName;
  final String? phone;
  final String? address;

  RegisterParams({
    required this.email,
    required this.password,
    required this.firstName,
    required this.lastName,
    this.phone,
    this.address,
  });
}

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase(this.repository);

  Future<User> call(RegisterParams params) async {
    return await repository.signUp(
      params.email,
      params.password,
      params.firstName,
      params.lastName,
    );
  }
}
