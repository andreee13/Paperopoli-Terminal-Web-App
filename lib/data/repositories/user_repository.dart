import 'package:firebase_auth/firebase_auth.dart';
import 'package:paperopoli_terminal/core/errors/exceptions.dart';

class UserRepository {
  final FirebaseAuth firebaseAuth;

  UserRepository({
    required this.firebaseAuth,
  });

  Future<User?> signUpWithEmailPassword({
    required String fullName,
    required String email,
    required String password,
  }) async =>
      await firebaseAuth
          .createUserWithEmailAndPassword(
            email: email,
            password: password,
          )
          .then(
            (userCredential) => userCredential.user!
              ..updateProfile(
                displayName: fullName,
              ),
          );

  Future<User?> signInWithEmailPassword({
    required String email,
    required String password,
  }) async =>
      await firebaseAuth
          .signInWithEmailAndPassword(
            email: email,
            password: password,
          )
          .then(
            (result) => result.user,
          )
          .catchError(
            (e) => throw AuthenticationException(
              e,
            ),
          );

  Future<User?> logOut() async {
    await firebaseAuth.signOut();
    return firebaseAuth.currentUser;
  }

  Future<bool> isSignedIn() async => firebaseAuth.currentUser != null;

  Future<User?> getUser() async => firebaseAuth.currentUser;
}
