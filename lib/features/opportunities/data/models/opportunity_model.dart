import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class OpportunityModel extends Equatable {
  final String id;
  final String ownerId;
  final String startupName;
  final String title;
  final String description;
  final List<String> requiredSkills;
  final String opportunityType;
  final String workMode;
  final String hoursPerWeek;
  final String status;
  final DateTime? deadline;
  final DateTime? createdAt;

  const OpportunityModel({
    required this.id,
    required this.ownerId,
    required this.startupName,
    required this.title,
    required this.description,
    required this.requiredSkills,
    required this.opportunityType,
    required this.workMode,
    required this.hoursPerWeek,
    required this.status,
    this.deadline,
    this.createdAt,
  });

  bool get isOpen => status == 'open';

  factory OpportunityModel.fromDocument(
    DocumentSnapshot<Map<String, dynamic>> document,
  ) {
    final data = document.data() ?? {};

    final rawSkills = data['requiredSkills'];
    final rawDeadline = data['deadline'];
    final rawCreatedAt = data['createdAt'];

    return OpportunityModel(
      id: document.id,
      ownerId: data['ownerId'] as String? ?? '',
      startupName: data['startupName'] as String? ?? 'Unknown Startup',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      requiredSkills: rawSkills is List
          ? rawSkills.map((skill) => skill.toString()).toList()
          : const [],
      opportunityType: data['opportunityType'] as String? ?? 'Internship',
      workMode: data['workMode'] as String? ?? 'On-campus',
      hoursPerWeek: data['hoursPerWeek'] as String? ?? '',
      status: data['status'] as String? ?? 'open',
      deadline: rawDeadline is Timestamp ? rawDeadline.toDate() : null,
      createdAt: rawCreatedAt is Timestamp ? rawCreatedAt.toDate() : null,
    );
  }

  @override
  List<Object?> get props => [
        id,
        ownerId,
        startupName,
        title,
        description,
        requiredSkills,
        opportunityType,
        workMode,
        hoursPerWeek,
        status,
        deadline,
        createdAt,
      ];
}