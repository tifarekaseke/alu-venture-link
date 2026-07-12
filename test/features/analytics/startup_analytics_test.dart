import 'package:flutter_test/flutter_test.dart';
import 'package:alu_venture_link/features/analytics/data/models/startup_analytics.dart';

void main() {
  group('OpportunityPerformance', () {
    test('calculates acceptance rate', () {
      const performance = OpportunityPerformance(
        opportunityId: 'opportunity-1',
        title: 'Flutter Developer Intern',
        status: 'open',
        applications: 10,
        interviews: 4,
        accepted: 2,
      );

      expect(performance.acceptanceRate, 20);
    });

    test('returns zero when there are no applications', () {
      const performance = OpportunityPerformance(
        opportunityId: 'opportunity-1',
        title: 'Marketing Intern',
        status: 'open',
        applications: 0,
        interviews: 0,
        accepted: 0,
      );

      expect(performance.acceptanceRate, 0);
    });
  });

  group('StartupAnalytics', () {
    const analytics = StartupAnalytics(
      totalOpportunities: 4,
      openOpportunities: 3,
      closedOpportunities: 1,
      totalApplications: 20,
      submitted: 5,
      underReview: 4,
      shortlisted: 3,
      interviews: 4,
      accepted: 2,
      rejected: 1,
      withdrawn: 1,
      opportunityPerformance: [],
    );

    test('calculates the active candidate pipeline', () {
      expect(analytics.activePipeline, 16);
    });

    test('calculates the startup acceptance rate', () {
      expect(analytics.acceptanceRate, 10);
    });

    test('calculates the interview rate', () {
      expect(analytics.interviewRate, 20);
    });

    test('avoids division by zero', () {
      const emptyAnalytics = StartupAnalytics(
        totalOpportunities: 0,
        openOpportunities: 0,
        closedOpportunities: 0,
        totalApplications: 0,
        submitted: 0,
        underReview: 0,
        shortlisted: 0,
        interviews: 0,
        accepted: 0,
        rejected: 0,
        withdrawn: 0,
        opportunityPerformance: [],
      );

      expect(emptyAnalytics.acceptanceRate, 0);

      expect(emptyAnalytics.interviewRate, 0);
    });
  });
}
