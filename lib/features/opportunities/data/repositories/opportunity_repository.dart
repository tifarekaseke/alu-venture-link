import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/opportunity_model.dart';

class OpportunityRepository {
  final FirebaseFirestore _firestore;

  OpportunityRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _opportunities {
    return _firestore.collection('opportunities');
  }

  Stream<List<OpportunityModel>> watchOpenOpportunities() {
    return _opportunities.snapshots().map((snapshot) {
      final opportunities = snapshot.docs
          .map(OpportunityModel.fromDocument)
          .where((opportunity) => opportunity.status == 'open')
          .toList();

      opportunities.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      return opportunities;
    });
  }

  Stream<List<OpportunityModel>> watchStartupOpportunities(
    String ownerId,
  ) {
    return _opportunities.snapshots().map((snapshot) {
      final opportunities = snapshot.docs
          .map(OpportunityModel.fromDocument)
          .where((opportunity) => opportunity.ownerId == ownerId)
          .toList();

      opportunities.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      return opportunities;
    });
  }

  Future<void> createOpportunity({
    required String ownerId,
    required String startupName,
    required String title,
    required String description,
    required List<String> requiredSkills,
    required String opportunityType,
    required String workMode,
    required String hoursPerWeek,
    required DateTime deadline,
  }) async {
    await _opportunities.add({
      'ownerId': ownerId,
      'startupName': startupName,
      'title': title.trim(),
      'description': description.trim(),
      'requiredSkills': requiredSkills,
      'opportunityType': opportunityType,
      'workMode': workMode,
      'hoursPerWeek': hoursPerWeek.trim(),
      'status': 'open',
      'deadline': Timestamp.fromDate(deadline),
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> closeOpportunity(String opportunityId) async {
    await _opportunities.doc(opportunityId).update({
      'status': 'closed',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> reopenOpportunity(String opportunityId) async {
    await _opportunities.doc(opportunityId).update({
      'status': 'open',
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> deleteOpportunity(String opportunityId) async {
    await _opportunities.doc(opportunityId).delete();
  }
}