import 'package:fpdart/fpdart.dart';
import '../entities/user.dart';

abstract class AuthRepository {
  Stream<User?> get authStateChanges;
  
  Future<Either<String, User>> signIn({
    required String email,
    required String password,
  });

  Future<Either<String, User>> signUp({
    required String name,
    required String email,
    required String password,
  });

  Future<Either<String, User>> signInWithGoogle();

  Future<void> signOut();
  
  Future<User?> getCurrentUser();
}
