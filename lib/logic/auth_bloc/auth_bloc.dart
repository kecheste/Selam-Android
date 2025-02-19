import 'dart:async';

import 'package:selam/data/models/user_model.dart';
import 'package:selam/data/repositories/auth.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final AuthRepository authRepository;
  StreamSubscription<MyUser>? _userSubscription;

  AuthBloc({required this.authRepository}) : super(AuthInitialState()) {
    on<AuthEvent>((event, emit) {});

    on<CheckAuth>((event, emit) async {
      emit(AuthLoadingState());
      try {
        User? firebaseUser = FirebaseAuth.instance.currentUser;

        if (firebaseUser != null) {
          await _userSubscription?.cancel();

          _userSubscription =
              authRepository.getUserStream(firebaseUser.uid).listen(
            (user) {
              add(UpdateUserProfile(user));
            },
            onError: (error) {
              emit(AuthFailureState("CheckAuth Error: ${error.toString()}"));
            },
          );
        } else {
          emit(AuthLoggedOutState());
        }
      } catch (e) {
        emit(AuthFailureState("CheckAuth Error: ${e.toString()}"));
      }
    });

    on<UpdateUserProfile>((event, emit) async {
      try {
        MyUser updatedUser = await authRepository.updateUser(event.updatedUser);
        emit(AuthSuccessState(updatedUser));
      } catch (e) {
        emit(AuthFailureState("UpdateUserProfile Error: ${e.toString()}"));
      }
    });

    on<GetMyUser>((event, emit) async {
      emit(AuthLoadingState());
      try {
        MyUser user = await authRepository.getMyUser(event.myUserId);
        emit(AuthSuccessState(user));
      } catch (e) {
        emit(AuthFailureState("GetMyUser Error: ${e.toString()}"));
      }
    });

    on<SendOtp>((event, emit) async {
      emit(AuthLoadingState());
      try {
        await authRepository.sendOtp(
            phone: event.phone,
            errorStep: event.errorStep,
            nextStep: event.nextStep);
        emit(AuthOtpState());
      } catch (e) {
        emit(AuthFailureState("SendOtp Error: ${e.toString()}"));
      }
    });

    on<SignInUser>((event, emit) async {
      emit(AuthLoadingState());
      try {
        final MyUser user = await authRepository.loginWithOtp(
            otp: event.otp, phone: event.phone);
        emit(AuthSuccessState(user));
      } catch (e) {
        emit(AuthFailureState("SignInUser Error: ${e.toString()}"));
      }
    });

    on<SignOutUser>((event, emit) async {
      emit(AuthLoadingState());
      try {
        authRepository.signOut();
        emit(AuthLoggedOutState());
      } catch (e) {
        emit(AuthFailureState("SignOutUser Error: ${e.toString()}"));
      }
    });
  }
}
