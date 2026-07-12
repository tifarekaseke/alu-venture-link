import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/models/app_user.dart';
import '../../data/models/notification_model.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';

class NotificationsScreen extends StatefulWidget {
  final AppUser user;

  const NotificationsScreen({
    required this.user,
    super.key,
  });

  @override
  State<NotificationsScreen> createState() =>
      _NotificationsScreenState();
}

class _NotificationsScreenState
    extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();

    context
        .read<NotificationCubit>()
        .watchNotifications(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Notifications'),
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              final hasUnread = state is NotificationLoaded &&
                  state.unreadCount > 0;

              return TextButton(
                onPressed: hasUnread
                    ? () {
                        context
                            .read<NotificationCubit>()
                            .markAllAsRead(widget.user.uid);
                      }
                    : null,
                child: const Text('Mark all read'),
              );
            },
          ),
        ],
      ),
      body: BlocConsumer<NotificationCubit, NotificationState>(
        listener: (context, state) {
          if (state is NotificationFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is NotificationLoading ||
              state is NotificationInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is NotificationLoaded &&
              state.notifications.isEmpty) {
            return const _EmptyNotificationsState();
          }

          if (state is NotificationLoaded) {
            return ListView.builder(
              padding: const EdgeInsets.fromLTRB(
                20,
                16,
                20,
                32,
              ),
              itemCount: state.notifications.length,
              itemBuilder: (context, index) {
                final notification =
                    state.notifications[index];

                return Dismissible(
                  key: ValueKey(notification.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.only(right: 22),
                    decoration: BoxDecoration(
                      color: Colors.red.shade600,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    alignment: Alignment.centerRight,
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                    ),
                  ),
                  onDismissed: (_) {
                    context
                        .read<NotificationCubit>()
                        .deleteNotification(notification.id);
                  },
                  child: _NotificationCard(
                    notification: notification,
                    onTap: () {
                      if (!notification.isRead) {
                        context
                            .read<NotificationCubit>()
                            .markAsRead(notification.id);
                      }
                    },
                  ),
                );
              },
            );
          }

          if (state is NotificationFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final AppNotification notification;
  final VoidCallback onTap;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
  });

  IconData get _icon {
    switch (notification.type) {
      case 'new_application':
        return Icons.person_add_alt_outlined;
      case 'application_status':
        return Icons.assignment_turned_in_outlined;
      case 'application_withdrawn':
        return Icons.person_remove_outlined;
      case 'verification_approved':
        return Icons.verified_outlined;
      case 'verification_rejected':
        return Icons.cancel_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color get _iconColor {
    switch (notification.type) {
      case 'verification_approved':
        return Colors.green;
      case 'verification_rejected':
        return Colors.red;
      case 'application_status':
        return AppTheme.purple;
      default:
        return AppTheme.navy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final dateText = notification.createdAt == null
        ? 'Just now'
        : DateFormat('dd MMM, HH:mm')
            .format(notification.createdAt!);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 12),
      color: notification.isRead
          ? Colors.white
          : const Color(0xFFF4F1FF),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: notification.isRead
              ? const Color(0xFFE4E7EC)
              : AppTheme.purple.withAlpha(90),
        ),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(17),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: _iconColor.withAlpha(25),
                child: Icon(
                  _icon,
                  color: _iconColor,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification.title,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: notification.isRead
                                  ? FontWeight.w700
                                  : FontWeight.w800,
                              color: AppTheme.navy,
                            ),
                          ),
                        ),
                        if (!notification.isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.purple,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      notification.message,
                      style: const TextStyle(
                        height: 1.45,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 9),
                    Text(
                      dateText,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EmptyNotificationsState extends StatelessWidget {
  const _EmptyNotificationsState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.notifications_none_outlined,
              size: 60,
              color: AppTheme.purple,
            ),
            SizedBox(height: 18),
            Text(
              'No notifications yet',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: AppTheme.navy,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Application and verification updates will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.5,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}