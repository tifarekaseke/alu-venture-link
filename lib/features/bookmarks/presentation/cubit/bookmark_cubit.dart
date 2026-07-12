import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../opportunities/data/models/opportunity_model.dart';
import '../../data/repositories/bookmark_repository.dart';
import 'bookmark_state.dart';

class BookmarkCubit extends Cubit<BookmarkState> {
  final BookmarkRepository _bookmarkRepository;

  StreamSubscription<List<OpportunityModel>>? _subscription;

  BookmarkCubit(this._bookmarkRepository) : super(const BookmarkInitial());

  void watchSavedOpportunities(String userId) {
    emit(const BookmarkLoading());

    _subscription?.cancel();

    _subscription = _bookmarkRepository.watchSavedOpportunities(userId).listen(
      (savedOpportunities) {
        final savedIds =
            savedOpportunities.map((opportunity) => opportunity.id).toSet();

        emit(
          BookmarkLoaded(
            savedOpportunityIds: savedIds,
            savedOpportunities: savedOpportunities,
          ),
        );
      },
      onError: (Object error) {
        debugPrint('BOOKMARK WATCH ERROR: $error');

        emit(
          BookmarkFailure(
            'Could not load saved opportunities: $error',
          ),
        );
      },
    );
  }

  Future<void> toggleBookmark({
    required String userId,
    required OpportunityModel opportunity,
  }) async {
    try {
      await _bookmarkRepository.toggleBookmark(
        userId: userId,
        opportunity: opportunity,
      );
      debugPrint('BOOKMARK SAVED OR REMOVED SUCCESSFULLY');
    } catch (error) {
      debugPrint('BOOKMARK TOGGLE ERROR: $error');

      emit(
        BookmarkFailure(
          'Bookmark error: $error',
        ),
      );
    }
  }

  Future<void> removeBookmark({
    required String userId,
    required String opportunityId,
  }) async {
    try {
      await _bookmarkRepository.removeBookmark(
        userId: userId,
        opportunityId: opportunityId,
      );
    } catch (error) {
      debugPrint('BOOKMARK REMOVE ERROR: $error');

      emit(
        BookmarkFailure(
          'Remove bookmark error: $error',
        ),
      );
    }
  }

  @override
  Future<void> close() async {
    await _subscription?.cancel();
    return super.close();
  }
}