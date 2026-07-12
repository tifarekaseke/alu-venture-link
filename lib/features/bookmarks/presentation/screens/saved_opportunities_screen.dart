import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../applications/presentation/screens/opportunity_detail_screen.dart';
import '../../../auth/data/models/app_user.dart';
import '../../../opportunities/presentation/widgets/opportunity_card.dart';
import '../cubit/bookmark_cubit.dart';
import '../cubit/bookmark_state.dart';

class SavedOpportunitiesScreen extends StatefulWidget {
  final AppUser user;

  const SavedOpportunitiesScreen({
    required this.user,
    super.key,
  });

  @override
  State<SavedOpportunitiesScreen> createState() =>
      _SavedOpportunitiesScreenState();
}

class _SavedOpportunitiesScreenState extends State<SavedOpportunitiesScreen> {
  @override
  void initState() {
    super.initState();

    context.read<BookmarkCubit>().watchSavedOpportunities(widget.user.uid);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Saved Opportunities'),
      ),
      body: BlocConsumer<BookmarkCubit, BookmarkState>(
        listener: (context, state) {
          if (state is BookmarkFailure) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message)),
            );
          }
        },
        builder: (context, state) {
          if (state is BookmarkLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is BookmarkLoaded &&
              state.savedOpportunities.isEmpty) {
            return const _EmptySavedState();
          }

          if (state is BookmarkLoaded) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 16, 24, 32),
              children: [
                const Text(
                  'Saved opportunities',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.navy,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Roles you bookmark will appear here for quick access.',
                  style: TextStyle(
                    height: 1.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),
                ...state.savedOpportunities.map(
                  (opportunity) => OpportunityCard(
                    opportunity: opportunity,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => OpportunityDetailScreen(
                            student: widget.user,
                            opportunity: opportunity,
                          ),
                        ),
                      );
                    },
                    trailing: IconButton(
                      tooltip: 'Remove saved opportunity',
                      onPressed: () {
                        context.read<BookmarkCubit>().removeBookmark(
                              userId: widget.user.uid,
                              opportunityId: opportunity.id,
                            );
                      },
                      icon: const Icon(Icons.bookmark_remove_outlined),
                    ),
                  ),
                ),
              ],
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}

class _EmptySavedState extends StatelessWidget {
  const _EmptySavedState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.bookmark_border_outlined,
              size: 54,
              color: AppTheme.purple,
            ),
            const SizedBox(height: 18),
            const Text(
              'No saved opportunities yet',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: AppTheme.navy,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the bookmark icon on an opportunity to save it here.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
