import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/app_user.dart';

class AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;

  AuthRepository({FirebaseAuth? firebaseAuth, FirebaseFirestore? firestore})
    : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
      _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<User?> get authStateChanges {
    return _firebaseAuth.authStateChanges();
  }

  Future<void> register({
    required String fullName,
    required String email,
    required String password,
    required String role,
  }) async {
    final normalizedEmail = email.trim().toLowerCase();

    final credential = await _firebaseAuth
        .createUserWithEmailAndPassword(
          email: normalizedEmail,
          password: password,
        )
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () {
            throw TimeoutException(
              'Registration took too long. Check your internet connection.',
            );
          },
        );

    final firebaseUser = credential.user;

    if (firebaseUser == null) {
      throw StateError('Firebase did not return a user account.');
    }

    await firebaseUser
        .updateDisplayName(fullName.trim())
        .timeout(const Duration(seconds: 15));

    await _firestore
        .collection('users')
        .doc(firebaseUser.uid)
        .set({
          'uid': firebaseUser.uid,
          'fullName': fullName.trim(),
          'email': normalizedEmail,
          'role': role,
          'campus': 'ALU Rwanda',
          'program': '',
          'skills': <String>[],
          'profileImageUrl': '',
          'profileCompleted': false,
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        })
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () {
            throw TimeoutException(
              'The account was created, but the profile could not be saved. '
              'Check your connection and sign in again.',
            );
          },
        );
  }

  Future<void> signIn({required String email, required String password}) async {
    await _firebaseAuth
        .signInWithEmailAndPassword(
          email: email.trim().toLowerCase(),
          password: password,
        )
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () {
            throw TimeoutException(
              'Login took too long. Check your internet connection.',
            );
          },
        );
  }

  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  Future<void> sendPasswordResetEmail(String email) async {
    await _firebaseAuth
        .sendPasswordResetEmail(email: email.trim().toLowerCase())
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () {
            throw TimeoutException(
              'Password reset took too long. Check your connection.',
            );
          },
        );
  }

  Future<AppUser?> getUserProfile(String uid) async {
    final document = await _firestore
        .collection('users')
        .doc(uid)
        .get()
        .timeout(
          const Duration(seconds: 20),
          onTimeout: () {
            throw TimeoutException(
              'Could not load your profile. Check your internet connection.',
            );
          },
        );

    final data = document.data();

    if (!document.exists || data == null) {
      return null;
    }

    return AppUser.fromMap(document.id, data);
  }

  Stream<AppUser?> watchUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map((document) {
      final data = document.data();

      if (!document.exists || data == null) {
        return null;
      }

      return AppUser.fromMap(document.id, data);
    });
  }
}
