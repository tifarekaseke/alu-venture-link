import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../opportunities/data/models/opportunity_model.dart';

class BookmarkRepository {
  final FirebaseFirestore _firestore;

  BookmarkRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> _bookmarkCollection(
    String userId,
  ) {
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('bookmarks');
  }

  Stream<List<OpportunityModel>> watchSavedOpportunities(String userId) {
    return _bookmarkCollection(userId).snapshots().map((snapshot) {
      final opportunities = snapshot.docs.map((document) {
        return OpportunityModel.fromDocument(document);
      }).toList();

      opportunities.sort((a, b) {
        final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
        return bDate.compareTo(aDate);
      });

      return opportunities;
    });
  }

  Future<void> toggleBookmark({
    required String userId,
    required OpportunityModel opportunity,
  }) async {
    final bookmarkDocument =
        _bookmarkCollection(userId).doc(opportunity.id);

    final existingBookmark = await bookmarkDocument.get();

    if (existingBookmark.exists) {
      await bookmarkDocument.delete();
      return;
    }

    await bookmarkDocument.set({
      'ownerId': opportunity.ownerId,
      'startupName': opportunity.startupName,
      'title': opportunity.title,
      'description': opportunity.description,
      'requiredSkills': opportunity.requiredSkills,
      'opportunityType': opportunity.opportunityType,
      'workMode': opportunity.workMode,
      'hoursPerWeek': opportunity.hoursPerWeek,
      'status': opportunity.status,
      'deadline': opportunity.deadline == null
          ? null
          : Timestamp.fromDate(opportunity.deadline!),
      'createdAt': opportunity.createdAt == null
          ? FieldValue.serverTimestamp()
          : Timestamp.fromDate(opportunity.createdAt!),
      'savedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> removeBookmark({
    required String userId,
    required String opportunityId,
  }) async {
    await _bookmarkCollection(userId).doc(opportunityId).delete();
  }
}