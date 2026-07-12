import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/models/app_user.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/models/startup_profile_model.dart';
import '../cubit/startup_cubit.dart';
import '../cubit/startup_state.dart';

class AdminVerificationScreen extends StatefulWidget {
  final AppUser user;

  const AdminVerificationScreen({
    required this.user,
    super.key,
  });

  @override
  State<AdminVerificationScreen> createState() =>
      _AdminVerificationScreenState();
}

class _AdminVerificationScreenState
    extends State<AdminVerificationScreen> {
  @override
  void initState() {
    super.initState();

    context.read<StartupCubit>().watchPendingProfiles();
  }

  Future<void> _approve(
    StartupProfileModel profile,
  ) async {
    final success =
        await context.read<StartupCubit>().approveProfile(
              profileId: profile.id,
              adminId: widget.user.uid,
            );

    if (!mounted || !success) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${profile.startupName} has been approved.',
        ),
      ),
    );
  }

  Future<void> _reject(
    StartupProfileModel profile,
  ) async {
    final controller = TextEditingController();

    final reason = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Reject verification'),
          content: TextField(
            controller: controller,
            minLines: 3,
            maxLines: 5,
            decoration: const InputDecoration(
              labelText: 'Reason',
              hintText:
                  'Explain what the startup must correct.',
              alignLabelWithHint: true,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Cancel'),
            ),
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.length < 5) {
                  return;
                }

                Navigator.of(dialogContext).pop(value);
              },
              child: const Text('Reject'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (reason == null || !mounted) {
      return;
    }

    final success =
        await context.read<StartupCubit>().rejectProfile(
              profileId: profile.id,
              adminId: widget.user.uid,
              reason: reason,
            );

    if (!mounted || !success) {
      return;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${profile.startupName} has been rejected.',
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ALU Verification Admin'),
        actions: [
          IconButton(
            tooltip: 'Sign out',
            onPressed: () {
              context.read<AuthCubit>().signOut();
            },
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: BlocConsumer<StartupCubit, StartupState>(
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
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is StartupProfilesLoaded &&
              state.profiles.isEmpty) {
            return const _EmptyVerificationState();
          }

          if (state is StartupProfilesLoaded) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                24,
                18,
                24,
                32,
              ),
              children: [
                const Text(
                  'Pending verification',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.navy,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Review whether each venture is recognized within the ALU ecosystem.',
                  style: TextStyle(
                    height: 1.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ...state.profiles.map(
                  (profile) => _VerificationCard(
                    profile: profile,
                    onApprove: () => _approve(profile),
                    onReject: () => _reject(profile),
                  ),
                ),
              ],
            );
          }

          if (state is StartupFailure) {
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

class _VerificationCard extends StatelessWidget {
  final StartupProfileModel profile;
  final VoidCallback onApprove;
  final VoidCallback onReject;

  const _VerificationCard({
    required this.profile,
    required this.onApprove,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 18),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
        side: const BorderSide(
          color: Color(0xFFE4E7EC),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppTheme.navy,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.rocket_launch_outlined,
                    color: AppTheme.gold,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        profile.startupName,
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.navy,
                        ),
                      ),
                      Text(
                        '${profile.industry} • ${profile.ventureStage}',
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                const Chip(
                  label: Text('Pending'),
                  side: BorderSide.none,
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              profile.description,
              style: const TextStyle(
                height: 1.5,
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 16),
            _Detail(
              label: 'Founder',
              value:
                  '${profile.ownerName} (${profile.ownerEmail})',
            ),
            _Detail(
              label: 'Recognition',
              value: profile.recognitionType,
            ),
            _Detail(
              label: 'Reference',
              value: profile.recognitionReference,
            ),
            if (profile.website.isNotEmpty)
              _Detail(
                label: 'Website',
                value: profile.website,
              ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: onReject,
                    child: const Text('Reject'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: onApprove,
                    icon: const Icon(Icons.verified),
                    label: const Text('Approve'),
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

class _Detail extends StatelessWidget {
  final String label;
  final String value;

  const _Detail({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 7),
      child: Text.rich(
        TextSpan(
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: AppTheme.navy,
              ),
            ),
            TextSpan(
              text: value,
              style: const TextStyle(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyVerificationState extends StatelessWidget {
  const _EmptyVerificationState();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(30),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.verified_user_outlined,
              size: 58,
              color: AppTheme.purple,
            ),
            SizedBox(height: 18),
            Text(
              'No pending startups',
              style: TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.w800,
                color: AppTheme.navy,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'New startup verification requests will appear here.',
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