

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



  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}