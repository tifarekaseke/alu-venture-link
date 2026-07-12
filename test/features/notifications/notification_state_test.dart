import 'package:flutter_test/flutter_test.dart';
import 'package:alu_venture_link/features/notifications/data/models/notification_model.dart';
import 'package:alu_venture_link/features/notifications/presentation/cubit/notification_state.dart';

void main() {
  AppNotification createNotification({
    required String id,
    required bool isRead,
  }) {
    return AppNotification(
      id: id,
      recipientId: 'student-1',
      senderId: 'startup-1',
      title: 'Application update',
      message: 'Your application status changed.',
      type: 'application_status',
      referenceId: 'application-1',
      isRead: isRead,
      createdAt: DateTime(2026, 7, 10),
    );
  }

  group('NotificationLoaded', () {
    test('counts only unread notifications', () {
      final state = NotificationLoaded([
        createNotification(id: 'notification-1', isRead: false),
        createNotification(id: 'notification-2', isRead: true),
        createNotification(id: 'notification-3', isRead: false),
      ]);

      expect(state.unreadCount, 2);
    });

    test('returns zero when every notification is read', () {
      final state = NotificationLoaded([
        createNotification(id: 'notification-1', isRead: true),
        createNotification(id: 'notification-2', isRead: true),
      ]);

      expect(state.unreadCount, 0);
    });
  });
}
