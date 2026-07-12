import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/models/app_user.dart';
import '../../data/models/application_model.dart';
import '../cubit/application_cubit.dart';
import '../cubit/application_state.dart';

class MyApplicationsScreen extends StatefulWidget {
  final AppUser user;

  const MyApplicationsScreen({required this.user, super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen> {
  @override
  void initState() {
    super.initState();

    context.read<ApplicationCubit>().watchStudentApplications(widget.user.uid);
  }

  Future<void> _withdraw(ApplicationModel application) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Withdraw application?'),
          content: Text(
            'You are about to withdraw your application for ${application.opportunityTitle}.',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Withdraw'),
            ),
          ],
        );
      },
    );

    if (confirmed != true || !mounted) {
      return;
    }

    final success = await context.read<ApplicationCubit>().withdrawApplication(
      application.id,
    );

    if (!mounted || !success) {
      return;
    }

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Application withdrawn.')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Applications')),
      body: BlocConsumer<ApplicationCubit, ApplicationState>(
        listener: (context, state) {
          if (state is ApplicationFailure) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is ApplicationLoading || state is ApplicationInitial) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is ApplicationLoaded && state.applications.isEmpty) {
            return const _EmptyApplications();
          }

          if (state is ApplicationLoaded) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 18, 20, 32),
              children: [
                const Text(
                  'Application journey',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.navy,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Track your applications, interview invitations, and final decisions.',
                  style: TextStyle(height: 1.5, color: AppTheme.textSecondary),
                ),
                const SizedBox(height: 24),
                ...state.applications.map(
                  (application) => _StudentApplicationCard(
                    application: application,
                    onWithdraw: () {
                      _withdraw(application);
                    },
                  ),
                ),
              ],
            );
          }

          if (state is ApplicationFailure) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Text(state.message, textAlign: TextAlign.center),
              ),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _StudentApplicationCard extends StatelessWidget {
  final ApplicationModel application;
  final VoidCallback onWithdraw;

  const _StudentApplicationCard({
    required this.application,
    required this.onWithdraw,
  });

  @override
  Widget build(BuildContext context) {
    final submittedText = application.submittedAt == null
        ? 'Recently'
        : DateFormat('dd MMM yyyy').format(application.submittedAt!);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(color: Color(0xFFE4E7EC)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.navy,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(Icons.work_outline, color: AppTheme.gold),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.opportunityTitle,
                        style: const TextStyle(
                          fontSize: 18,
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
                _StudentStatusChip(status: application.status),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 7),
                Text(
                  'Applied $submittedText',
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),

            if (application.hasInterview) ...[
              const SizedBox(height: 18),
              _StudentInterviewCard(application: application),
            ],

            if (application.canWithdraw) ...[
              const SizedBox(height: 18),
              OutlinedButton.icon(
                onPressed: onWithdraw,
                icon: const Icon(Icons.undo_outlined),
                label: const Text('Withdraw application'),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StudentInterviewCard extends StatelessWidget {
  final ApplicationModel application;

  const _StudentInterviewCard({required this.application});

  @override
  Widget build(BuildContext context) {
    final dateText = DateFormat(
      'EEEE, dd MMMM yyyy',
    ).format(application.interviewDateTime!.toLocal());

    final timeText = DateFormat(
      'HH:mm',
    ).format(application.interviewDateTime!.toLocal());

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EDFF),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppTheme.purple.withAlpha(55)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.event_available_outlined, color: AppTheme.purple),
              SizedBox(width: 9),
              Expanded(
                child: Text(
                  'Interview invitation',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.navy,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          _InterviewDetailRow(
            icon: Icons.calendar_month_outlined,
            label: dateText,
          ),
          const SizedBox(height: 9),

          _InterviewDetailRow(icon: Icons.access_time, label: timeText),
          const SizedBox(height: 9),

          _InterviewDetailRow(
            icon: Icons.video_call_outlined,
            label: application.interviewMode,
          ),
          const SizedBox(height: 9),

          _InterviewDetailRow(
            icon: application.interviewMode == 'In-person'
                ? Icons.location_on_outlined
                : Icons.link_outlined,
            label: application.interviewLocationOrLink,
          ),

          if (application.interviewNotes.isNotEmpty) ...[
            const SizedBox(height: 14),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Preparation instructions',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                color: AppTheme.navy,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              application.interviewNotes,
              style: const TextStyle(
                height: 1.5,
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _InterviewDetailRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InterviewDetailRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: AppTheme.purple),
        const SizedBox(width: 10),
        Expanded(
          child: SelectableText(
            label,
            style: const TextStyle(height: 1.4, color: AppTheme.navy),
          ),
        ),
      ],
    );
  }
}

class _StudentStatusChip extends StatelessWidget {
  final String status;

  const _StudentStatusChip({required this.status});

  String get _label {
    switch (status) {
      case 'underReview':
        return 'Under review';
      case 'shortlisted':
        return 'Shortlisted';
      case 'interview':
        return 'Interview';
      case 'accepted':
        return 'Accepted';
      case 'rejected':
        return 'Rejected';
      case 'withdrawn':
        return 'Withdrawn';
      default:
        return 'Submitted';
    }
  }

  IconData get _icon {
    switch (status) {
      case 'accepted':
        return Icons.check_circle;
      case 'rejected':
        return Icons.cancel;
      case 'withdrawn':
        return Icons.undo;
      case 'interview':
        return Icons.video_call;
      case 'shortlisted':
        return Icons.star;
      case 'underReview':
        return Icons.visibility;
      default:
        return Icons.send;
    }
  }

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;

    switch (status) {
      case 'accepted':
        background = const Color(0xFFEAF8EF);
        foreground = Colors.green.shade700;
        break;

      case 'rejected':
      case 'withdrawn':
        background = const Color(0xFFFFEEEE);
        foreground = Colors.red.shade700;
        break;

      case 'interview':
      case 'shortlisted':
        background = const Color(0xFFF1EDFF);
        foreground = AppTheme.purple;
        break;

      default:
        background = const Color(0xFFFFF7D6);
        foreground = Colors.orange.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon, size: 14, color: foreground),
          const SizedBox(width: 5),
          Text(
            _label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: foreground,
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyApplications extends StatelessWidget {
  const _EmptyApplications();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.assignment_outlined, size: 60, color: AppTheme.purple),
            SizedBox(height: 18),
            Text(
              'No applications yet',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: AppTheme.navy,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Your submitted applications and interview invitations will appear here.',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.5, color: AppTheme.textSecondary),
            ),
          ],
        ),
      ),
    );
  }
}
