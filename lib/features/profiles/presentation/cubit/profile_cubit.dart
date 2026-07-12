import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/repositories/profile_repository.dart';
import 'profile_state.dart';

class ProfileCubit extends Cubit<ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileCubit(this._profileRepository)
      : super(const ProfileInitial());

  Future<void> updateStudentProfile({
    required String userId,
    required String fullName,
    required String campus,
    required String program,
    required String bio,
    required List<String> skills,
    required int availabilityHours,
    required String portfolioUrl,
    required String linkedInUrl,
    required String githubUrl,
  }) async {
    emit(const ProfileSaving());

    try {
      await _profileRepository.updateStudentProfile(
        userId: userId,
        fullName: fullName,
        campus: campus,
        program: program,
        bio: bio,
        skills: skills,
        availabilityHours: availabilityHours,
        portfolioUrl: portfolioUrl,
        linkedInUrl: linkedInUrl,
        githubUrl: githubUrl,
      );

      emit(const ProfileSaved());
    } catch (error) {
      if (error is FirebaseException) {
        if (error.code == 'permission-denied') {
          emit(
            const ProfileFailure(
              'Firebase denied the profile update. Check the Firestore rules.',
            ),
          );
          return;
        }

        if (error.code == 'unavailable') {
          emit(
            const ProfileFailure(
              'Firebase is temporarily unavailable. Check your connection.',
            ),
          );
          return;
        }

        emit(
          ProfileFailure(
            error.message ?? 'A Firebase error occurred.',
          ),
        );
        return;
      }

      emit(
        const ProfileFailure(
          'The student profile could not be updated.',
        ),
      );
    }
  }

  void reset() {
    emit(const ProfileInitial());
  }
}