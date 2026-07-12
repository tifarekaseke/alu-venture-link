import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../../auth/data/models/app_user.dart';
import '../../../opportunities/data/models/opportunity_model.dart';
import '../models/application_model.dart';

class ApplicationRepository {
  final FirebaseFirestore _firestore;
  final FirebaseAuth _firebaseAuth;

  ApplicationRepository({
    FirebaseFirestore? firestore,
    FirebaseAuth? firebaseAuth,
  })  : _firestore =
            firestore ?? FirebaseFirestore.instance,
        _firebaseAuth =
            firebaseAuth ?? FirebaseAuth.instance;

  CollectionReference<Map<String, dynamic>>
      get _applications {
    return _firestore.collection('applications');
  }

  CollectionReference<Map<String, dynamic>>
      get _notifications {
    return _firestore.collection('notifications');
  }

  Stream<List<ApplicationModel>>
      watchStudentApplications(
    String studentId,
  ) {
    return _applications
        .where(
          'studentId',
          isEqualTo: studentId,
        )
        .snapshots()
        .map((snapshot) {
      final applications = snapshot.docs
          .map(ApplicationModel.fromDocument)
          .toList();

      applications.sort((a, b) {
        final aDate = a.submittedAt ??
            DateTime.fromMillisecondsSinceEpoch(0);

        final bDate = b.submittedAt ??
            DateTime.fromMillisecondsSinceEpoch(0);

        return bDate.compareTo(aDate);
      });

      return applications;
    });
  }

  Stream<List<ApplicationModel>>
      watchStartupApplications(
    String startupOwnerId,
  ) {
    return _applications
        .where(
          'startupOwnerId',
          isEqualTo: startupOwnerId,
        )
        .snapshots()
        .map((snapshot) {
      final applications = snapshot.docs
          .map(ApplicationModel.fromDocument)
          .toList();

      applications.sort((a, b) {
        final aDate = a.submittedAt ??
            DateTime.fromMillisecondsSinceEpoch(0);

        final bDate = b.submittedAt ??
            DateTime.fromMillisecondsSinceEpoch(0);

        return bDate.compareTo(aDate);
      });

      return applications;
    });
  }

  Future<bool> hasAlreadyApplied({
    required String studentId,
    required String opportunityId,
  }) async {
    final snapshot = await _applications
        .where(
          'studentId',
          isEqualTo: studentId,
        )
        .where(
          'opportunityId',
          isEqualTo: opportunityId,
        )
        .limit(1)
        .get();

    return snapshot.docs.isNotEmpty;
  }

  Future<void> submitApplication({
    required AppUser student,
    required OpportunityModel opportunity,
    required String coverLetter,
  }) async {
    final alreadyApplied = await hasAlreadyApplied(
      studentId: student.uid,
      opportunityId: opportunity.id,
    );

    if (alreadyApplied) {
      throw StateError(
        'You have already applied for this opportunity.',
      );
    }

    final applicationReference =
        _applications.doc();

    final notificationReference =
        _notifications.doc();

    final batch = _firestore.batch();

    batch.set(
      applicationReference,
      {
        'opportunityId': opportunity.id,
        'opportunityTitle': opportunity.title,
        'startupOwnerId': opportunity.ownerId,
        'startupName': opportunity.startupName,
        'studentId': student.uid,
        'studentName': student.fullName,
        'studentEmail': student.email,
        'coverLetter': coverLetter.trim(),
        'status': 'submitted',
        'submittedAt':
            FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
        'interviewDateTime': null,
        'interviewMode': '',
        'interviewLocationOrLink': '',
        'interviewNotes': '',
        'interviewScheduledBy': '',
        'interviewScheduledAt': null,
      },
    );

    batch.set(
      notificationReference,
      {
        'recipientId': opportunity.ownerId,
        'senderId': student.uid,
        'title': 'New application received',
        'message':
            '${student.fullName} applied for ${opportunity.title}.',
        'type': 'new_application',
        'referenceId': applicationReference.id,
        'isRead': false,
        'createdAt':
            FieldValue.serverTimestamp(),
      },
    );

    await batch.commit();
  }

  Future<void> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) async {
    final applicationReference =
        _applications.doc(applicationId);

    final snapshot =
        await applicationReference.get();

    final data = snapshot.data();

    if (!snapshot.exists || data == null) {
      throw StateError(
        'The application could not be found.',
      );
    }

    final previousStatus =
        data['status'] as String? ?? 'submitted';

    if (previousStatus == status) {
      return;
    }

    final studentId =
        data['studentId'] as String? ?? '';

    final opportunityTitle =
        data['opportunityTitle'] as String? ??
            'the opportunity';

    final startupName =
        data['startupName'] as String? ??
            'The startup';

    final actorId =
        _firebaseAuth.currentUser?.uid ??
            (data['startupOwnerId']
                    as String? ??
                '');

    final batch = _firestore.batch();

    batch.update(
      applicationReference,
      {
        'status': status,
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
    );

    if (studentId.isNotEmpty &&
        actorId.isNotEmpty) {
      final notificationReference =
          _notifications.doc();

      batch.set(
        notificationReference,
        {
          'recipientId': studentId,
          'senderId': actorId,
          'title': _statusTitle(status),
          'message':
              '$startupName moved your application for $opportunityTitle to ${_statusLabel(status)}.',
          'type': 'application_status',
          'referenceId': applicationId,
          'isRead': false,
          'createdAt':
              FieldValue.serverTimestamp(),
        },
      );
    }

    await batch.commit();
  }

  Future<void> scheduleInterview({
    required String applicationId,
    required DateTime interviewDateTime,
    required String interviewMode,
    required String locationOrLink,
    required String notes,
  }) async {
    final applicationReference =
        _applications.doc(applicationId);

    final snapshot =
        await applicationReference.get();

    final data = snapshot.data();

    if (!snapshot.exists || data == null) {
      throw StateError(
        'The application could not be found.',
      );
    }

    final studentId =
        data['studentId'] as String? ?? '';

    final opportunityTitle =
        data['opportunityTitle'] as String? ??
            'the opportunity';

    final startupName =
        data['startupName'] as String? ??
            'The startup';

    final startupOwnerId =
        data['startupOwnerId'] as String? ?? '';

    final actorId =
        _firebaseAuth.currentUser?.uid ??
            startupOwnerId;

    if (studentId.isEmpty) {
      throw StateError(
        'The student account could not be found.',
      );
    }

    final batch = _firestore.batch();

    batch.update(
      applicationReference,
      {
        'status': 'interview',
        'interviewDateTime':
            Timestamp.fromDate(interviewDateTime),
        'interviewMode': interviewMode.trim(),
        'interviewLocationOrLink':
            locationOrLink.trim(),
        'interviewNotes': notes.trim(),
        'interviewScheduledBy': actorId,
        'interviewScheduledAt':
            FieldValue.serverTimestamp(),
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
    );

    final notificationReference =
        _notifications.doc();

    batch.set(
      notificationReference,
      {
        'recipientId': studentId,
        'senderId': actorId,
        'title': 'Interview scheduled',
        'message':
            '$startupName scheduled an interview for your $opportunityTitle application.',
        'type': 'application_status',
        'referenceId': applicationId,
        'isRead': false,
        'createdAt':
            FieldValue.serverTimestamp(),
      },
    );

    await batch.commit();
  }

  Future<void> withdrawApplication(
    String applicationId,
  ) async {
    final applicationReference =
        _applications.doc(applicationId);

    final snapshot =
        await applicationReference.get();

    final data = snapshot.data();

    if (!snapshot.exists || data == null) {
      throw StateError(
        'The application could not be found.',
      );
    }

    final currentStatus =
        data['status'] as String? ?? '';

    if (currentStatus == 'withdrawn') {
      return;
    }

    final startupOwnerId =
        data['startupOwnerId'] as String? ?? '';

    final studentId =
        data['studentId'] as String? ?? '';

    final studentName =
        data['studentName'] as String? ??
            'A student';

    final opportunityTitle =
        data['opportunityTitle'] as String? ??
            'an opportunity';

    final actorId =
        _firebaseAuth.currentUser?.uid ??
            studentId;

    final batch = _firestore.batch();

    batch.update(
      applicationReference,
      {
        'status': 'withdrawn',
        'updatedAt':
            FieldValue.serverTimestamp(),
      },
    );

    if (startupOwnerId.isNotEmpty &&
        actorId.isNotEmpty) {
      final notificationReference =
          _notifications.doc();

      batch.set(
        notificationReference,
        {
          'recipientId': startupOwnerId,
          'senderId': actorId,
          'title': 'Application withdrawn',
          'message':
              '$studentName withdrew their application for $opportunityTitle.',
          'type': 'application_withdrawn',
          'referenceId': applicationId,
          'isRead': false,
          'createdAt':
              FieldValue.serverTimestamp(),
        },
      );
    }

    await batch.commit();
  }

  String _statusTitle(String status) {
    switch (status) {
      case 'underReview':
        return 'Application under review';
      case 'shortlisted':
        return 'You have been shortlisted';
      case 'interview':
        return 'Interview stage reached';
      case 'accepted':
        return 'Application accepted';
      case 'rejected':
        return 'Application update';
      default:
        return 'Application status updated';
    }
  }

  String _statusLabel(String status) {
    switch (status) {
      case 'underReview':
        return 'under review';
      case 'shortlisted':
        return 'shortlisted';
      case 'interview':
        return 'interview';
      case 'accepted':
        return 'accepted';
      case 'rejected':
        return 'rejected';
      case 'withdrawn':
        return 'withdrawn';
      default:
        return status;
    }
  }
}