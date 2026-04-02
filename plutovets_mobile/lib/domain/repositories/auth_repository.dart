import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> signIn(String email, String password);
  Future<User> signUp(String email, String password, String firstName, String lastName);
  Future<void> forgotPassword(String email);
  Future<void> resetPassword(String token, String password);
  Future<void> logout();
  Future<User?> getCurrentUser();
}
