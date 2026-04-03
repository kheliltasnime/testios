import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class GetCurrentUserUseCase {
  final AuthRepository repository;
  GetCurrentUserUseCase(this.repository);
  Future<User?> call(NoParams params) async {
    return await repository.getCurrentUser();
  }
}
