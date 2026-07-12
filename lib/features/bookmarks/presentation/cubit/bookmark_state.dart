import 'package:equatable/equatable.dart';

import '../../../opportunities/data/models/opportunity_model.dart';

abstract class BookmarkState extends Equatable {
  const BookmarkState();

  @override
  List<Object?> get props => [];
}

class BookmarkInitial extends BookmarkState {
  const BookmarkInitial();
}

class BookmarkLoading extends BookmarkState {
  const BookmarkLoading();
}

class BookmarkLoaded extends BookmarkState {
  final Set<String> savedOpportunityIds;
  final List<OpportunityModel> savedOpportunities;

  const BookmarkLoaded({
    required this.savedOpportunityIds,
    required this.savedOpportunities,
  });

  @override
  List<Object?> get props => [
        savedOpportunityIds.toList(),
        savedOpportunities,
      ];
}

class BookmarkFailure extends BookmarkState {
  final String message;

  const BookmarkFailure(this.message);

  @override
  List<Object?> get props => [message];
}