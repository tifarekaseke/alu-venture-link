import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/models/app_user.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../notifications/presentation/cubit/notification_cubit.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../../opportunities/presentation/cubit/opportunity_cubit.dart';
import '../../../opportunities/presentation/cubit/opportunity_state.dart';
import '../../../opportunities/presentation/screens/create_opportunity_screen.dart';
import '../../../opportunities/presentation/widgets/opportunity_card.dart';
import '../../data/models/startup_profile_model.dart';
import '../cubit/startup_cubit.dart';
import '../cubit/startup_state.dart';
import 'create_startup_profile_screen.dart';

class StartupDashboardScreen extends StatefulWidget {
  final AppUser user;
  final VoidCallback onOpenApplicants;
  final VoidCallback onOpenAnalytics;
  final VoidCallback onOpenProfile;

  const StartupDashboardScreen({
    required this.user,
    required this.onOpenApplicants,
    required this.onOpenAnalytics,
    required this.onOpenProfile,
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

  Future<void> _openProfileForm({
    StartupProfileModel? profile,
  }) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CreateStartupProfileScreen(
          user: widget.user,
          existingProfile: profile,
        ),
      ),
    );
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotificationsScreen(
          user: widget.user,
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

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<StartupCubit, StartupState>(
      listener: (context, state) {
        if (state is StartupFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }
      },
      builder: (context, state) {
        if (state is StartupInitial ||
            state is StartupLoading) {
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
              onCreate: () {
                _openProfileForm();
              },
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
            body: RefreshIndicator(
              onRefresh: () async {
                context
                    .read<StartupCubit>()
                    .watchStartupProfile(
                      widget.user.uid,
                    );

                context
                    .read<OpportunityCubit>()
                    .watchStartupOpportunities(
                      widget.user.uid,
                    );

                await Future<void>.delayed(
                  const Duration(milliseconds: 500),
                );
              },
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  100,
                ),
                children: [
                  _DashboardHero(
                    profile: profile,
                    onOpenProfile:
                        widget.onOpenProfile,
                  ),

                  const SizedBox(height: 20),

                  _QuickActions(
                    onOpenApplicants:
                        widget.onOpenApplicants,
                    onOpenAnalytics:
                        widget.onOpenAnalytics,
                    onOpenProfile:
                        widget.onOpenProfile,
                  ),

                  const SizedBox(height: 22),

                  _VerificationStatusCard(
                    profile: profile,
                    onUpdate: () {
                      _openProfileForm(
                        profile: profile,
                      );
                    },
                  ),

                  const SizedBox(height: 28),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Your opportunities',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight:
                                FontWeight.w800,
                            color: AppTheme.navy,
                          ),
                        ),
                      ),
                      if (profile.isApproved)
                        TextButton.icon(
                          onPressed: () {
                            _openCreateOpportunity(
                              profile,
                            );
                          },
                          icon: const Icon(
                            Icons.add,
                          ),
                          label: const Text('New role'),
                        ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  BlocBuilder<OpportunityCubit,
                      OpportunityState>(
                    builder: (context, opportunityState) {
                      if (opportunityState
                              is OpportunityLoading ||
                          opportunityState
                              is OpportunityInitial) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(28),
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
                            _openCreateOpportunity(
                              profile,
                            );
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
                                  opportunity:
                                      opportunity,
                                  trailing:
                                      PopupMenuButton<String>(
                                    tooltip:
                                        'Opportunity actions',
                                    onSelected: (value) {
                                      final cubit = context
                                          .read<
                                              OpportunityCubit>();

                                      if (value ==
                                          'close') {
                                        cubit
                                            .closeOpportunity(
                                          opportunity.id,
                                        );
                                      }

                                      if (value ==
                                          'reopen') {
                                        cubit
                                            .reopenOpportunity(
                                          opportunity.id,
                                        );
                                      }

                                      if (value ==
                                          'delete') {
                                        cubit
                                            .deleteOpportunity(
                                          opportunity.id,
                                        );
                                      }
                                    },
                                    itemBuilder: (context) {
                                      return [
                                        if (opportunity
                                                .status ==
                                            'open')
                                          const PopupMenuItem(
                                            value: 'close',
                                            child: Text(
                                              'Close opportunity',
                                            ),
                                          ),
                                        if (opportunity
                                                .status ==
                                            'closed')
                                          const PopupMenuItem(
                                            value: 'reopen',
                                            child: Text(
                                              'Reopen opportunity',
                                            ),
                                          ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Text(
                                            'Delete opportunity',
                                          ),
                                        ),
                                      ];
                                    },
                                  ),
                                ),
                              )
                              .toList(),
                        );
                      }

                      if (opportunityState
                          is OpportunityFailure) {
                        return _DashboardError(
                          message:
                              opportunityState.message,
                        );
                      }

                      return const SizedBox.shrink();
                    },
                  ),
                ],
              ),
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

  AppBar _appBar() {
    return AppBar(
      title: const Text('Startup Dashboard'),
      actions: [
        NotificationBell(
          onPressed: _openNotifications,
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
}

class _DashboardHero extends StatelessWidget {
  final StartupProfileModel profile;
  final VoidCallback onOpenProfile;

  const _DashboardHero({
    required this.profile,
    required this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AppTheme.navy,
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(24),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: const Icon(
                  Icons.rocket_launch_outlined,
                  color: AppTheme.gold,
                  size: 29,
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
                        Flexible(
                          child: Text(
                            profile.startupName,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                        ),
                        if (profile.isApproved) ...[
                          const SizedBox(width: 7),
                          const Icon(
                            Icons.verified,
                            color: AppTheme.gold,
                            size: 21,
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      '${profile.industry} • ${profile.ventureStage}',
                      style: const TextStyle(
                        color: Colors.white70,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            profile.description,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: Colors.white70,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          TextButton.icon(
            onPressed: onOpenProfile,
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.gold,
              padding: EdgeInsets.zero,
            ),
            icon: const Icon(
              Icons.arrow_forward,
            ),
            label: const Text(
              'View startup profile',
            ),
          ),
        ],
      ),
    );
  }
}

class _QuickActions extends StatelessWidget {
  final VoidCallback onOpenApplicants;
  final VoidCallback onOpenAnalytics;
  final VoidCallback onOpenProfile;

  const _QuickActions({
    required this.onOpenApplicants,
    required this.onOpenAnalytics,
    required this.onOpenProfile,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final width =
            (constraints.maxWidth - 20) / 3;

        return Row(
          children: [
            SizedBox(
              width: width,
              child: _QuickActionCard(
                icon: Icons.groups_outlined,
                label: 'Applicants',
                onTap: onOpenApplicants,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: width,
              child: _QuickActionCard(
                icon: Icons.insights_outlined,
                label: 'Analytics',
                onTap: onOpenAnalytics,
              ),
            ),
            const SizedBox(width: 10),
            SizedBox(
              width: width,
              child: _QuickActionCard(
                icon: Icons.business_outlined,
                label: 'Profile',
                onTap: onOpenProfile,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickActionCard({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: 8,
            vertical: 16,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE4E7EC),
            ),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: AppTheme.purple,
              ),
              const SizedBox(height: 9),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppTheme.navy,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
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
    late final Color background;
    late final Color foreground;
    late final IconData icon;
    late final String title;
    late final String message;

    if (profile.isApproved) {
      background = const Color(0xFFEAF8EF);
      foreground = Colors.green.shade700;
      icon = Icons.verified;
      title = 'Verified ALU startup';
      message =
          'Your venture can publish opportunities and manage applicants.';
    } else if (profile.isRejected) {
      background = const Color(0xFFFFEEEE);
      foreground = Colors.red.shade700;
      icon = Icons.cancel_outlined;
      title = 'Verification needs changes';
      message = profile.rejectionReason.isEmpty
          ? 'Update your profile and submit it again.'
          : profile.rejectionReason;
    } else {
      background = const Color(0xFFFFF7D6);
      foreground = Colors.orange.shade800;
      icon = Icons.hourglass_top_outlined;
      title = 'Verification pending';
      message =
          'An administrator must approve your startup before you can post roles.';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: background,
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
                color: foreground,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: foreground,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            message,
            style: TextStyle(
              color: foreground,
              height: 1.45,
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
              size: 62,
              color: AppTheme.purple,
            ),
            const SizedBox(height: 18),
            const Text(
              'Create your startup profile',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.navy,
                fontSize: 23,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Provide your venture information and submit it for ALU verification.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onCreate,
              child: const Text(
                'Create startup profile',
              ),
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
      padding: const EdgeInsets.all(24),
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
            size: 46,
            color: AppTheme.purple,
          ),
          const SizedBox(height: 14),
          Text(
            approved
                ? 'No opportunities posted yet'
                : 'Opportunity posting is locked',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.navy,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            approved
                ? 'Create your first role and begin receiving student applications.'
                : 'Complete verification before publishing opportunities.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
          if (approved) ...[
            const SizedBox(height: 18),
            ElevatedButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.add),
              label: const Text(
                'Create opportunity',
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DashboardError extends StatelessWidget {
  final String message;

  const _DashboardError({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.red.shade700,
          height: 1.5,
        ),
      ),
    );
  }
}