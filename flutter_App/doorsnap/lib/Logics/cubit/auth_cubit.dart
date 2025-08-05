

import 'dart:async';

import 'package:doorsnap/Data/Repository/auth_repository.dart';
import 'package:doorsnap/Logics/cubit/auth_state.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;
  StreamSubscription<User?>? _authStateSubscription;

  AuthCubit({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AuthState()) ;

  

//       this will called after otp verification -creates anonymous user with email/phone

  Future<void> emailPhoneDetails({
    
    required String email,
    required String phoneNumber,
    
  }) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      final user = await _authRepository.emailPhoneDetails(
        email: email,
        phoneNumber: phoneNumber,
      );
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      ));
    }
  }



    Future<void> userDetails({
    required String fullName,
    required String username,
    required String address,
  }) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      final user = await _authRepository.userDetails(
        fullName: fullName,
        username: username,
        address: address,
      );
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: e.toString(),
      ));
    }
  }

  Future<void> linkPasswordToAccount({
    required String email,
    required String password
  }) async {
    try{
      emit(state.copyWith(status: AuthStatus.loading));

     _authRepository.linkEmailPassword(
      email: email,
      password: password,
    );

    emit(state.copyWith(status: AuthStatus.authenticated));    // here is change user: user in original

    }catch(e){
      emit(state.copyWith(status: AuthStatus.error, error: e.toString()));
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}