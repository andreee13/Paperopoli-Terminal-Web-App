import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:paperopoli_terminal/core/errors/exceptions.dart';
import 'package:paperopoli_terminal/data/repositories/user_repository.dart';

part 'authentication_state.dart';

class AuthenticationCubit extends Cubit<AuthenticationState> {
  final UserRepository repository;

  AuthenticationCubit({
    required this.repository,
  }) : super(
          const AuthenticationInitial(),
        );

  Future<void> login() async {
    try {
      emit(
        const AuthenticationLoading(),
      );
      if (await repository.isSignedIn()) {
        emit(
          AuthenticationLogged(
            await repository.getUser(),
          ),
        );
      } else {
        emit(
          const AuthenticationNotLogged(),
        );
      }
    } on AuthenticationException catch (e) {
      emit(
        AuthenticationError(e),
      );
    }
  }

  Future<void> logOut() async {
    try {
      emit(
        const AuthenticationLoading(),
      );
      if (await repository.logOut() != null) {
        emit(
          AuthenticationLogged(
            await repository.getUser(),
          ),
        );
      } else {
        emit(
          const AuthenticationNotLogged(),
        );
      }
    } on AuthenticationException catch (e) {
      emit(
        AuthenticationError(e),
      );
    }
  }

  Future<void> signUpWithCredentials({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      emit(
        const AuthenticationLoading(),
      );
      if (await repository.signUpWithEmailPassword(
            email: email,
            password: password,
            fullName: fullName,
          ) !=
          null) {
        emit(
          AuthenticationLogged(
            await repository.getUser(),
          ),
        );
      } else {
        emit(
          const AuthenticationNotLogged(),
        );
      }
    } on Exception catch (e) {
      emit(
        AuthenticationError(
          e,
        ),
      );
    }
  }

  Future<void> logInWithCredentials({
    required String email,
    required String password,
  }) async {
    try {
      emit(
        const AuthenticationLoading(),
      );
      if (await repository.signInWithEmailPassword(
            email: email,
            password: password,
          ) !=
          null) {
        emit(
          AuthenticationLogged(
            await repository.getUser(),
          ),
        );
      } else {
        emit(
          const AuthenticationNotLogged(),
        );
      }
    } on AuthenticationException catch (e) {
      emit(
        AuthenticationError(
          e,
        ),
      );
    }
  }
}
