import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/models/app_user.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../data/models/startup_profile_model.dart';
import '../cubit/startup_cubit.dart';
import '../cubit/startup_state.dart';
import 'create_startup_profile_screen.dart';

class StartupProfileScreen extends StatefulWidget {
  final AppUser user;

  const StartupProfileScreen({required this.user, super.key});

  @override
  State<StartupProfileScreen> createState() => _StartupProfileScreenState();
}

class _StartupProfileScreenState extends State<StartupProfileScreen> {
  @override
  void initState() {
    super.initState();

    context.read<StartupCubit>().watchStartupProfile(widget.user.uid);
  }

  Future<void> _openProfileForm({StartupProfileModel? profile}) async {
    await Navigator.of(context).push<bool>(
      MaterialPageRoute<bool>(
        builder: (_) => CreateStartupProfileScreen(
          user: widget.user,
          existingProfile: profile,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Profile'),
        actions: [
          BlocBuilder<StartupCubit, StartupState>(
            builder: (context, state) {
              if (state is StartupProfileLoaded) {
                return IconButton(
                  tooltip: 'Edit profile',
                  onPressed: () {
                    _openProfileForm(profile: state.profile);
                  },
                  icon: const Icon(Icons.edit_outlined),
                );
              }

              return const SizedBox.shrink();
            },
          ),
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
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.message)));
          }
        },
        builder: (context, state) {
          if (state is StartupInitial || state is StartupLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is StartupProfileMissing) {
            return _MissingStartupProfile(
              onCreate: () {
                _openProfileForm();
              },
            );
          }

          if (state is StartupProfileLoaded) {
            return _StartupProfileContent(
              profile: state.profile,
              onEdit: () {
                _openProfileForm(profile: state.profile);
              },
            );
          }

          if (state is StartupFailure) {
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

class _StartupProfileContent extends StatelessWidget {
  final StartupProfileModel profile;
  final VoidCallback onEdit;

  const _StartupProfileContent({required this.profile, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 36),
      children: [
        Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: AppTheme.navy,
            borderRadius: BorderRadius.circular(26),
          ),
          child: Column(
            children: [
              Container(
                width: 76,
                height: 76,
                decoration: BoxDecoration(
                  color: Colors.white.withAlpha(25),
                  borderRadius: BorderRadius.circular(22),
                ),
                child: const Icon(
                  Icons.rocket_launch_outlined,
                  color: AppTheme.gold,
                  size: 38,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      profile.startupName,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 25,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  if (profile.isApproved) ...[
                    const SizedBox(width: 8),
                    const Icon(Icons.verified, color: AppTheme.gold),
                  ],
                ],
              ),
              const SizedBox(height: 7),
              Text(
                '${profile.industry} • ${profile.ventureStage}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white70),
              ),
              const SizedBox(height: 16),
              _VerificationBadge(profile: profile),
            ],
          ),
        ),

        const SizedBox(height: 20),

        _ProfileSection(
          title: 'About the venture',
          child: Text(
            profile.description,
            style: const TextStyle(height: 1.55, color: AppTheme.textSecondary),
          ),
        ),

        const SizedBox(height: 16),

        _ProfileSection(
          title: 'Founder information',
          child: Column(
            children: [
              _InformationRow(
                icon: Icons.person_outline,
                label: profile.ownerName,
              ),
              const Divider(height: 26),
              _InformationRow(
                icon: Icons.email_outlined,
                label: profile.ownerEmail,
              ),
            ],
          ),
        ),

        const SizedBox(height: 16),

        _ProfileSection(
          title: 'ALU recognition',
          child: Column(
            children: [
              _InformationRow(
                icon: Icons.verified_user_outlined,
                label: profile.recognitionType,
              ),
              const Divider(height: 26),
              _InformationRow(
                icon: Icons.badge_outlined,
                label: profile.recognitionReference,
              ),
            ],
          ),
        ),

        if (profile.website.isNotEmpty) ...[
          const SizedBox(height: 16),
          _ProfileSection(
            title: 'Online presence',
            child: _InformationRow(
              icon: Icons.language_outlined,
              label: profile.website,
            ),
          ),
        ],

        if (profile.isRejected && profile.rejectionReason.isNotEmpty) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: const Color(0xFFFFEEEE),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade700),
                    const SizedBox(width: 9),
                    Text(
                      'Verification feedback',
                      style: TextStyle(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  profile.rejectionReason,
                  style: TextStyle(height: 1.5, color: Colors.red.shade700),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 24),

        ElevatedButton.icon(
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
          label: Text(
            profile.isRejected
                ? 'Update and resubmit profile'
                : 'Edit startup profile',
          ),
        ),
      ],
    );
  }
}

class _VerificationBadge extends StatelessWidget {
  final StartupProfileModel profile;

  const _VerificationBadge({required this.profile});

  @override
  Widget build(BuildContext context) {
    late final String text;
    late final IconData icon;
    late final Color color;

    if (profile.isApproved) {
      text = 'Verified ALU startup';
      icon = Icons.verified;
      color = Colors.greenAccent;
    } else if (profile.isRejected) {
      text = 'Verification needs changes';
      icon = Icons.cancel_outlined;
      color = Colors.redAccent;
    } else {
      text = 'Verification pending';
      icon = Icons.hourglass_top_outlined;
      color = AppTheme.gold;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(20),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 7),
          Text(
            text,
            style: TextStyle(color: color, fontWeight: FontWeight.w800),
          ),
        ],
      ),
    );
  }
}

class _ProfileSection extends StatelessWidget {
  final String title;
  final Widget child;

  const _ProfileSection({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: const Color(0xFFE4E7EC)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.navy,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InformationRow extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InformationRow({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 21, color: AppTheme.purple),
        const SizedBox(width: 12),
        Expanded(
          child: SelectableText(
            label,
            style: const TextStyle(height: 1.45, color: AppTheme.textSecondary),
          ),
        ),
      ],
    );
  }
}

class _MissingStartupProfile extends StatelessWidget {
  final VoidCallback onCreate;

  const _MissingStartupProfile({required this.onCreate});

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
              'Complete your venture information and submit it for ALU verification.',
              textAlign: TextAlign.center,
              style: TextStyle(height: 1.5, color: AppTheme.textSecondary),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: onCreate,
              child: const Text('Create startup profile'),
            ),
          ],
        ),
      ),
    );
  }
}
