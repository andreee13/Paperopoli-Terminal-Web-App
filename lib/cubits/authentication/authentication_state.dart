part of 'authentication_cubit.dart';

@immutable
abstract class AuthenticationState {
  const AuthenticationState();
}

class AuthenticationInitial extends AuthenticationState {
  const AuthenticationInitial();

  @override
  String toString() => 'Initial';
}

class AuthenticationLoading extends AuthenticationState {
  const AuthenticationLoading();

  @override
  String toString() => 'Logging';
}

class AuthenticationNotLogged extends AuthenticationState {
  const AuthenticationNotLogged();

  @override
  String toString() => 'Not logged';
}

class AuthenticationLogged extends AuthenticationState {
  final User? user;

  const AuthenticationLogged(
    this.user,
  );

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is AuthenticationLogged && other.user == user;
  }

  @override
  int get hashCode => user.hashCode;

  @override
  String toString() => 'Logged';
}

class AuthenticationError extends AuthenticationState {
  final Exception exception;

  const AuthenticationError(
    this.exception,
  );
}
