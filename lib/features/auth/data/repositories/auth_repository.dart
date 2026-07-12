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

  User? get currentUser {
    return _firebaseAuth.currentUser;
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
    final reference = _firestore.collection('users').doc(uid);

    // First try the locally cached profile.
    try {
      final cachedDocument = await reference
          .get(const GetOptions(source: Source.cache))
          .timeout(const Duration(seconds: 3));

      final cachedUser = _mapUser(cachedDocument);

      if (cachedUser != null) {
        return cachedUser;
      }
    } on FirebaseException {
      // A cache miss can happen on a fresh installation.
    } on TimeoutException {
      // Continue and request the document from the server.
    }

    // If the profile is not cached, request it from Firestore.
    final serverDocument = await reference
        .get(const GetOptions(source: Source.server))
        .timeout(
          const Duration(seconds: 15),
          onTimeout: () {
            throw TimeoutException(
              'Could not load your profile from Cloud Firestore. '
              'Check the emulator internet connection and try again.',
            );
          },
        );

    return _mapUser(serverDocument);
  }

  Stream<AppUser?> watchUserProfile(String uid) {
    return _firestore.collection('users').doc(uid).snapshots().map(_mapUser);
  }

  AppUser? _mapUser(DocumentSnapshot<Map<String, dynamic>> document) {
    final data = document.data();

    if (!document.exists || data == null) {
      return null;
    }

    return AppUser.fromMap(document.id, data);
  }
}
