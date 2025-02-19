part of 'auth_bloc.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object> get props => [];
}

class CheckAuth extends AuthEvent {
  const CheckAuth();
}

class UpdateUserProfile extends AuthEvent {
  final MyUser updatedUser;

  const UpdateUserProfile(this.updatedUser);
}

class SendOtp extends AuthEvent {
  final String phone;
  final Function errorStep;
  final Function nextStep;

  const SendOtp(this.phone, this.errorStep, this.nextStep);
}

class SignInUser extends AuthEvent {
  final String otp;
  final String phone;

  const SignInUser(this.otp, this.phone);
}

class GetMyUser extends AuthEvent {
  final String myUserId;

  const GetMyUser({required this.myUserId});

  @override
  List<Object> get props => [myUserId];
}

class SignOutUser extends AuthEvent {
  const SignOutUser();
}
