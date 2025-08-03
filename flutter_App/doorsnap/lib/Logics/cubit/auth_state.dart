

import 'package:doorsnap/Data/Models/user_model.dart';
import 'package:equatable/equatable.dart';

enum AuthStatus {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
  // passwordResetRequested,
  // emailVerificationSent,
  // emailVerified,
  // passwordChanged,
  // accountCreated,
  // accountDeleted
}

class AuthState extends Equatable{
  final AuthStatus status;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.error,
    });

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
      error: error ?? this.error,
    );
  }
  
  @override
  List<Object?> get props => [status, user , error ];
  
  


}