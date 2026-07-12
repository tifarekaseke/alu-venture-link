import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../applications/data/models/application_model.dart';
import '../../../opportunities/data/models/opportunity_model.dart';
import '../../data/models/startup_analytics.dart';
import '../../data/repositories/startup_analytics_repository.dart';
import 'analytics_state.dart';

class AnalyticsCubit extends Cubit<AnalyticsState> {
  final StartupAnalyticsRepository _analyticsRepository;

  StreamSubscription<List<OpportunityModel>>?
      _opportunitySubscription;

  StreamSubscription<List<ApplicationModel>>?
      _applicationSubscription;

  List<OpportunityModel>? _latestOpportunities;
  List<ApplicationModel>? _latestApplications;

  AnalyticsCubit(this._analyticsRepository)
      : super(const AnalyticsInitial());

  void watchStartupAnalytics(String startupOwnerId) {
    emit(const AnalyticsLoading());

    _opportunitySubscription?.cancel();
    _applicationSubscription?.cancel();

    _latestOpportunities = null;
    _latestApplications = null;

    _opportunitySubscription = _analyticsRepository
        .watchStartupOpportunities(startupOwnerId)
        .listen(
      (opportunities) {
        _latestOpportunities = opportunities;
        _emitAnalyticsWhenReady();
      },
      onError: (Object error) {
        emit(
          AnalyticsFailure(
            _friendlyError(error),
          ),
        );
      },
    );

    _applicationSubscription = _analyticsRepository
        .watchStartupApplications(startupOwnerId)
        .listen(
      (applications) {
        _latestApplications = applications;
        _emitAnalyticsWhenReady();
      },
      onError: (Object error) {
        emit(
          AnalyticsFailure(
            _friendlyError(error),
          ),
        );
      },
    );
  }

  void _emitAnalyticsWhenReady() {
    final opportunities = _latestOpportunities;
    final applications = _latestApplications;

    if (opportunities == null || applications == null) {
      return;
    }

    int countStatus(String status) {
      return applications.where((application) {
        return application.status == status;
      }).length;
    }

    final performances = opportunities.map((opportunity) {
      final opportunityApplications =
          applications.where((application) {
        return application.opportunityId == opportunity.id;
      }).toList();

      final interviewCount =
          opportunityApplications.where((application) {
        return application.status == 'interview';
      }).length;

      final acceptedCount =
          opportunityApplications.where((application) {
        return application.status == 'accepted';
      }).length;

      return OpportunityPerformance(
        opportunityId: opportunity.id,
        title: opportunity.title,
        status: opportunity.status,
        applications: opportunityApplications.length,
        interviews: interviewCount,
        accepted: acceptedCount,
      );
    }).toList();

    performances.sort((a, b) {
      final applicationComparison =
          b.applications.compareTo(a.applications);

      if (applicationComparison != 0) {
        return applicationComparison;
      }

      return a.title.compareTo(b.title);
    });

    emit(
      AnalyticsLoaded(
        StartupAnalytics(
          totalOpportunities: opportunities.length,
          openOpportunities:
              opportunities.where((opportunity) {
            return opportunity.status == 'open';
          }).length,
          closedOpportunities:
              opportunities.where((opportunity) {
            return opportunity.status == 'closed';
          }).length,
          totalApplications: applications.length,
          submitted: countStatus('submitted'),
          underReview: countStatus('underReview'),
          shortlisted: countStatus('shortlisted'),
          interviews: countStatus('interview'),
          accepted: countStatus('accepted'),
          rejected: countStatus('rejected'),
          withdrawn: countStatus('withdrawn'),
          opportunityPerformance: performances,
        ),
      ),
    );
  }

  String _friendlyError(Object error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'permission-denied':
          return 'Firebase denied access to the analytics data.';

        case 'unavailable':
          return 'Analytics are temporarily unavailable. Check your connection.';

        case 'failed-precondition':
          return 'Firestore needs an index for this analytics query. Open the link shown in the terminal.';

        default:
          return error.message ??
              'A Firebase analytics error occurred.';
      }
    }

    return 'The startup analytics could not be loaded.';
  }

  @override
  Future<void> close() async {
    await _opportunitySubscription?.cancel();
    await _applicationSubscription?.cancel();

    return super.close();
  }
}