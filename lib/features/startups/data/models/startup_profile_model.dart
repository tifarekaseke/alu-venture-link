import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class StartupProfileModel extends Equatable {
  final String id;
  final String ownerId;
  final String ownerName;
  final String ownerEmail;
  final String startupName;
  final String description;
  final String industry;
  final String ventureStage;
  final String recognitionType;
  final String recognitionReference;
  final String website;
  final String verificationStatus;
  final String rejectionReason;
  final String verifiedBy;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? verifiedAt;

  const StartupProfileModel({
    required this.id,
    required this.ownerId,
    required this.ownerName,
    required this.ownerEmail,
    required this.startupName,
    required this.description,
    required this.industry,
    required this.ventureStage,
    required this.recognitionType,
    required this.recognitionReference,
    required this.website,
    required this.verificationStatus,
    required this.rejectionReason,
    required this.verifiedBy,
    this.createdAt,
    this.updatedAt,
    this.verifiedAt,
  });

  bool get isApproved => verificationStatus == 'approved';

  bool get isPending => verificationStatus == 'pending';

  bool get isRejected => verificationStatus == 'rejected';

  factory StartupProfileModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    DateTime? readDate(dynamic value) {
      return value is Timestamp ? value.toDate() : null;
    }

    return StartupProfileModel(
      id: document.id,
      ownerId: data['ownerId'] as String? ?? '',
      ownerName: data['ownerName'] as String? ?? '',
      ownerEmail: data['ownerEmail'] as String? ?? '',
      startupName: data['startupName'] as String? ?? '',
      description: data['description'] as String? ?? '',
      industry: data['industry'] as String? ?? '',
      ventureStage: data['ventureStage'] as String? ?? '',
      recognitionType: data['recognitionType'] as String? ?? '',
      recognitionReference:
          data['recognitionReference'] as String? ?? '',
      website: data['website'] as String? ?? '',
      verificationStatus:
          data['verificationStatus'] as String? ?? 'pending',
      rejectionReason: data['rejectionReason'] as String? ?? '',
      verifiedBy: data['verifiedBy'] as String? ?? '',
      createdAt: readDate(data['createdAt']),
      updatedAt: readDate(data['updatedAt']),
      verifiedAt: readDate(data['verifiedAt']),
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        ownerName,
        ownerEmail,
        startupName,
        description,
        industry,
        ventureStage,
        recognitionType,
        recognitionReference,
        website,
        verificationStatus,
        rejectionReason,
        verifiedBy,
        createdAt,
        updatedAt,
        verifiedAt,
      ];
}