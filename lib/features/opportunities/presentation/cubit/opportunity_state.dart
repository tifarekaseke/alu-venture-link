import 'package:equatable/equatable.dart';

import '../../data/models/opportunity_model.dart';

abstract class OpportunityState extends Equatable {
  const OpportunityState();

  @override
  List<Object?> get props => [];
}

class OpportunityInitial extends OpportunityState {
  const OpportunityInitial();
}

class OpportunityLoading extends OpportunityState {
  const OpportunityLoading();
}

class OpportunityLoaded extends OpportunityState {
  final List<OpportunityModel> opportunities;

  const OpportunityLoaded(this.opportunities);

  @override
  List<Object?> get props => [opportunities];
}

class OpportunityFailure extends OpportunityState {
  final String message;

  const OpportunityFailure(this.message);

  @override
  List<Object?> get props => [message];
}
