import 'package:equatable/equatable.dart';

import '../../data/models/notification_model.dart';

abstract class NotificationState extends Equatable {
  const NotificationState();

  @override
  List<Object?> get props => [];
}

class NotificationInitial extends NotificationState {
  const NotificationInitial();
}

class NotificationLoading extends NotificationState {
  const NotificationLoading();
}

class NotificationLoaded extends NotificationState {
  final List<AppNotification> notifications;

  const NotificationLoaded(this.notifications);

  int get unreadCount {
    return notifications.where((item) => !item.isRead).length;
  }

  @override
  List<Object?> get props => [notifications];
}

class NotificationFailure extends NotificationState {
  final String message;

  const NotificationFailure(this.message);

  @override
  List<Object?> get props => [message];
}