import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/notification_model.dart';

class NotificationRepository {
  final FirebaseFirestore _firestore;

  NotificationRepository({FirebaseFirestore? firestore})
    : _firestore = firestore ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _notifications {
    return _firestore.collection('notifications');
  }

  Stream<List<AppNotification>> watchNotifications(String userId) {
    return _notifications
        .where('recipientId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
          final notifications = snapshot.docs
              .map(AppNotification.fromDocument)
              .toList();

          notifications.sort((a, b) {
            final aDate = a.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);
            final bDate = b.createdAt ?? DateTime.fromMillisecondsSinceEpoch(0);

            return bDate.compareTo(aDate);
          });

          return notifications;
        });
  }

  Future<void> markAsRead(String notificationId) async {
    await _notifications.doc(notificationId).update({'isRead': true});
  }

  Future<void> markAllAsRead(String userId) async {
    final snapshot = await _notifications
        .where('recipientId', isEqualTo: userId)
        .get();

    final unreadDocuments = snapshot.docs.where((document) {
      return document.data()['isRead'] != true;
    }).toList();

    if (unreadDocuments.isEmpty) {
      return;
    }

    final batch = _firestore.batch();

    for (final document in unreadDocuments) {
      batch.update(document.reference, {'isRead': true});
    }

    await batch.commit();
  }

  Future<void> deleteNotification(String notificationId) async {
    await _notifications.doc(notificationId).delete();
  }
}
