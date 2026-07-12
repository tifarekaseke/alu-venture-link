import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/models/app_user.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../auth/presentation/cubit/auth_state.dart';
import 'edit_student_profile_screen.dart';

class StudentProfileScreen extends StatelessWidget {
  const StudentProfileScreen({super.key});

  int _calculateCompletion(AppUser user) {
    final checks = <bool>[
      user.fullName.trim().isNotEmpty,
      user.program.trim().isNotEmpty,
      user.campus.trim().isNotEmpty,
      user.bio.trim().isNotEmpty,
      user.skills.isNotEmpty,
      user.availabilityHours > 0,
      user.portfolioUrl.trim().isNotEmpty ||
          user.linkedInUrl.trim().isNotEmpty ||
          user.githubUrl.trim().isNotEmpty,
    ];

    final completed = checks.where((check) => check).length;

    return ((completed / checks.length) * 100).round();
  }

  String _initials(String fullName) {
    final parts = fullName
        .trim()
        .split(RegExp(r'\s+'))
        .where((part) => part.isNotEmpty)
        .toList();

    if (parts.isEmpty) {
      return 'S';
    }

    if (parts.length == 1) {
      return parts.first.substring(0, 1).toUpperCase();
    }

    return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
  }

  void _openEditor(BuildContext context, AppUser user) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => EditStudentProfileScreen(user: user),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        if (state is! AuthAuthenticated) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = state.user;
        final completion = _calculateCompletion(user);

        return Scaffold(
          appBar: AppBar(
            title: const Text('My Profile'),
            actions: [
              IconButton(
                tooltip: 'Edit profile',
                onPressed: () {
                  _openEditor(context, user);
                },
                icon: const Icon(Icons.edit_outlined),
              ),
            ],
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
            children: [
              Center(
                child: CircleAvatar(
                  radius: 48,
                  backgroundColor: AppTheme.navy,
                  child: Text(
                    _initials(user.fullName),
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.gold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                user.fullName,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppTheme.navy,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                user.program.isEmpty ? 'Program not added' : user.program,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 4),
              Text(
                user.campus,
                textAlign: TextAlign.center,
                style: const TextStyle(color: AppTheme.textSecondary),
              ),
              const SizedBox(height: 26),

              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFE4E7EC)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Expanded(
                          child: Text(
                            'Profile completion',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.navy,
                            ),
                          ),
                        ),
                        Text(
                          '$completion%',
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.purple,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    LinearProgressIndicator(
                      value: completion / 100,
                      minHeight: 9,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      completion == 100
                          ? 'Your opportunity profile is complete.'
                          : 'Complete your profile to help startups evaluate your fit.',
                      style: const TextStyle(
                        height: 1.4,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

              _ProfileSection(
                title: 'About',
                child: Text(
                  user.bio.isEmpty
                      ? 'No professional bio added yet.'
                      : user.bio,
                  style: const TextStyle(
                    height: 1.55,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),

              const SizedBox(height: 18),

              _ProfileSection(
                title: 'Skills',
                child: user.skills.isEmpty
                    ? const Text(
                        'No skills added yet.',
                        style: TextStyle(color: AppTheme.textSecondary),
                      )
                    : Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: user.skills
                            .map(
                              (skill) => Chip(
                                label: Text(skill),
                                side: BorderSide.none,
                                backgroundColor: const Color(0xFFFFF7D6),
                              ),
                            )
                            .toList(),
                      ),
              ),

              const SizedBox(height: 18),

              _ProfileSection(
                title: 'Availability',
                child: _InformationRow(
                  icon: Icons.schedule_outlined,
                  label: user.availabilityHours > 0
                      ? '${user.availabilityHours} hours per week'
                      : 'Not specified',
                ),
              ),

              const SizedBox(height: 18),

              _ProfileSection(
                title: 'Professional links',
                child: Column(
                  children: [
                    _InformationRow(
                      icon: Icons.language_outlined,
                      label: user.portfolioUrl.isEmpty
                          ? 'Portfolio not added'
                          : user.portfolioUrl,
                    ),
                    const Divider(),
                    _InformationRow(
                      icon: Icons.business_center_outlined,
                      label: user.linkedInUrl.isEmpty
                          ? 'LinkedIn not added'
                          : user.linkedInUrl,
                    ),
                    const Divider(),
                    _InformationRow(
                      icon: Icons.code,
                      label: user.githubUrl.isEmpty
                          ? 'GitHub not added'
                          : user.githubUrl,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 24),

              ElevatedButton.icon(
                onPressed: () {
                  _openEditor(context, user);
                },
                icon: const Icon(Icons.edit_outlined),
                label: const Text('Edit profile'),
              ),

              const SizedBox(height: 12),

              OutlinedButton.icon(
                onPressed: () {
                  context.read<AuthCubit>().signOut();
                },
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 54),
                ),
                icon: const Icon(Icons.logout),
                label: const Text('Sign out'),
              ),
            ],
          ),
        );
      },
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
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppTheme.navy,
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
        Icon(icon, color: AppTheme.purple, size: 21),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(height: 1.45, color: AppTheme.textSecondary),
          ),
        ),
      ],
    );
  }
}
