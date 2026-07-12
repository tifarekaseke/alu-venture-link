import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/app_user.dart';
import '../../data/repositories/auth_repository.dart';
import 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<AppUser?>? _profileSubscription;

  AuthCubit(this._authRepository) : super(const AuthInitial()) {
    _observeAuthentication();
  }

  void _observeAuthentication() {
    _authSubscription = _authRepository.authStateChanges.listen(
      _handleAuthenticationChange,
      onError: (Object error) {
        emit(AuthFailure(_friendlyError(error)));
      },
    );
  }

  Future<void> _handleAuthenticationChange(User? firebaseUser) async {
    await _profileSubscription?.cancel();

    if (firebaseUser == null) {
      emit(const AuthUnauthenticated());
      return;
    }

    emit(const AuthLoading());

    try {
      final profile = await _authRepository.getUserProfile(firebaseUser.uid);

      if (profile == null) {
        await _authRepository.signOut();

        emit(
          const AuthFailure(
            'Your account exists, but your Firestore profile was not found.',
          ),
        );
        return;
      }

      emit(AuthAuthenticated(profile));

      _profileSubscription = _authRepository
          .watchUserProfile(firebaseUser.uid)
          .listen(
            (updatedProfile) {
              if (updatedProfile != null) {
                emit(AuthAuthenticated(updatedProfile));
              }
            },
            onError: (Object error) {
              // Keep the last successfully loaded profile visible.
              // A temporary Firestore interruption should not log the user out.
            },
          );
    } catch (error) {
      final message = _friendlyError(error);

      emit(AuthFailure(message));

      await Future<void>.delayed(const Duration(milliseconds: 100));

      emit(const AuthUnauthenticated());
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    emit(const AuthLoading());

    try {
      await _authRepository.register(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
      );
    } catch (error) {
      emit(AuthFailure(_friendlyError(error)));
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthLoading());

    try {
      await _authRepository.signIn(email: email, password: password);
    } catch (error) {
      emit(AuthFailure(_friendlyError(error)));
    }
  }

  Future<void> signOut() async {
    try {
      await _authRepository.signOut();
    } catch (error) {
      emit(AuthFailure(_friendlyError(error)));
    }
  }

  Future<void> resetPassword(String email) async {
    emit(const AuthLoading());

    try {
      await _authRepository.sendPasswordResetEmail(email);
      emit(const AuthUnauthenticated());
    } catch (error) {
      emit(AuthFailure(_friendlyError(error)));
    }
  }

  String _friendlyError(Object error) {
    if (error is TimeoutException) {
      return error.message ??
          'The request took too long. Check your internet connection.';
    }

    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'email-already-in-use':
          return 'An account already exists for this email.';
        case 'invalid-email':
          return 'Enter a valid email address.';
        case 'weak-password':
          return 'Use a password with at least 6 characters.';
        case 'user-not-found':
          return 'No account was found for this email.';
        case 'wrong-password':
        case 'invalid-credential':
          return 'The email or password is incorrect.';
        case 'too-many-requests':
          return 'Too many attempts. Wait briefly and try again.';
        case 'network-request-failed':
          return 'Firebase could not connect. Check your internet connection.';
        default:
          return error.message ?? 'Authentication could not be completed.';
      }
    }

    if (error is FirebaseException) {
      switch (error.code) {
        case 'unavailable':
          return 'Cloud Firestore is currently unreachable. Change networks and retry.';
        case 'permission-denied':
          return 'Firestore denied the request. Check your security rules.';
        default:
          return error.message ?? 'A Firebase error occurred.';
      }
    }

    return 'Something went wrong: $error';
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    await _profileSubscription?.cancel();
    return super.close();
  }
}
