
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
    String? fcmToken,
    
  }) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      final user = await _authRepository.emailPhoneDetails(
        email: email,
        phoneNumber: phoneNumber,
        fcmToken: fcmToken,
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

    emit(state.copyWith(status: AuthStatus.authenticated));    

    }catch(e){
      emit(state.copyWith(status: AuthStatus.error, error: e.toString()));
    }
  }


  Future<void> deviceIdDetails({
    required String deviceId,
  }) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      final user = await _authRepository.deviceIdDetails(
        deviceId: deviceId,
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


  Future<void> deviceFcmToken({
  required String fcmToken,
  }) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      final user = await _authRepository.deviceFcmToken(
        fcmToken: fcmToken,
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
  


  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    try {
      emit(state.copyWith(status: AuthStatus.loading));
      final user = await _authRepository.signIn(
        email: email,
        password: password,
      );
      emit(state.copyWith(
        status: AuthStatus.authenticated,
        user: user,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: AuthStatus.error,
        error: 'email/password are incorrect, Please enter correct email/password',
        
      ));
    }
  }

  @override
  Future<void> close() {
    _authStateSubscription?.cancel();
    return super.close();
  }
}