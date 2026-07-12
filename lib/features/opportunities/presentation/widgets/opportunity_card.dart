import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../../../core/theme/app_theme.dart';
import '../../data/models/opportunity_model.dart';

class OpportunityCard extends StatelessWidget {
  final OpportunityModel opportunity;
  final VoidCallback? onTap;
  final Widget? trailing;
  final int? matchPercentage;

  const OpportunityCard({
    required this.opportunity,
    this.onTap,
    this.trailing,
    this.matchPercentage,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final deadlineText = opportunity.deadline == null
        ? 'No deadline'
        : DateFormat('dd MMM yyyy').format(opportunity.deadline!);

    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 14),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Color(0xFFE4E7EC)),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: AppTheme.navy,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(
                      Icons.rocket_launch_outlined,
                      color: AppTheme.gold,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          opportunity.title,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.navy,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          opportunity.startupName,
                          style: const TextStyle(color: AppTheme.textSecondary),
                        ),
                      ],
                    ),
                  ),
                  trailing ?? const SizedBox.shrink(),
                ],
              ),

              if (matchPercentage != null) ...[
                const SizedBox(height: 14),
                _MatchBadge(percentage: matchPercentage!),
              ],

              const SizedBox(height: 14),

              Text(
                opportunity.description,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  height: 1.45,
                  color: AppTheme.textSecondary,
                ),
              ),

              const SizedBox(height: 14),

              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  _Tag(label: opportunity.opportunityType),
                  _Tag(label: opportunity.workMode),
                  _Tag(label: '${opportunity.hoursPerWeek} hrs/week'),
                  _Tag(label: opportunity.status),
                ],
              ),

              if (opportunity.requiredSkills.isNotEmpty) ...[
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: opportunity.requiredSkills
                      .map((skill) => _SkillChip(label: skill))
                      .toList(),
                ),
              ],

              const SizedBox(height: 14),

              Row(
                children: [
                  const Icon(
                    Icons.calendar_today_outlined,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Deadline: $deadlineText',
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MatchBadge extends StatelessWidget {
  final int percentage;

  const _MatchBadge({required this.percentage});

  Color get _foregroundColor {
    if (percentage >= 75) {
      return Colors.green.shade700;
    }

    if (percentage >= 40) {
      return Colors.orange.shade800;
    }

    return AppTheme.purple;
  }

  Color get _backgroundColor {
    if (percentage >= 75) {
      return const Color(0xFFEAF8EF);
    }

    if (percentage >= 40) {
      return const Color(0xFFFFF7D6);
    }

    return const Color(0xFFF1EDFF);
  }

  String get _message {
    if (percentage >= 75) {
      return 'Strong match';
    }

    if (percentage >= 40) {
      return 'Potential match';
    }

    return 'Build more matching skills';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      decoration: BoxDecoration(
        color: _backgroundColor,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.auto_awesome, size: 17, color: _foregroundColor),
          const SizedBox(width: 7),
          Text(
            '$percentage% match',
            style: TextStyle(
              fontWeight: FontWeight.w800,
              color: _foregroundColor,
            ),
          ),
          const SizedBox(width: 7),
          Text(
            '• $_message',
            style: TextStyle(fontSize: 12, color: _foregroundColor),
          ),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String label;

  const _Tag({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text(label),
      backgroundColor: const Color(0xFFF2F4F7),
      side: BorderSide.none,
      labelStyle: const TextStyle(fontSize: 12, color: AppTheme.navy),
    );
  }
}

class _SkillChip extends StatelessWidget {
  final String label;

  const _SkillChip({required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      visualDensity: VisualDensity.compact,
      label: Text(label),
      backgroundColor: const Color(0xFFFFF7D6),
      side: BorderSide.none,
      labelStyle: const TextStyle(fontSize: 12, color: AppTheme.deepNavy),
    );
  }
}
