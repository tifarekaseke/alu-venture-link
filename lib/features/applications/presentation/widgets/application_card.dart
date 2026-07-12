import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/application_model.dart';

class ApplicationCard extends StatelessWidget {
  final ApplicationModel application;
  final Widget? trailing;

  const ApplicationCard({required this.application, this.trailing, super.key});

  Color get _statusColor {
    switch (application.status) {
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'shortlisted':
      case 'interview':
        return AppTheme.purple;
      case 'withdrawn':
        return Colors.grey;
      default:
        return AppTheme.navy;
    }
  }

  @override
  Widget build(BuildContext context) {
    final submittedText = application.submittedAt == null
        ? 'Recently'
        : DateFormat('dd MMM yyyy').format(application.submittedAt!);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE4E7EC)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  backgroundColor: _statusColor.withAlpha(25),
                  child: Icon(Icons.description_outlined, color: _statusColor),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.opportunityTitle,
                        style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.navy,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        application.startupName,
                        style: const TextStyle(color: AppTheme.textSecondary),
                      ),
                    ],
                  ),
                ),
                trailing ?? const SizedBox.shrink(),
              ],
            ),
            const SizedBox(height: 14),
            Text(
              application.coverLetter,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                height: 1.45,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Chip(
                  label: Text(application.status),
                  backgroundColor: _statusColor.withAlpha(25),
                  side: BorderSide.none,
                  labelStyle: TextStyle(
                    color: _statusColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                Text(
                  submittedText,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
