import 'package:equatable/equatable.dart';

import '../../data/models/startup_analytics.dart';

abstract class AnalyticsState extends Equatable {
  const AnalyticsState();

  @override
  List<Object?> get props => [];
}

class AnalyticsInitial extends AnalyticsState {
  const AnalyticsInitial();
}

class AnalyticsLoading extends AnalyticsState {
  const AnalyticsLoading();
}

class AnalyticsLoaded extends AnalyticsState {
  final StartupAnalytics analytics;

  const AnalyticsLoaded(this.analytics);

  @override
  List<Object?> get props => [analytics];
}

class AnalyticsFailure extends AnalyticsState {
  final String message;

  const AnalyticsFailure(this.message);

  @override
  List<Object?> get props => [message];
}
