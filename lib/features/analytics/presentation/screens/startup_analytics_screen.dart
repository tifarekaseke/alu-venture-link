import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../auth/data/models/app_user.dart';
import '../../data/models/startup_analytics.dart';
import '../cubit/analytics_cubit.dart';
import '../cubit/analytics_state.dart';

class StartupAnalyticsScreen extends StatefulWidget {
  final AppUser user;

  const StartupAnalyticsScreen({
    required this.user,
    super.key,
  });

  @override
  State<StartupAnalyticsScreen> createState() =>
      _StartupAnalyticsScreenState();
}

class _StartupAnalyticsScreenState
    extends State<StartupAnalyticsScreen> {
  @override
  void initState() {
    super.initState();

    context
        .read<AnalyticsCubit>()
        .watchStartupAnalytics(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Startup Analytics'),
      ),
      body: BlocConsumer<AnalyticsCubit, AnalyticsState>(
        listener: (context, state) {
          if (state is AnalyticsFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
              ),
            );
          }
        },
        builder: (context, state) {
          if (state is AnalyticsInitial ||
              state is AnalyticsLoading) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (state is AnalyticsFailure) {
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

          if (state is AnalyticsLoaded) {
            return _AnalyticsContent(
              analytics: state.analytics,
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _AnalyticsContent extends StatelessWidget {
  final StartupAnalytics analytics;

  const _AnalyticsContent({
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(
        20,
        18,
        20,
        36,
      ),
      children: [
        const Text(
          'Live venture performance',
          style: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.w800,
            color: AppTheme.navy,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Understand how students are engaging with your opportunities and moving through the recruitment pipeline.',
          style: TextStyle(
            height: 1.5,
            color: AppTheme.textSecondary,
          ),
        ),
        const SizedBox(height: 24),

        _HeroAnalyticsCard(
          analytics: analytics,
        ),

        const SizedBox(height: 20),

        LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth =
                (constraints.maxWidth - 12) / 2;

            return Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                SizedBox(
                  width: itemWidth,
                  child: _MetricCard(
                    title: 'Opportunities',
                    value: analytics.totalOpportunities,
                    subtitle:
                        '${analytics.openOpportunities} open',
                    icon: Icons.work_outline,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _MetricCard(
                    title: 'Applications',
                    value: analytics.totalApplications,
                    subtitle:
                        '${analytics.activePipeline} active',
                    icon: Icons.groups_outlined,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _MetricCard(
                    title: 'Interviews',
                    value: analytics.interviews,
                    subtitle:
                        '${analytics.interviewRate.toStringAsFixed(0)}% rate',
                    icon: Icons.video_call_outlined,
                  ),
                ),
                SizedBox(
                  width: itemWidth,
                  child: _MetricCard(
                    title: 'Accepted',
                    value: analytics.accepted,
                    subtitle:
                        '${analytics.acceptanceRate.toStringAsFixed(0)}% rate',
                    icon: Icons.check_circle_outline,
                  ),
                ),
              ],
            );
          },
        ),

        const SizedBox(height: 28),

        const _SectionHeading(
          title: 'Candidate pipeline',
          subtitle:
              'Live distribution of candidates across each recruitment stage.',
        ),

        const SizedBox(height: 16),

        _PipelineCard(
          analytics: analytics,
        ),

        const SizedBox(height: 28),

        const _SectionHeading(
          title: 'Opportunity performance',
          subtitle:
              'Compare application, interview and acceptance activity by role.',
        ),

        const SizedBox(height: 16),

        if (analytics.opportunityPerformance.isEmpty)
          const _EmptyPerformanceState()
        else
          ...analytics.opportunityPerformance.map(
            (performance) => _OpportunityPerformanceCard(
              performance: performance,
            ),
          ),
      ],
    );
  }
}

class _HeroAnalyticsCard extends StatelessWidget {
  final StartupAnalytics analytics;

  const _HeroAnalyticsCard({
    required this.analytics,
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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.insights_outlined,
                color: AppTheme.gold,
                size: 30,
              ),
              SizedBox(width: 10),
              Text(
                'Recruitment overview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          Row(
            children: [
              Expanded(
                child: _HeroValue(
                  label: 'Total candidates',
                  value: analytics.totalApplications.toString(),
                ),
              ),
              Container(
                width: 1,
                height: 54,
                color: Colors.white24,
              ),
              Expanded(
                child: _HeroValue(
                  label: 'Acceptance rate',
                  value:
                      '${analytics.acceptanceRate.toStringAsFixed(0)}%',
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: analytics.acceptanceRate / 100,
              minHeight: 9,
              backgroundColor: Colors.white24,
              color: AppTheme.gold,
            ),
          ),
        ],
      ),
    );
  }
}

class _HeroValue extends StatelessWidget {
  final String label;
  final String value;

  const _HeroValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: AppTheme.gold,
            fontSize: 30,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 12,
          ),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final int value;
  final String subtitle;
  final IconData icon;

  const _MetricCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: const Color(0xFFE4E7EC),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFF1EDFF),
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(
              icon,
              color: AppTheme.purple,
              size: 21,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            value.toString(),
            style: const TextStyle(
              color: AppTheme.navy,
              fontSize: 26,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(
              color: AppTheme.navy,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            style: const TextStyle(
              color: AppTheme.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _PipelineCard extends StatelessWidget {
  final StartupAnalytics analytics;

  const _PipelineCard({
    required this.analytics,
  });

  @override
  Widget build(BuildContext context) {
    final maximum =
        analytics.totalApplications == 0
            ? 1
            : analytics.totalApplications;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE4E7EC),
        ),
      ),
      child: Column(
        children: [
          _PipelineBar(
            label: 'Submitted',
            value: analytics.submitted,
            maximum: maximum,
          ),
          _PipelineBar(
            label: 'Under review',
            value: analytics.underReview,
            maximum: maximum,
          ),
          _PipelineBar(
            label: 'Shortlisted',
            value: analytics.shortlisted,
            maximum: maximum,
          ),
          _PipelineBar(
            label: 'Interview',
            value: analytics.interviews,
            maximum: maximum,
          ),
          _PipelineBar(
            label: 'Accepted',
            value: analytics.accepted,
            maximum: maximum,
          ),
          _PipelineBar(
            label: 'Rejected',
            value: analytics.rejected,
            maximum: maximum,
          ),
          _PipelineBar(
            label: 'Withdrawn',
            value: analytics.withdrawn,
            maximum: maximum,
            showBottomSpacing: false,
          ),
        ],
      ),
    );
  }
}

class _PipelineBar extends StatelessWidget {
  final String label;
  final int value;
  final int maximum;
  final bool showBottomSpacing;

  const _PipelineBar({
    required this.label,
    required this.value,
    required this.maximum,
    this.showBottomSpacing = true,
  });

  @override
  Widget build(BuildContext context) {
    final fraction = value / maximum;

    return Padding(
      padding: EdgeInsets.only(
        bottom: showBottomSpacing ? 18 : 0,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    color: AppTheme.navy,
                  ),
                ),
              ),
              Text(
                value.toString(),
                style: const TextStyle(
                  fontWeight: FontWeight.w800,
                  color: AppTheme.purple,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: fraction,
              minHeight: 9,
              backgroundColor: const Color(0xFFF2F4F7),
              color: AppTheme.purple,
            ),
          ),
        ],
      ),
    );
  }
}

class _OpportunityPerformanceCard extends StatelessWidget {
  final OpportunityPerformance performance;

  const _OpportunityPerformanceCard({
    required this.performance,
  });

  @override
  Widget build(BuildContext context) {
    final isOpen = performance.status == 'open';

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(19),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: const Color(0xFFE4E7EC),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 43,
                height: 43,
                decoration: BoxDecoration(
                  color: AppTheme.navy,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.work_outline,
                  color: AppTheme.gold,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  performance.title,
                  style: const TextStyle(
                    color: AppTheme.navy,
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: isOpen
                      ? const Color(0xFFEAF8EF)
                      : const Color(0xFFF2F4F7),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isOpen ? 'Open' : 'Closed',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: isOpen
                        ? Colors.green.shade700
                        : AppTheme.textSecondary,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: _PerformanceValue(
                  label: 'Applications',
                  value: performance.applications,
                ),
              ),
              Expanded(
                child: _PerformanceValue(
                  label: 'Interviews',
                  value: performance.interviews,
                ),
              ),
              Expanded(
                child: _PerformanceValue(
                  label: 'Accepted',
                  value: performance.accepted,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Expanded(
                child: Text(
                  'Role acceptance rate',
                  style: TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ),
              Text(
                '${performance.acceptanceRate.toStringAsFixed(0)}%',
                style: const TextStyle(
                  color: AppTheme.purple,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: LinearProgressIndicator(
              value: performance.acceptanceRate / 100,
              minHeight: 8,
              backgroundColor: const Color(0xFFF2F4F7),
              color: AppTheme.purple,
            ),
          ),
        ],
      ),
    );
  }
}

class _PerformanceValue extends StatelessWidget {
  final String label;
  final int value;

  const _PerformanceValue({
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: const TextStyle(
            color: AppTheme.navy,
            fontSize: 21,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _SectionHeading extends StatelessWidget {
  final String title;
  final String subtitle;

  const _SectionHeading({
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: AppTheme.navy,
            fontSize: 20,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          subtitle,
          style: const TextStyle(
            color: AppTheme.textSecondary,
            height: 1.45,
          ),
        ),
      ],
    );
  }
}

class _EmptyPerformanceState extends StatelessWidget {
  const _EmptyPerformanceState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(21),
        border: Border.all(
          color: const Color(0xFFE4E7EC),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.insights_outlined,
            size: 48,
            color: AppTheme.purple,
          ),
          SizedBox(height: 14),
          Text(
            'No performance data yet',
            style: TextStyle(
              color: AppTheme.navy,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Publish an opportunity to begin collecting recruitment analytics.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.textSecondary,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}