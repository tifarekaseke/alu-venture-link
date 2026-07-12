import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/models/app_user.dart';
import '../../data/models/application_model.dart';
import '../cubit/application_cubit.dart';
import '../cubit/application_state.dart';
import 'schedule_interview_screen.dart';

class StartupApplicationsScreen
    extends StatefulWidget {
  final AppUser user;

  const StartupApplicationsScreen({
    required this.user,
    super.key,
  });

  @override
  State<StartupApplicationsScreen> createState() =>
      _StartupApplicationsScreenState();
}

class _StartupApplicationsScreenState
    extends State<StartupApplicationsScreen> {
  String _selectedStatus = 'All';

  final _statuses = const [
    'All',
    'submitted',
    'underReview',
    'shortlisted',
    'interview',
    'accepted',
    'rejected',
    'withdrawn',
  ];

  @override
  void initState() {
    super.initState();

    context
        .read<ApplicationCubit>()
        .watchStartupApplications(
          widget.user.uid,
        );
  }

  List<ApplicationModel> _filteredApplications(
    List<ApplicationModel> applications,
  ) {
    if (_selectedStatus == 'All') {
      return applications;
    }

    return applications.where((application) {
      return application.status ==
          _selectedStatus;
    }).toList();
  }

  Future<void> _changeStatus({
    required ApplicationModel application,
    required String status,
  }) async {
    final success = await context
        .read<ApplicationCubit>()
        .updateApplicationStatus(
          applicationId: application.id,
          status: status,
        );

    if (!mounted || !success) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${application.studentName} moved to ${_statusLabel(status)}.',
        ),
      ),
    );
  }

  Future<void> _scheduleInterview(
    ApplicationModel application,
  ) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) =>
            ScheduleInterviewScreen(
          application: application,
        ),
      ),
    );
  }

  String _statusLabel(String status) {
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
      case 'submitted':
        return 'Submitted';
      default:
        return status;
    }
  }

  int _countStatus(
    List<ApplicationModel> applications,
    String status,
  ) {
    return applications
        .where(
          (application) =>
              application.status == status,
        )
        .length;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Applicants'),
      ),
      body: BlocConsumer<
          ApplicationCubit,
          ApplicationState>(
        listener: (context, state) {
          if (state is ApplicationFailure) {
            ScaffoldMessenger.of(context)
                .showSnackBar(
              SnackBar(
                content: Text(state.message),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is ApplicationLoading ||
              state is ApplicationInitial) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is ApplicationLoaded &&
              state.applications.isEmpty) {
            return const _EmptyApplicantState();
          }

          if (state is ApplicationLoaded) {
            final applications =
                state.applications;

            final filtered =
                _filteredApplications(
              applications,
            );

            return ListView(
              padding: const EdgeInsets.fromLTRB(
                20,
                18,
                20,
                32,
              ),
              children: [
                const Text(
                  'Candidate pipeline',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.navy,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Review applicants, move them through the selection process, and schedule interviews.',
                  style: TextStyle(
                    height: 1.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 22),

                Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    _MetricCard(
                      label: 'Total',
                      value:
                          applications.length,
                      icon:
                          Icons.groups_outlined,
                    ),
                    _MetricCard(
                      label: 'Review',
                      value: _countStatus(
                        applications,
                        'underReview',
                      ),
                      icon:
                          Icons.visibility_outlined,
                    ),
                    _MetricCard(
                      label: 'Interview',
                      value: _countStatus(
                        applications,
                        'interview',
                      ),
                      icon:
                          Icons.video_call_outlined,
                    ),
                    _MetricCard(
                      label: 'Accepted',
                      value: _countStatus(
                        applications,
                        'accepted',
                      ),
                      icon:
                          Icons.check_circle_outline,
                    ),
                  ],
                ),

                const SizedBox(height: 22),

                DropdownButtonFormField<String>(
                  initialValue: _selectedStatus,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'Filter by status',
                    prefixIcon:
                        Icon(Icons.filter_list),
                  ),
                  items: _statuses.map((status) {
                    return DropdownMenuItem<String>(
                      value: status,
                      child: Text(
                        status == 'All'
                            ? 'All applications'
                            : _statusLabel(status),
                      ),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value == null) {
                      return;
                    }

                    setState(() {
                      _selectedStatus = value;
                    });
                  },
                ),

                const SizedBox(height: 22),

                if (filtered.isEmpty)
                  const _NoFilteredApplicants()
                else
                  ...filtered.map(
                    (application) =>
                        _ApplicantCard(
                      application: application,
                      statusLabel:
                          _statusLabel(
                        application.status,
                      ),
                      onStatusChanged:
                          (status) {
                        _changeStatus(
                          application:
                              application,
                          status: status,
                        );
                      },
                      onScheduleInterview: () {
                        _scheduleInterview(
                          application,
                        );
                      },
                    ),
                  ),
              ],
            );
          }

          if (state is ApplicationFailure) {
            return Center(
              child: Padding(
                padding:
                    const EdgeInsets.all(28),
                child: Text(
                  state.message,
                  textAlign:
                      TextAlign.center,
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

class _ApplicantCard extends StatelessWidget {
  final ApplicationModel application;
  final String statusLabel;
  final ValueChanged<String> onStatusChanged;
  final VoidCallback onScheduleInterview;

  const _ApplicantCard({
    required this.application,
    required this.statusLabel,
    required this.onStatusChanged,
    required this.onScheduleInterview,
  });

  @override
  Widget build(BuildContext context) {
    final submittedText =
        application.submittedAt == null
            ? 'Recently'
            : DateFormat('dd MMM yyyy')
                .format(
                  application.submittedAt!,
                );

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(
        bottom: 16,
      ),
      shape: RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(22),
        side: const BorderSide(
          color: Color(0xFFE4E7EC),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor:
                      AppTheme.navy,
                  child: Text(
                    _initials(
                      application.studentName,
                    ),
                    style: const TextStyle(
                      color: AppTheme.gold,
                      fontWeight:
                          FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        application.studentName,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.w800,
                          color: AppTheme.navy,
                        ),
                      ),
                      const SizedBox(height: 3),
                      Text(
                        application.studentEmail,
                        style: const TextStyle(
                          color:
                              AppTheme.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        application
                            .opportunityTitle,
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.w700,
                          color: AppTheme.purple,
                        ),
                      ),
                    ],
                  ),
                ),
                _StatusChip(
                  status:
                      application.status,
                  label: statusLabel,
                ),
              ],
            ),

            const SizedBox(height: 18),

            Text(
              application.coverLetter.isEmpty
                  ? 'No cover letter was provided.'
                  : application.coverLetter,
              maxLines: 5,
              overflow:
                  TextOverflow.ellipsis,
              style: const TextStyle(
                height: 1.5,
                color:
                    AppTheme.textSecondary,
              ),
            ),

            const SizedBox(height: 14),

            Row(
              children: [
                const Icon(
                  Icons.calendar_today_outlined,
                  size: 16,
                  color:
                      AppTheme.textSecondary,
                ),
                const SizedBox(width: 7),
                Text(
                  'Applied $submittedText',
                  style: const TextStyle(
                    fontSize: 13,
                    color:
                        AppTheme.textSecondary,
                  ),
                ),
              ],
            ),

            if (application.hasInterview) ...[
              const SizedBox(height: 16),
              _InterviewSummary(
                application: application,
              ),
            ],

            const SizedBox(height: 18),

            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed:
                        application.status ==
                                    'accepted' ||
                                application.status ==
                                    'rejected' ||
                                application.status ==
                                    'withdrawn'
                            ? null
                            : onScheduleInterview,
                    icon: const Icon(
                      Icons.event_outlined,
                    ),
                    label: Text(
                      application.hasInterview
                          ? 'Update interview'
                          : 'Schedule',
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                PopupMenuButton<String>(
                  tooltip: 'Change status',
                  onSelected:
                      onStatusChanged,
                  itemBuilder: (context) {
                    return const [
                      PopupMenuItem(
                        value:
                            'underReview',
                        child: Text(
                          'Move to review',
                        ),
                      ),
                      PopupMenuItem(
                        value:
                            'shortlisted',
                        child: Text(
                          'Shortlist',
                        ),
                      ),
                      PopupMenuItem(
                        value: 'accepted',
                        child: Text(
                          'Accept',
                        ),
                      ),
                      PopupMenuItem(
                        value: 'rejected',
                        child: Text(
                          'Reject',
                        ),
                      ),
                    ];
                  },
                  child: Container(
                    height: 48,
                    padding:
                        const EdgeInsets
                            .symmetric(
                      horizontal: 16,
                    ),
                    decoration:
                        BoxDecoration(
                      color: AppTheme.navy,
                      borderRadius:
                          BorderRadius.circular(
                        14,
                      ),
                    ),
                    alignment:
                        Alignment.center,
                    child: const Row(
                      children: [
                        Text(
                          'Status',
                          style: TextStyle(
                            color:
                                Colors.white,
                            fontWeight:
                                FontWeight.w700,
                          ),
                        ),
                        SizedBox(width: 6),
                        Icon(
                          Icons
                              .keyboard_arrow_down,
                          color:
                              Colors.white,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _initials(String value) {
    final parts = value
        .trim()
        .split(RegExp(r'\s+'))
        .where(
          (part) => part.isNotEmpty,
        )
        .toList();

    if (parts.isEmpty) {
      return 'S';
    }

    if (parts.length == 1) {
      return parts.first[0]
          .toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'
        .toUpperCase();
  }
}

class _InterviewSummary extends StatelessWidget {
  final ApplicationModel application;

  const _InterviewSummary({
    required this.application,
  });

  @override
  Widget build(BuildContext context) {
    final dateText =
        DateFormat(
      'EEE, dd MMM yyyy • HH:mm',
    ).format(
      application.interviewDateTime!
          .toLocal(),
    );

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFFF1EDFF),
        borderRadius:
            BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.video_call_outlined,
                color: AppTheme.purple,
              ),
              SizedBox(width: 8),
              Text(
                'Interview scheduled',
                style: TextStyle(
                  fontWeight:
                      FontWeight.w800,
                  color: AppTheme.navy,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            dateText,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: AppTheme.navy,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            application.interviewMode,
            style: const TextStyle(
              color:
                  AppTheme.textSecondary,
            ),
          ),
          Text(
            application
                .interviewLocationOrLink,
            style: const TextStyle(
              color:
                  AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String label;
  final int value;
  final IconData icon;

  const _MetricCard({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE4E7EC),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: AppTheme.purple,
          ),
          const SizedBox(height: 10),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 24,
              fontWeight:
                  FontWeight.w800,
              color: AppTheme.navy,
            ),
          ),
          Text(
            label,
            style: const TextStyle(
              color:
                  AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String status;
  final String label;

  const _StatusChip({
    required this.status,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    Color background;
    Color foreground;

    switch (status) {
      case 'accepted':
        background =
            const Color(0xFFEAF8EF);
        foreground =
            Colors.green.shade700;
        break;

      case 'rejected':
      case 'withdrawn':
        background =
            const Color(0xFFFFEEEE);
        foreground =
            Colors.red.shade700;
        break;

      case 'interview':
      case 'shortlisted':
        background =
            const Color(0xFFF1EDFF);
        foreground = AppTheme.purple;
        break;

      default:
        background =
            const Color(0xFFFFF7D6);
        foreground =
            Colors.orange.shade800;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 10,
        vertical: 7,
      ),
      decoration: BoxDecoration(
        color: background,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w800,
          color: foreground,
        ),
      ),
    );
  }
}

class _EmptyApplicantState
    extends StatelessWidget {
  const _EmptyApplicantState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            Icon(
              Icons.groups_outlined,
              size: 60,
              color: AppTheme.purple,
            ),
            SizedBox(height: 18),
            Text(
              'No applications yet',
              style: TextStyle(
                fontSize: 21,
                fontWeight:
                    FontWeight.w800,
                color: AppTheme.navy,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Student applications will appear here in real time.',
              textAlign:
                  TextAlign.center,
              style: TextStyle(
                height: 1.5,
                color:
                    AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _NoFilteredApplicants
    extends StatelessWidget {
  const _NoFilteredApplicants();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE4E7EC),
        ),
      ),
      child: const Text(
        'No applications match this status filter.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color:
              AppTheme.textSecondary,
        ),
      ),
    );
  }
}