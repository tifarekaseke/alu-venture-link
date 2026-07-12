import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/opportunity_model.dart';
import '../../data/repositories/opportunity_repository.dart';
import 'opportunity_state.dart';

class OpportunityCubit extends Cubit<OpportunityState> {
  final OpportunityRepository _opportunityRepository;

  StreamSubscription<List<OpportunityModel>>? _subscription;

  OpportunityCubit(this._opportunityRepository)
      : super(const OpportunityInitial());

  void watchOpenOpportunities() {
    emit(const OpportunityLoading());

    _subscription?.cancel();

    _subscription =
        _opportunityRepository.watchOpenOpportunities().listen(
      (opportunities) {
        emit(OpportunityLoaded(opportunities));
      },
      onError: (Object error) {
        emit(const OpportunityFailure(
          'Could not load opportunities.',
        ));
      },
    );
  }

  void watchStartupOpportunities(String ownerId) {
    emit(const OpportunityLoading());

    _subscription?.cancel();

    _subscription =
        _opportunityRepository.watchStartupOpportunities(ownerId).listen(
      (opportunities) {
        emit(OpportunityLoaded(opportunities));
      },
      onError: (Object error) {
        emit(const OpportunityFailure(
          'Could not load your startup opportunities.',
        ));
      },
    );
  }

  Future<void> createOpportunity({
    required String ownerId,
    required String startupName,
    required String title,
    required String description,
    required List<String> requiredSkills,
    required String opportunityType,
    required String workMode,
    required String hoursPerWeek,
    required DateTime deadline,
  }) async {
    try {
      await _opportunityRepository.createOpportunity(
        ownerId: ownerId,
        startupName: startupName,
        title: title,
        description: description,
        requiredSkills: requiredSkills,
        opportunityType: opportunityType,
        workMode: workMode,
        hoursPerWeek: hoursPerWeek,
        deadline: deadline,
      );
    } catch (error) {
      emit(const OpportunityFailure(
        'Could not create the opportunity.',
      ));
    }
  }

  Future<void> closeOpportunity(String opportunityId) async {
    try {
      await _opportunityRepository.closeOpportunity(opportunityId);
    } catch (error) {
      emit(const OpportunityFailure(
        'Could not close the opportunity.',
      ));
    }
  }

  Future<void> reopenOpportunity(String opportunityId) async {
    try {
      await _opportunityRepository.reopenOpportunity(opportunityId);
    } catch (error) {
      emit(const OpportunityFailure(
        'Could not reopen the opportunity.',
      ));
    }
  }

  Future<void> deleteOpportunity(String opportunityId) async {
    try {
      await _opportunityRepository.deleteOpportunity(opportunityId);
    } catch (error) {
      emit(const OpportunityFailure(
        'Could not delete the opportunity.',
      ));
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}