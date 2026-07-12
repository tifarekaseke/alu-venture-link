import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String uid;
  final String fullName;
  final String email;
  final String role;
  final String campus;
  final String program;
  final List<String> skills;
  final String profileImageUrl;
  final String bio;
  final String portfolioUrl;
  final String linkedInUrl;
  final String githubUrl;
  final int availabilityHours;
  final bool profileCompleted;
  final DateTime? createdAt;

  const AppUser({
    required this.uid,
    required this.fullName,
    required this.email,
    required this.role,
    required this.campus,
    required this.program,
    required this.skills,
    required this.profileImageUrl,
    this.bio = '',
    this.portfolioUrl = '',
    this.linkedInUrl = '',
    this.githubUrl = '',
    this.availabilityHours = 0,
    this.profileCompleted = false,
    this.createdAt,
  });

  bool get isStudent => role == 'student';

  bool get isStartup => role == 'startup';

  bool get isAdmin => role == 'admin';

  factory AppUser.fromMap(String documentId, Map<String, dynamic> map) {
    final rawSkills = map['skills'];
    final rawCreatedAt = map['createdAt'];
    final rawAvailability = map['availabilityHours'];

    return AppUser(
      uid: documentId,
      fullName: map['fullName'] as String? ?? '',
      email: map['email'] as String? ?? '',
      role: map['role'] as String? ?? 'student',
      campus: map['campus'] as String? ?? 'ALU Rwanda',
      program: map['program'] as String? ?? '',
      skills: rawSkills is List
          ? rawSkills.map((skill) => skill.toString()).toList()
          : const [],
      profileImageUrl: map['profileImageUrl'] as String? ?? '',
      bio: map['bio'] as String? ?? '',
      portfolioUrl: map['portfolioUrl'] as String? ?? '',
      linkedInUrl: map['linkedInUrl'] as String? ?? '',
      githubUrl: map['githubUrl'] as String? ?? '',
      availabilityHours: rawAvailability is num ? rawAvailability.toInt() : 0,
      profileCompleted: map['profileCompleted'] as bool? ?? false,
      createdAt: rawCreatedAt is Timestamp ? rawCreatedAt.toDate() : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'role': role,
      'campus': campus,
      'program': program,
      'skills': skills,
      'profileImageUrl': profileImageUrl,
      'bio': bio,
      'portfolioUrl': portfolioUrl,
      'linkedInUrl': linkedInUrl,
      'githubUrl': githubUrl,
      'availabilityHours': availabilityHours,
      'profileCompleted': profileCompleted,
    };
  }

  AppUser copyWith({
    String? fullName,
    String? email,
    String? role,
    String? campus,
    String? program,
    List<String>? skills,
    String? profileImageUrl,
    String? bio,
    String? portfolioUrl,
    String? linkedInUrl,
    String? githubUrl,
    int? availabilityHours,
    bool? profileCompleted,
  }) {
    return AppUser(
      uid: uid,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      role: role ?? this.role,
      campus: campus ?? this.campus,
      program: program ?? this.program,
      skills: skills ?? this.skills,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      bio: bio ?? this.bio,
      portfolioUrl: portfolioUrl ?? this.portfolioUrl,
      linkedInUrl: linkedInUrl ?? this.linkedInUrl,
      githubUrl: githubUrl ?? this.githubUrl,
      availabilityHours: availabilityHours ?? this.availabilityHours,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [
    uid,
    fullName,
    email,
    role,
    campus,
    program,
    skills,
    profileImageUrl,
    bio,
    portfolioUrl,
    linkedInUrl,
    githubUrl,
    availabilityHours,
    profileCompleted,
    createdAt,
  ];
}
