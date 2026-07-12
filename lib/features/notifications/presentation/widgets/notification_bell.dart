import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../cubit/notification_cubit.dart';
import '../cubit/notification_state.dart';

class NotificationBell extends StatelessWidget {
  final VoidCallback onPressed;

  const NotificationBell({
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<NotificationCubit, NotificationState>(
      builder: (context, state) {
        final unreadCount =
            state is NotificationLoaded ? state.unreadCount : 0;

        return Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: 'Notifications',
              onPressed: onPressed,
              icon: Icon(
                unreadCount > 0
                    ? Icons.notifications
                    : Icons.notifications_outlined,
              ),
            ),
            if (unreadCount > 0)
              Positioned(
                right: 5,
                top: 5,
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 17,
                    minHeight: 17,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.purple,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white,
                      width: 1.5,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    unreadCount > 99
                        ? '99+'
                        : unreadCount.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 9,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    );
  }
}