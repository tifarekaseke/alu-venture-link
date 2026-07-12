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

  Future<void>? _activeProfileLoad;
  String? _loadingUid;
  bool _registrationInProgress = false;

  AuthCubit(this._authRepository) : super(const AuthInitial()) {
    _observeAuthentication();
  }

  void _observeAuthentication() {
    _authSubscription = _authRepository.authStateChanges.listen(
      (firebaseUser) {
        unawaited(_handleAuthenticationChange(firebaseUser));
      },
      onError: (Object error) {
        if (!isClosed) {
          emit(AuthFailure(_friendlyError(error)));
        }
      },
    );
  }

  Future<void> _handleAuthenticationChange(User? firebaseUser) async {
    /*
      Firebase emits an authentication event immediately after account
      creation. During registration, the Firestore profile may still be
      in the process of being created, so registration loads the profile
      itself after the write finishes.
    */
    if (_registrationInProgress && firebaseUser != null) {
      return;
    }

    if (firebaseUser == null) {
      await _cancelProfileSubscription();

      _loadingUid = null;
      _activeProfileLoad = null;

      if (!isClosed) {
        emit(const AuthUnauthenticated());
      }

      return;
    }

    await _loadProfile(firebaseUser);
  }

  Future<void> _loadProfile(User firebaseUser) async {
    /*
      The authentication stream and the sign-in method may both request
      the profile at nearly the same time. This prevents duplicate loads.
    */
    if (_loadingUid == firebaseUser.uid && _activeProfileLoad != null) {
      await _activeProfileLoad;
      return;
    }

    _loadingUid = firebaseUser.uid;

    final operation = _performProfileLoad(firebaseUser);
    _activeProfileLoad = operation;

    try {
      await operation;
    } finally {
      if (identical(_activeProfileLoad, operation)) {
        _activeProfileLoad = null;
        _loadingUid = null;
      }
    }
  }

  Future<void> _performProfileLoad(User firebaseUser) async {
    await _cancelProfileSubscription();

    if (isClosed) {
      return;
    }

    emit(const AuthLoading());

    try {
      final profile = await _authRepository.getUserProfile(firebaseUser.uid);

      if (profile == null) {
        if (!isClosed) {
          emit(
            const AuthFailure(
              'Your account exists, but its Firestore profile '
              'was not found.',
            ),
          );
        }

        await _authRepository.signOut();
        return;
      }

      if (isClosed) {
        return;
      }

      emit(AuthAuthenticated(profile));

      /*
        After the initial profile has loaded, continue listening for
        profile changes in real time.
      */
      _profileSubscription = _authRepository
          .watchUserProfile(firebaseUser.uid)
          .listen(
            (updatedProfile) {
              if (!isClosed && updatedProfile != null) {
                emit(AuthAuthenticated(updatedProfile));
              }
            },
            onError: (Object error) {
              /*
                Keep the last successfully loaded profile visible if
                the real-time Firestore listener temporarily disconnects.
              */
            },
          );
    } catch (error) {
      if (!isClosed) {
        emit(AuthFailure(_friendlyError(error)));
      }
    }
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    emit(const AuthLoading());
    _registrationInProgress = true;

    try {
      await _authRepository.register(
        fullName: fullName,
        email: email,
        password: password,
        role: role,
      );

      final firebaseUser = _authRepository.currentUser;

      if (firebaseUser == null) {
        throw StateError(
          'Registration completed, but Firebase returned '
          'no current user.',
        );
      }

      await _loadProfile(firebaseUser);
    } catch (error) {
      if (!isClosed) {
        emit(AuthFailure(_friendlyError(error)));
      }
    } finally {
      _registrationInProgress = false;
    }
  }

  Future<void> signIn({required String email, required String password}) async {
    emit(const AuthLoading());

    try {
      await _authRepository.signIn(email: email, password: password);

      /*
        Load the profile directly after sign-in instead of depending
        only on authStateChanges.
      */
      final firebaseUser = _authRepository.currentUser;

      if (firebaseUser == null) {
        throw StateError(
          'Login completed, but Firebase returned no current user.',
        );
      }

      await _loadProfile(firebaseUser);
    } catch (error) {
      if (!isClosed) {
        emit(AuthFailure(_friendlyError(error)));
      }
    }
  }

  Future<void> retryCurrentProfile() async {
    final firebaseUser = _authRepository.currentUser;

    if (firebaseUser == null) {
      emit(const AuthUnauthenticated());
      return;
    }

    await _loadProfile(firebaseUser);
  }

  Future<void> signOut() async {
    try {
      await _cancelProfileSubscription();
      await _authRepository.signOut();

      if (!isClosed) {
        emit(const AuthUnauthenticated());
      }
    } catch (error) {
      if (!isClosed) {
        emit(AuthFailure(_friendlyError(error)));
      }
    }
  }

  Future<void> resetPassword(String email) async {
    emit(const AuthLoading());

    try {
      await _authRepository.sendPasswordResetEmail(email);

      if (!isClosed) {
        emit(const AuthUnauthenticated());
      }
    } catch (error) {
      if (!isClosed) {
        emit(AuthFailure(_friendlyError(error)));
      }
    }
  }

  Future<void> _cancelProfileSubscription() async {
    final subscription = _profileSubscription;
    _profileSubscription = null;

    if (subscription == null) {
      return;
    }

    try {
      await subscription.cancel().timeout(const Duration(seconds: 3));
    } on TimeoutException {
      /*
        Do not allow a slow stream cancellation to keep the login
        screen loading forever.
      */
    }
  }

  String _friendlyError(Object error) {
    if (error is TimeoutException) {
      return error.message ??
          'The request took too long. '
              'Check your internet connection.';
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
          return 'Firebase Authentication could not connect. '
              'Check your internet connection.';

        default:
          return error.message ?? 'Authentication could not be completed.';
      }
    }

    if (error is FirebaseException) {
      switch (error.code) {
        case 'unavailable':
          return 'Cloud Firestore is unreachable from this device. '
              'Check the emulator connection or restart the emulator.';

        case 'permission-denied':
          return 'Firestore denied the profile request. '
              'Check the published security rules.';

        default:
          return error.message ?? 'A Firebase error occurred.';
      }
    }

    if (error is StateError) {
      return error.message.toString();
    }

    return 'Something went wrong: $error';
  }

  @override
  Future<void> close() async {
    await _authSubscription?.cancel();
    await _cancelProfileSubscription();

    return super.close();
  }
}
