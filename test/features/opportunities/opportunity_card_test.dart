import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:alu_venture_link/features/opportunities/data/models/opportunity_model.dart';
import 'package:alu_venture_link/features/opportunities/presentation/widgets/opportunity_card.dart';

void main() {
  testWidgets(
    'OpportunityCard displays role information and match percentage',
    (tester) async {
      final opportunity = OpportunityModel(
        id: 'opportunity-1',
        ownerId: 'startup-1',
        startupName: 'GreenTech Venture',
        title: 'Flutter Developer Intern',
        description:
            'Support the development of a mobile application for students.',
        requiredSkills: const ['Flutter', 'Firebase'],
        opportunityType: 'Internship',
        workMode: 'Hybrid',
        hoursPerWeek: '10',
        status: 'open',
        deadline: DateTime(2026, 8, 1),
        createdAt: DateTime(2026, 7, 1),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: OpportunityCard(
                opportunity: opportunity,
                matchPercentage: 75,
              ),
            ),
          ),
        ),
      );

      expect(find.text('Flutter Developer Intern'), findsOneWidget);

      expect(find.text('GreenTech Venture'), findsOneWidget);

      expect(find.textContaining('75% match'), findsOneWidget);

      expect(find.text('Flutter'), findsOneWidget);

      expect(find.text('Firebase'), findsOneWidget);

      expect(find.text('Hybrid'), findsOneWidget);
    },
  );
}
