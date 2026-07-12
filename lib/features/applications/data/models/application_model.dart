import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class ApplicationModel extends Equatable {
  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String startupOwnerId;
  final String startupName;
  final String studentId;
  final String studentName;
  final String studentEmail;
  final String coverLetter;
  final String status;
  final DateTime? submittedAt;
  final DateTime? updatedAt;

  final DateTime? interviewDateTime;
  final String interviewMode;
  final String interviewLocationOrLink;
  final String interviewNotes;
  final String interviewScheduledBy;
  final DateTime? interviewScheduledAt;

  const ApplicationModel({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupOwnerId,
    required this.startupName,
    required this.studentId,
    required this.studentName,
    required this.studentEmail,
    required this.coverLetter,
    required this.status,
    required this.interviewMode,
    required this.interviewLocationOrLink,
    required this.interviewNotes,
    required this.interviewScheduledBy,
    this.submittedAt,
    this.updatedAt,
    this.interviewDateTime,
    this.interviewScheduledAt,
  });

  bool get hasInterview {
    return interviewDateTime != null &&
        interviewMode.trim().isNotEmpty;
  }

  bool get canWithdraw {
    return status != 'accepted' &&
        status != 'rejected' &&
        status != 'withdrawn';
  }

  factory ApplicationModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    DateTime? readDate(dynamic value) {
      return value is Timestamp ? value.toDate() : null;
    }

    return ApplicationModel(
      id: document.id,
      opportunityId:
          data['opportunityId'] as String? ?? '',
      opportunityTitle:
          data['opportunityTitle'] as String? ?? '',
      startupOwnerId:
          data['startupOwnerId'] as String? ?? '',
      startupName:
          data['startupName'] as String? ?? '',
      studentId: data['studentId'] as String? ?? '',
      studentName:
          data['studentName'] as String? ?? '',
      studentEmail:
          data['studentEmail'] as String? ?? '',
      coverLetter:
          data['coverLetter'] as String? ?? '',
      status: data['status'] as String? ?? 'submitted',
      submittedAt: readDate(data['submittedAt']),
      updatedAt: readDate(data['updatedAt']),
      interviewDateTime:
          readDate(data['interviewDateTime']),
      interviewMode:
          data['interviewMode'] as String? ?? '',
      interviewLocationOrLink:
          data['interviewLocationOrLink']
                  as String? ??
              '',
      interviewNotes:
          data['interviewNotes'] as String? ?? '',
      interviewScheduledBy:
          data['interviewScheduledBy'] as String? ?? '',
      interviewScheduledAt:
          readDate(data['interviewScheduledAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        opportunityId,
        opportunityTitle,
        startupOwnerId,
        startupName,
        studentId,
        studentName,
        studentEmail,
        coverLetter,
        status,
        submittedAt,
        updatedAt,
        interviewDateTime,
        interviewMode,
        interviewLocationOrLink,
        interviewNotes,
        interviewScheduledBy,
        interviewScheduledAt,
      ];
}