import 'package:flutter_test/flutter_test.dart';
import 'package:alu_venture_link/features/auth/data/models/app_user.dart';

void main() {
  group('AppUser', () {
    AppUser createUser({String role = 'student'}) {
      return AppUser(
        uid: 'user-123',
        fullName: 'Tifare Kaseke',
        email: 'tifare@alustudent.com',
        role: role,
        campus: 'ALU Rwanda',
        program: 'Software Engineering',
        skills: const ['Flutter', 'Firebase'],
        profileImageUrl: '',
        bio: 'Software engineering student.',
        portfolioUrl: '',
        linkedInUrl: '',
        githubUrl: '',
        availabilityHours: 10,
        profileCompleted: true,
      );
    }

    test('recognizes a student role', () {
      final user = createUser();

      expect(user.isStudent, isTrue);
      expect(user.isStartup, isFalse);
      expect(user.isAdmin, isFalse);
    });

    test('recognizes a startup role', () {
      final user = createUser(role: 'startup');

      expect(user.isStartup, isTrue);
      expect(user.isStudent, isFalse);
      expect(user.isAdmin, isFalse);
    });

    test('recognizes an admin role', () {
      final user = createUser(role: 'admin');

      expect(user.isAdmin, isTrue);
      expect(user.isStudent, isFalse);
      expect(user.isStartup, isFalse);
    });

    test('copyWith preserves unchanged information', () {
      final original = createUser();

      final updated = original.copyWith(
        availabilityHours: 15,
        bio: 'Flutter developer and product designer.',
      );

      expect(updated.uid, original.uid);
      expect(updated.email, original.email);
      expect(updated.role, original.role);
      expect(updated.skills, original.skills);
      expect(updated.availabilityHours, 15);
      expect(updated.bio, 'Flutter developer and product designer.');
    });

    test('toMap contains important profile fields', () {
      final map = createUser().toMap();

      expect(map['fullName'], 'Tifare Kaseke');
      expect(map['role'], 'student');
      expect(map['program'], 'Software Engineering');
      expect(map['skills'], ['Flutter', 'Firebase']);
      expect(map['profileCompleted'], isTrue);
    });
  });
}
