import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/notification_model.dart';
import '../../data/repositories/notification_repository.dart';
import 'notification_state.dart';

class NotificationCubit extends Cubit<NotificationState> {
  final NotificationRepository _notificationRepository;

  StreamSubscription<List<AppNotification>>? _subscription;

  NotificationCubit(this._notificationRepository)
    : super(const NotificationInitial());

  void watchNotifications(String userId) {
    emit(const NotificationLoading());

    _subscription?.cancel();

    _subscription = _notificationRepository
        .watchNotifications(userId)
        .listen(
          (notifications) {
            emit(NotificationLoaded(notifications));
          },
          onError: (Object error) {
            emit(NotificationFailure(_friendlyError(error)));
          },
        );
  }

  Future<void> markAsRead(String notificationId) async {
    try {
      await _notificationRepository.markAsRead(notificationId);
    } catch (error) {
      emit(NotificationFailure(_friendlyError(error)));
    }
  }

  Future<void> markAllAsRead(String userId) async {
    try {
      await _notificationRepository.markAllAsRead(userId);
    } catch (error) {
      emit(NotificationFailure(_friendlyError(error)));
    }
  }

  Future<void> deleteNotification(String notificationId) async {
    try {
      await _notificationRepository.deleteNotification(notificationId);
    } catch (error) {
      emit(NotificationFailure(_friendlyError(error)));
    }
  }

  String _friendlyError(Object error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Firebase denied access to notifications.';
        case 'unavailable':
          return 'Notifications are temporarily unavailable.';
        default:
          return error.message ?? 'A Firebase notification error occurred.';
      }
    }

    return 'Notifications could not be updated.';
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
