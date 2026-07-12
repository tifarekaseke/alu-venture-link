import 'package:equatable/equatable.dart';

class OpportunityPerformance extends Equatable {
  final String opportunityId;
  final String title;
  final String status;
  final int applications;
  final int interviews;
  final int accepted;

  const OpportunityPerformance({
    required this.opportunityId,
    required this.title,
    required this.status,
    required this.applications,
    required this.interviews,
    required this.accepted,
  });

  double get acceptanceRate {
    if (applications == 0) {
      return 0;
    }

    return (accepted / applications) * 100;
  }

  @override
  List<Object?> get props => [
    opportunityId,
    title,
    status,
    applications,
    interviews,
    accepted,
  ];
}

class StartupAnalytics extends Equatable {
  final int totalOpportunities;
  final int openOpportunities;
  final int closedOpportunities;

  final int totalApplications;
  final int submitted;
  final int underReview;
  final int shortlisted;
  final int interviews;
  final int accepted;
  final int rejected;
  final int withdrawn;

  final List<OpportunityPerformance> opportunityPerformance;

  const StartupAnalytics({
    required this.totalOpportunities,
    required this.openOpportunities,
    required this.closedOpportunities,
    required this.totalApplications,
    required this.submitted,
    required this.underReview,
    required this.shortlisted,
    required this.interviews,
    required this.accepted,
    required this.rejected,
    required this.withdrawn,
    required this.opportunityPerformance,
  });

  int get activePipeline {
    return submitted + underReview + shortlisted + interviews;
  }

  double get acceptanceRate {
    if (totalApplications == 0) {
      return 0;
    }

    return (accepted / totalApplications) * 100;
  }

  double get interviewRate {
    if (totalApplications == 0) {
      return 0;
    }

    return (interviews / totalApplications) * 100;
  }

  @override
  List<Object?> get props => [
    totalOpportunities,
    openOpportunities,
    closedOpportunities,
    totalApplications,
    submitted,
    underReview,
    shortlisted,
    interviews,
    accepted,
    rejected,
    withdrawn,
    opportunityPerformance,
  ];
}
