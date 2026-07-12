import 'package:flutter_test/flutter_test.dart';
import 'package:alu_venture_link/features/applications/data/models/application_model.dart';

void main() {
  ApplicationModel createApplication({
    String status = 'submitted',
    DateTime? interviewDateTime,
    String interviewMode = '',
  }) {
    return ApplicationModel(
      id: 'application-1',
      opportunityId: 'opportunity-1',
      opportunityTitle: 'Flutter Developer Intern',
      startupOwnerId: 'startup-1',
      startupName: 'Test Venture',
      studentId: 'student-1',
      studentName: 'Tifare Kaseke',
      studentEmail: 'tifare@alustudent.com',
      coverLetter: 'I would like to apply.',
      status: status,
      interviewMode: interviewMode,
      interviewLocationOrLink: '',
      interviewNotes: '',
      interviewScheduledBy: '',
      submittedAt: DateTime(2026, 7, 1),
      interviewDateTime: interviewDateTime,
    );
  }

  group('ApplicationModel', () {
    test('detects a scheduled interview', () {
      final application = createApplication(
        status: 'interview',
        interviewDateTime: DateTime(2026, 7, 20, 10),
        interviewMode: 'Google Meet',
      );

      expect(application.hasInterview, isTrue);
    });

    test('does not report an interview without a mode', () {
      final application = createApplication(
        status: 'interview',
        interviewDateTime: DateTime(2026, 7, 20, 10),
      );

      expect(application.hasInterview, isFalse);
    });

    test('allows an active application to be withdrawn', () {
      final application = createApplication(status: 'underReview');

      expect(application.canWithdraw, isTrue);
    });

    test('does not allow accepted application withdrawal', () {
      final application = createApplication(status: 'accepted');

      expect(application.canWithdraw, isFalse);
    });

    test('does not allow rejected application withdrawal', () {
      final application = createApplication(status: 'rejected');

      expect(application.canWithdraw, isFalse);
    });

    test('does not allow repeated withdrawal', () {
      final application = createApplication(status: 'withdrawn');

      expect(application.canWithdraw, isFalse);
    });
  });
}
