import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/data/models/app_user.dart';
import '../../data/models/startup_profile_model.dart';
import '../../data/repositories/startup_repository.dart';
import 'startup_state.dart';

class StartupCubit extends Cubit<StartupState> {
  final StartupRepository _startupRepository;

  StreamSubscription<StartupProfileModel?>? _profileSubscription;
  StreamSubscription<List<StartupProfileModel>>?
      _profilesSubscription;

  StartupCubit(this._startupRepository)
      : super(const StartupInitial());

  void watchStartupProfile(String ownerId) {
    emit(const StartupLoading());

    _profilesSubscription?.cancel();
    _profileSubscription?.cancel();

    _profileSubscription =
        _startupRepository.watchStartupProfile(ownerId).listen(
      (profile) {
        if (profile == null) {
          emit(const StartupProfileMissing());
          return;
        }

        emit(StartupProfileLoaded(profile));
      },
      onError: (Object error) {
        emit(StartupFailure(_friendlyError(error)));
      },
    );
  }

  void watchPendingProfiles() {
    emit(const StartupLoading());

    _profileSubscription?.cancel();
    _profilesSubscription?.cancel();

    _profilesSubscription =
        _startupRepository.watchPendingProfiles().listen(
      (profiles) {
        emit(StartupProfilesLoaded(profiles));
      },
      onError: (Object error) {
        emit(StartupFailure(_friendlyError(error)));
      },
    );
  }

  Future<bool> submitProfile({
    required AppUser owner,
    required String startupName,
    required String description,
    required String industry,
    required String ventureStage,
    required String recognitionType,
    required String recognitionReference,
    required String website,
  }) async {
    try {
      await _startupRepository.submitProfile(
        owner: owner,
        startupName: startupName,
        description: description,
        industry: industry,
        ventureStage: ventureStage,
        recognitionType: recognitionType,
        recognitionReference: recognitionReference,
        website: website,
      );

      return true;
    } catch (error) {
      emit(StartupFailure(_friendlyError(error)));
      return false;
    }
  }

  Future<bool> approveProfile({
    required String profileId,
    required String adminId,
  }) async {
    try {
      await _startupRepository.approveProfile(
        profileId: profileId,
        adminId: adminId,
      );

      return true;
    } catch (error) {
      emit(StartupFailure(_friendlyError(error)));
      return false;
    }
  }

  Future<bool> rejectProfile({
    required String profileId,
    required String adminId,
    required String reason,
  }) async {
    try {
      await _startupRepository.rejectProfile(
        profileId: profileId,
        adminId: adminId,
        reason: reason,
      );

      return true;
    } catch (error) {
      emit(StartupFailure(_friendlyError(error)));
      return false;
    }
  }

  String _friendlyError(Object error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Firebase denied this request. Check the Firestore rules.';
        case 'unavailable':
          return 'Firebase is temporarily unavailable. Check your connection.';
        default:
          return error.message ?? 'A Firebase error occurred.';
      }
    }

    return 'The startup profile action could not be completed.';
  }

  @override
  Future<void> close() async {
    await _profileSubscription?.cancel();
    await _profilesSubscription?.cancel();
    return super.close();
  }
}