part of 'auth_bloc.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object> get props => [];
}

class AuthInitialState extends AuthState {}

class AuthLoggedOutState extends AuthState {}

class AuthOtpState extends AuthState {}

class AuthLoadingState extends AuthState {
  const AuthLoadingState();
}

class AuthSuccessState extends AuthState {
  final MyUser user;

  const AuthSuccessState(this.user);

  @override
  List<Object> get props => [user];
}

class AuthFailureState extends AuthState {
  final String errorMessage;

  const AuthFailureState(this.errorMessage);

  @override
  List<Object> get props => [errorMessage];
}
