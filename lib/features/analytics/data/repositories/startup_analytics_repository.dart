import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../applications/data/models/application_model.dart';
import '../../../opportunities/data/models/opportunity_model.dart';

class StartupAnalyticsRepository {
  final FirebaseFirestore _firestore;

  StartupAnalyticsRepository({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  Stream<List<OpportunityModel>> watchStartupOpportunities(
    String startupOwnerId,
  ) {
    return _firestore
        .collection('opportunities')
        .where(
          'ownerId',
          isEqualTo: startupOwnerId,
        )
        .snapshots()
        .map((snapshot) {
      final opportunities = snapshot.docs
          .map(OpportunityModel.fromDocument)
          .toList();

      opportunities.sort((a, b) {
        final aDate = a.createdAt ??
            DateTime.fromMillisecondsSinceEpoch(0);

        final bDate = b.createdAt ??
            DateTime.fromMillisecondsSinceEpoch(0);

        return bDate.compareTo(aDate);
      });

      return opportunities;
    });
  }

  Stream<List<ApplicationModel>> watchStartupApplications(
    String startupOwnerId,
  ) {
    return _firestore
        .collection('applications')
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
}