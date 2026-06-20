import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:fpdart/fpdart.dart';

part 'firebase_auth_service.g.dart';

@Riverpod(keepAlive: true)
FirebaseAuthService firebaseAuthService(FirebaseAuthServiceRef ref) {
  return FirebaseAuthService(firebase_auth.FirebaseAuth.instance);
}

class FirebaseAuthService {
  final firebase_auth.FirebaseAuth _firebaseAuth;

  FirebaseAuthService(this._firebaseAuth);

  Stream<firebase_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();
  firebase_auth.User? get currentUser => _firebaseAuth.currentUser;

  Future<Either<String, firebase_auth.User>> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      if (userCredential.user != null) {
        return Right(userCredential.user!);
      }
      return const Left('Unknown error occurred during sign in.');
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(e.message ?? 'Authentication failed');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, firebase_auth.User>> createUserWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      
      if (userCredential.user != null) {
        // Update display name
        await userCredential.user!.updateDisplayName(name);
        return Right(userCredential.user!);
      }
      return const Left('Unknown error occurred during sign up.');
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(e.message ?? 'Registration failed');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<Either<String, firebase_auth.User>> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) {
        return const Left('Google sign in was cancelled');
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final firebase_auth.OAuthCredential credential = firebase_auth.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _firebaseAuth.signInWithCredential(credential);
      
      if (userCredential.user != null) {
        return Right(userCredential.user!);
      }
      return const Left('Unknown error occurred during Google sign in.');
    } on firebase_auth.FirebaseAuthException catch (e) {
      return Left(e.message ?? 'Google Authentication failed');
    } catch (e) {
      return Left(e.toString());
    }
  }

  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _firebaseAuth.signOut();
  }
}
