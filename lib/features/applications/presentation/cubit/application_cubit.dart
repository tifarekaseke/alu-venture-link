import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../auth/data/models/app_user.dart';
import '../../../opportunities/data/models/opportunity_model.dart';
import '../../data/models/application_model.dart';
import '../../data/repositories/application_repository.dart';
import 'application_state.dart';

class ApplicationCubit extends Cubit<ApplicationState> {
  final ApplicationRepository _applicationRepository;

  StreamSubscription<List<ApplicationModel>>? _subscription;

  ApplicationCubit(this._applicationRepository)
    : super(const ApplicationInitial());

  void watchStudentApplications(String studentId) {
    emit(const ApplicationLoading());

    _subscription?.cancel();

    _subscription = _applicationRepository
        .watchStudentApplications(studentId)
        .listen(
          (applications) {
            emit(ApplicationLoaded(applications));
          },
          onError: (Object error) {
            emit(ApplicationFailure(_friendlyError(error)));
          },
        );
  }

  void watchStartupApplications(String startupOwnerId) {
    emit(const ApplicationLoading());

    _subscription?.cancel();

    _subscription = _applicationRepository
        .watchStartupApplications(startupOwnerId)
        .listen(
          (applications) {
            emit(ApplicationLoaded(applications));
          },
          onError: (Object error) {
            emit(ApplicationFailure(_friendlyError(error)));
          },
        );
  }

  Future<bool> submitApplication({
    required AppUser student,
    required OpportunityModel opportunity,
    required String coverLetter,
  }) async {
    try {
      await _applicationRepository.submitApplication(
        student: student,
        opportunity: opportunity,
        coverLetter: coverLetter,
      );

      return true;
    } catch (error) {
      emit(ApplicationFailure(_friendlyError(error)));

      return false;
    }
  }

  Future<bool> updateApplicationStatus({
    required String applicationId,
    required String status,
  }) async {
    try {
      await _applicationRepository.updateApplicationStatus(
        applicationId: applicationId,
        status: status,
      );

      return true;
    } catch (error) {
      emit(ApplicationFailure(_friendlyError(error)));

      return false;
    }
  }

  Future<bool> scheduleInterview({
    required String applicationId,
    required DateTime interviewDateTime,
    required String interviewMode,
    required String locationOrLink,
    required String notes,
  }) async {
    try {
      await _applicationRepository.scheduleInterview(
        applicationId: applicationId,
        interviewDateTime: interviewDateTime,
        interviewMode: interviewMode,
        locationOrLink: locationOrLink,
        notes: notes,
      );

      return true;
    } catch (error) {
      emit(ApplicationFailure(_friendlyError(error)));

      return false;
    }
  }

  Future<bool> withdrawApplication(String applicationId) async {
    try {
      await _applicationRepository.withdrawApplication(applicationId);

      return true;
    } catch (error) {
      emit(ApplicationFailure(_friendlyError(error)));

      return false;
    }
  }

  String _friendlyError(Object error) {
    if (error is StateError) {
      return error.message.toString();
    }

    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Firebase denied this application action. Check the Firestore rules.';

        case 'unavailable':
          return 'Applications are temporarily unavailable. Check your connection.';

        case 'failed-precondition':
          return 'Firestore needs an index for this query. Open the link shown in the terminal to create it.';

        default:
          return error.message ?? 'A Firebase error occurred.';
      }
    }

    return 'The application action could not be completed.';
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}
