import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileRepository {
  final FirebaseFirestore _firestore;

  ProfileRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  Future<void> updateStudentProfile({
    required String userId,
    required String fullName,
    required String campus,
    required String program,
    required String bio,
    required List<String> skills,
    required int availabilityHours,
    required String portfolioUrl,
    required String linkedInUrl,
    required String githubUrl,
  }) async {
    final normalizedSkills = skills
        .map((skill) => skill.trim())
        .where((skill) => skill.isNotEmpty)
        .toSet()
        .toList();

    final profileCompleted = fullName.trim().isNotEmpty &&
        campus.trim().isNotEmpty &&
        program.trim().isNotEmpty &&
        normalizedSkills.isNotEmpty &&
        bio.trim().isNotEmpty &&
        availabilityHours > 0;

    await _firestore.collection('users').doc(userId).set(
      {
        'fullName': fullName.trim(),
        'campus': campus.trim(),
        'program': program.trim(),
        'bio': bio.trim(),
        'skills': normalizedSkills,
        'availabilityHours': availabilityHours,
        'portfolioUrl': portfolioUrl.trim(),
        'linkedInUrl': linkedInUrl.trim(),
        'githubUrl': githubUrl.trim(),
        'profileCompleted': profileCompleted,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}