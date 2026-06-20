import 'package:fpdart/fpdart.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/entities/user.dart';
import '../../../domain/repositories/auth_repository.dart';
import '../datasources/remote/firebase_auth_service.dart';
import '../datasources/remote/firestore_service.dart';
import '../datasources/local/secure_storage_service.dart';

part 'auth_repository_impl.g.dart';

@riverpod
AuthRepository authRepository(AuthRepositoryRef ref) {
  return AuthRepositoryImpl(
    ref.watch(firebaseAuthServiceProvider),
    ref.watch(firestoreServiceProvider),
    ref.watch(secureStorageServiceProvider),
  );
}

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _authService;
  final FirestoreService _firestoreService;
  final SecureStorageService _secureStorage;

  AuthRepositoryImpl(this._authService, this._firestoreService, this._secureStorage);

  @override
  Stream<User?> get authStateChanges {
    return _authService.authStateChanges.asyncMap((firebaseUser) async {
      if (firebaseUser == null) {
        await _secureStorage.deleteUserId();
        return null;
      }
      
      try {
        final user = await _firestoreService.getUserProfile(firebaseUser.uid);
        if (user != null) {
          await _secureStorage.saveUserId(user.id);
          return user;
        }
      } catch (e) {
        // Fallback if Firestore is unavailable (e.g. offline on first login)
        final fallbackUser = User(
          id: firebaseUser.uid,
          name: firebaseUser.displayName ?? 'User',
          email: firebaseUser.email ?? '',
        );
        await _secureStorage.saveUserId(fallbackUser.id);
        return fallbackUser;
      }
      return null;
    });
  }

  @override
  Future<User?> getCurrentUser() async {
    final firebaseUser = _authService.currentUser;
    if (firebaseUser != null) {
      return await _firestoreService.getUserProfile(firebaseUser.uid);
    }
    return null;
  }

  @override
  Future<Either<String, User>> signIn({
    required String email,
    required String password,
  }) async {
    final result = await _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    return result.bind((firebaseUser) {
      // In a real scenario we'd fetch the user profile from firestore here
      // But since we are returning a future, we can map it via an async task or just return Right and let stream handle UI update
      return Right(User(id: firebaseUser.uid, email: firebaseUser.email ?? '', name: firebaseUser.displayName ?? ''));
    });
  }

  @override
  Future<Either<String, User>> signUp({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await _authService.createUserWithEmailAndPassword(
      email: email,
      password: password,
      name: name,
    );

    return await result.fold(
      (error) async => Left(error),
      (firebaseUser) async {
        final user = User(id: firebaseUser.uid, name: name, email: email);
        await _firestoreService.createUserProfile(user);
        return Right(user);
      },
    );
  }

  @override
  Future<Either<String, User>> signInWithGoogle() async {
    final result = await _authService.signInWithGoogle();

    return await result.fold(
      (error) async => Left(error),
      (firebaseUser) async {
        // Create user in firestore if it doesn't exist, otherwise just fetch
        final existingUser = await _firestoreService.getUserProfile(firebaseUser.uid);
        if (existingUser == null) {
          final newUser = User(
            id: firebaseUser.uid, 
            name: firebaseUser.displayName ?? 'Google User', 
            email: firebaseUser.email ?? '',
          );
          await _firestoreService.createUserProfile(newUser);
          return Right(newUser);
        }
        return Right(existingUser);
      },
    );
  }

  @override
  Future<void> signOut() async {
    await _secureStorage.clearAll();
    await _authService.signOut();
  }
}
