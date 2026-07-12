import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../applications/presentation/screens/startup_applications_screen.dart';
import '../../../auth/data/models/app_user.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../opportunities/presentation/cubit/opportunity_cubit.dart';
import '../../../opportunities/presentation/cubit/opportunity_state.dart';
import '../../../opportunities/presentation/screens/create_opportunity_screen.dart';
import '../../../opportunities/presentation/widgets/opportunity_card.dart';
import '../../data/models/startup_profile_model.dart';
import '../cubit/startup_cubit.dart';
import '../cubit/startup_state.dart';
import 'create_startup_profile_screen.dart';
import '../../../notifications/presentation/cubit/notification_cubit.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../../analytics/presentation/screens/startup_analytics_screen.dart';

class StartupDashboardScreen extends StatefulWidget {
  final AppUser user;

  const StartupDashboardScreen({
    required this.user,
    super.key,
  });

  @override
  State<StartupDashboardScreen> createState() =>
      _StartupDashboardScreenState();
}

class _StartupDashboardScreenState
    extends State<StartupDashboardScreen> {
  @override
  void initState() {
    super.initState();

    context
        .read<StartupCubit>()
        .watchStartupProfile(widget.user.uid);

    context
        .read<OpportunityCubit>()
        .watchStartupOpportunities(widget.user.uid);

    context
    .read<NotificationCubit>()
    .watchNotifications(widget.user.uid);
  }

  void _openApplicants() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StartupApplicationsScreen(
          user: widget.user,
        ),
      ),
    );
  }

  void _openProfileForm({
    StartupProfileModel? profile,
  }) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CreateStartupProfileScreen(
          user: widget.user,
          existingProfile: profile,
        ),
      ),
    );
  }

  void _openCreateOpportunity(
    StartupProfileModel profile,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => CreateOpportunityScreen(
          user: widget.user,
          startupName: profile.startupName,
        ),
      ),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: const Text('Startup Dashboard'),
      actions: [
        NotificationBell(
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotificationsScreen(
          user: widget.user,
        ),
      ),
    );
  },
),
   IconButton(
  tooltip: 'Analytics',
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => StartupAnalyticsScreen(
          user: widget.user,
        ),
      ),
    );
  },
  icon: const Icon(Icons.insights_outlined),
),
        IconButton(
          tooltip: 'Applicants',
          onPressed: _openApplicants,
          icon: const Icon(Icons.groups_outlined),
        ),
        IconButton(
          tooltip: 'Sign out',
          onPressed: () {
            context.read<AuthCubit>().signOut();
          },
          icon: const Icon(Icons.logout),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StartupCubit, StartupState>(
      listener: (context, state) {
        if (state is StartupFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      builder: (context, state) {
        if (state is StartupLoading ||
            state is StartupInitial) {
          return Scaffold(
            appBar: _appBar(),
            body: const Center(
              child: CircularProgressIndicator(),
            ),
          );
        }

        if (state is StartupProfileMissing) {
          return Scaffold(
            appBar: _appBar(),
            body: _MissingProfileView(
              onCreate: () => _openProfileForm(),
            ),
          );
        }

        if (state is StartupProfileLoaded) {
          final profile = state.profile;

          return Scaffold(
            appBar: _appBar(),
            floatingActionButton: profile.isApproved
                ? FloatingActionButton.extended(
                    onPressed: () {
                      _openCreateOpportunity(profile);
                    },
                    backgroundColor: AppTheme.navy,
                    foregroundColor: Colors.white,
                    icon: const Icon(Icons.add),
                    label: const Text('Post role'),
                  )
                : null,
            body: ListView(
              padding: const EdgeInsets.fromLTRB(
                24,
                16,
                24,
                100,
              ),
              children: [
                _StartupHeading(profile: profile),
                const SizedBox(height: 20),
                _VerificationStatusCard(
                  profile: profile,
                  onUpdate: () {
                    _openProfileForm(profile: profile);
                  },
                ),
                const SizedBox(height: 28),
                const Text(
                  'Your opportunities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.navy,
                  ),
                ),
                const SizedBox(height: 14),
                BlocBuilder<OpportunityCubit,
                    OpportunityState>(
                  builder: (context, opportunityState) {
                    if (opportunityState
                        is OpportunityLoading) {
                      return const Center(
                        child: Padding(
                          padding: EdgeInsets.all(24),
                          child:
                              CircularProgressIndicator(),
                        ),
                      );
                    }

                    if (opportunityState
                            is OpportunityLoaded &&
                        opportunityState
                            .opportunities.isEmpty) {
                      return _EmptyOpportunityState(
                        approved: profile.isApproved,
                        onCreate: () {
                          _openCreateOpportunity(profile);
                        },
                      );
                    }

                    if (opportunityState
                        is OpportunityLoaded) {
                      return Column(
                        children: opportunityState
                            .opportunities
                            .map(
                              (opportunity) =>
                                  OpportunityCard(
                                opportunity: opportunity,
                                trailing:
                                    PopupMenuButton<String>(
                                  onSelected: (value) {
                                    final cubit = context.read<
                                        OpportunityCubit>();

                                    if (value == 'close') {
                                      cubit.closeOpportunity(
                                        opportunity.id,
                                      );
                                    }

                                    if (value == 'reopen') {
                                      cubit.reopenOpportunity(
                                        opportunity.id,
                                      );
                                    }

                                    if (value == 'delete') {
                                      cubit.deleteOpportunity(
                                        opportunity.id,
                                      );
                                    }
                                  },
                                  itemBuilder: (context) {
                                    return [
                                      if (opportunity.status ==
                                          'open')
                                        const PopupMenuItem(
                                          value: 'close',
                                          child: Text(
                                            'Close opportunity',
                                          ),
                                        ),
                                      if (opportunity.status ==
                                          'closed')
                                        const PopupMenuItem(
                                          value: 'reopen',
                                          child: Text(
                                            'Reopen opportunity',
                                          ),
                                        ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ];
                                  },
                                ),
                              ),
                            )
                            .toList(),
                      );
                    }

                    return const SizedBox.shrink();
                  },
                ),
              ],
            ),
          );
        }

        if (state is StartupFailure) {
          return Scaffold(
            appBar: _appBar(),
            body: Center(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: Text(
                  state.message,
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          );
        }

        return Scaffold(
          appBar: _appBar(),
          body: const SizedBox.shrink(),
        );
      },
    );
  }
}

class _StartupHeading extends StatelessWidget {
  final StartupProfileModel profile;

  const _StartupHeading({
    required this.profile,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Flexible(
                    child: Text(
                      profile.startupName,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.navy,
                      ),
                    ),
                  ),
                  if (profile.isApproved) ...[
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.verified,
                      color: AppTheme.purple,
                      size: 23,
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 6),
              Text(
                '${profile.industry} • ${profile.ventureStage}',
                style: const TextStyle(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _VerificationStatusCard extends StatelessWidget {
  final StartupProfileModel profile;
  final VoidCallback onUpdate;

  const _VerificationStatusCard({
    required this.profile,
    required this.onUpdate,
  });

  @override
  Widget build(BuildContext context) {
    late final Color backgroundColor;
    late final Color foregroundColor;
    late final IconData icon;
    late final String title;
    late final String message;

    if (profile.isApproved) {
      backgroundColor = const Color(0xFFEAF8EF);
      foregroundColor = Colors.green.shade700;
      icon = Icons.verified;
      title = 'Verified ALU startup';
      message =
          'Your organization can publish opportunities and review applicants.';
    } else if (profile.isRejected) {
      backgroundColor = const Color(0xFFFFEEEE);
      foregroundColor = Colors.red.shade700;
      icon = Icons.cancel_outlined;
      title = 'Verification rejected';
      message = profile.rejectionReason.isEmpty
          ? 'Update your profile and submit it again.'
          : profile.rejectionReason;
    } else {
      backgroundColor = const Color(0xFFFFF7D6);
      foregroundColor = Colors.orange.shade800;
      icon = Icons.hourglass_top_outlined;
      title = 'Verification pending';
      message =
          'An administrator must approve your startup before you can post new roles.';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                icon,
                color: foregroundColor,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                    color: foregroundColor,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(
              height: 1.45,
              color: foregroundColor,
            ),
          ),
          if (profile.isRejected) ...[
            const SizedBox(height: 16),
            OutlinedButton(
              onPressed: onUpdate,
              child: const Text(
                'Update and resubmit',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MissingProfileView extends StatelessWidget {
  final VoidCallback onCreate;

  const _MissingProfileView({
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.business_outlined,
              size: 58,
              color: AppTheme.purple,
            ),
            const SizedBox(height: 18),
            const Text(
              'Create your startup profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 23,
                fontWeight: FontWeight.w800,
                color: AppTheme.navy,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Provide information showing that your venture is recognized within the ALU ecosystem.',
              textAlign: TextAlign.center,
              style: TextStyle(
                height: 1.5,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onCreate,
              child:
                  const Text('Create startup profile'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyOpportunityState extends StatelessWidget {
  final bool approved;
  final VoidCallback onCreate;

  const _EmptyOpportunityState({
    required this.approved,
    required this.onCreate,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE4E7EC),
        ),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.work_outline,
            size: 42,
            color: AppTheme.purple,
          ),
          const SizedBox(height: 14),
          Text(
            approved
                ? 'No opportunities posted yet'
                : 'Posting is currently locked',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.navy,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            approved
                ? 'Create your first role so students can discover and apply.'
                : 'Your startup must be approved before posting opportunities.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              height: 1.5,
              color: AppTheme.textSecondary,
            ),
          ),
          if (approved) ...[
            const SizedBox(height: 18),
            ElevatedButton(
              onPressed: onCreate,
              child:
                  const Text('Create opportunity'),
            ),
          ],
        ],
      ),
    );
  }
}