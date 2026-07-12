import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../auth/data/models/app_user.dart';
import '../models/startup_profile_model.dart';

class StartupRepository {
  final FirebaseFirestore _firestore;

  StartupRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _startups {
    return _firestore.collection('startups');
  }

  CollectionReference<Map<String, dynamic>> get _notifications {
    return _firestore.collection('notifications');
  }

  Stream<StartupProfileModel?> watchStartupProfile(
    String ownerId,
  ) {
    return _startups.doc(ownerId).snapshots().map((document) {
      if (!document.exists || document.data() == null) {
        return null;
      }

      return StartupProfileModel.fromDocument(document);
    });
  }

  Stream<List<StartupProfileModel>> watchPendingProfiles() {
    return _startups
        .where(
          'verificationStatus',
          isEqualTo: 'pending',
        )
        .snapshots()
        .map((snapshot) {
      final profiles = snapshot.docs
          .map(StartupProfileModel.fromDocument)
          .toList();

      profiles.sort((a, b) {
        final aDate =
            a.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate =
            b.updatedAt ?? DateTime.fromMillisecondsSinceEpoch(0);

        return bDate.compareTo(aDate);
      });

      return profiles;
    });
  }

  Future<void> submitProfile({
    required AppUser owner,
    required String startupName,
    required String description,
    required String industry,
    required String ventureStage,
    required String recognitionType,
    required String recognitionReference,
    required String website,
  }) async {
    final document = _startups.doc(owner.uid);
    final existingDocument = await document.get();

    final data = <String, dynamic>{
      'ownerId': owner.uid,
      'ownerName': owner.fullName,
      'ownerEmail': owner.email,
      'startupName': startupName.trim(),
      'description': description.trim(),
      'industry': industry,
      'ventureStage': ventureStage,
      'recognitionType': recognitionType,
      'recognitionReference':
          recognitionReference.trim(),
      'website': website.trim(),
      'verificationStatus': 'pending',
      'rejectionReason': '',
      'verifiedBy': '',
      'verifiedAt': null,
      'updatedAt': FieldValue.serverTimestamp(),
    };

    if (!existingDocument.exists) {
      data['createdAt'] = FieldValue.serverTimestamp();
    }

    await document.set(
      data,
      SetOptions(merge: true),
    );
  }

  Future<void> approveProfile({
    required String profileId,
    required String adminId,
  }) async {
    final startupReference = _startups.doc(profileId);
    final notificationReference = _notifications.doc();
    final batch = _firestore.batch();

    batch.update(startupReference, {
      'verificationStatus': 'approved',
      'rejectionReason': '',
      'verifiedBy': adminId,
      'verifiedAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.set(notificationReference, {
      'recipientId': profileId,
      'senderId': adminId,
      'title': 'Startup verification approved',
      'message':
          'Your startup has been verified. You can now publish opportunities.',
      'type': 'verification_approved',
      'referenceId': profileId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }

  Future<void> rejectProfile({
    required String profileId,
    required String adminId,
    required String reason,
  }) async {
    final startupReference = _startups.doc(profileId);
    final notificationReference = _notifications.doc();
    final batch = _firestore.batch();

    batch.update(startupReference, {
      'verificationStatus': 'rejected',
      'rejectionReason': reason.trim(),
      'verifiedBy': adminId,
      'verifiedAt': null,
      'updatedAt': FieldValue.serverTimestamp(),
    });

    batch.set(notificationReference, {
      'recipientId': profileId,
      'senderId': adminId,
      'title': 'Startup verification needs changes',
      'message':
          'Your startup verification was not approved: ${reason.trim()}',
      'type': 'verification_rejected',
      'referenceId': profileId,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });

    await batch.commit();
  }
}