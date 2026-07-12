import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../applications/presentation/screens/opportunity_detail_screen.dart';
import '../../../auth/data/models/app_user.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../bookmarks/presentation/cubit/bookmark_cubit.dart';
import '../../../bookmarks/presentation/cubit/bookmark_state.dart';
import '../../../notifications/presentation/cubit/notification_cubit.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';
import '../../../opportunities/data/models/opportunity_model.dart';
import '../../../opportunities/presentation/cubit/opportunity_cubit.dart';
import '../../../opportunities/presentation/cubit/opportunity_state.dart';
import '../../../opportunities/presentation/widgets/opportunity_card.dart';

class StudentHomeScreen extends StatefulWidget {
  final AppUser user;

  const StudentHomeScreen({
    required this.user,
    super.key,
  });

  @override
  State<StudentHomeScreen> createState() =>
      _StudentHomeScreenState();
}

class _StudentHomeScreenState
    extends State<StudentHomeScreen> {
  final _searchController = TextEditingController();

  String _selectedWorkMode = 'All';
  String _selectedType = 'All';

  @override
  void initState() {
    super.initState();

    context
        .read<OpportunityCubit>()
        .watchOpenOpportunities();

    context
        .read<BookmarkCubit>()
        .watchSavedOpportunities(widget.user.uid);

    context
        .read<NotificationCubit>()
        .watchNotifications(widget.user.uid);
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<OpportunityModel> _filterOpportunities(
    List<OpportunityModel> opportunities,
  ) {
    final query =
        _searchController.text.trim().toLowerCase();

    return opportunities.where((opportunity) {
      final matchesSearch = query.isEmpty ||
          opportunity.title
              .toLowerCase()
              .contains(query) ||
          opportunity.startupName
              .toLowerCase()
              .contains(query) ||
          opportunity.requiredSkills.any(
            (skill) =>
                skill.toLowerCase().contains(query),
          );

      final matchesWorkMode =
          _selectedWorkMode == 'All' ||
              opportunity.workMode ==
                  _selectedWorkMode;

      final matchesType = _selectedType == 'All' ||
          opportunity.opportunityType ==
              _selectedType;

      return matchesSearch &&
          matchesWorkMode &&
          matchesType;
    }).toList();
  }

  int _calculateMatchPercentage(
    AppUser user,
    OpportunityModel opportunity,
  ) {
    final studentSkills = user.skills
        .map(
          (skill) => skill.trim().toLowerCase(),
        )
        .where(
          (skill) => skill.isNotEmpty,
        )
        .toSet();

    final requiredSkills = opportunity.requiredSkills
        .map(
          (skill) => skill.trim().toLowerCase(),
        )
        .where(
          (skill) => skill.isNotEmpty,
        )
        .toSet();

    if (requiredSkills.isEmpty) {
      return 100;
    }

    if (studentSkills.isEmpty) {
      return 0;
    }

    final matchedSkills =
        requiredSkills.where((requiredSkill) {
      return studentSkills.any((studentSkill) {
        return studentSkill == requiredSkill ||
            studentSkill.contains(requiredSkill) ||
            requiredSkill.contains(studentSkill);
      });
    }).length;

    return ((matchedSkills / requiredSkills.length) *
            100)
        .round();
  }

  void _openNotifications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotificationsScreen(
          user: widget.user,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final firstName =
        widget.user.fullName.trim().isEmpty
            ? 'Student'
            : widget.user.fullName
                .trim()
                .split(' ')
                .first;

    final bookmarkState =
        context.watch<BookmarkCubit>().state;

    final savedIds = bookmarkState is BookmarkLoaded
        ? bookmarkState.savedOpportunityIds
        : <String>{};

    return BlocListener<BookmarkCubit, BookmarkState>(
      listener: (context, state) {
        if (state is BookmarkFailure) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
            ),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ALU VentureLink'),
          actions: [
            NotificationBell(
              onPressed: _openNotifications,
            ),
            IconButton(
              tooltip: 'Sign out',
              onPressed: () {
                context.read<AuthCubit>().signOut();
              },
              icon: const Icon(Icons.logout),
            ),
          ],
        ),
        body: BlocConsumer<
            OpportunityCubit,
            OpportunityState>(
          listener: (context, state) {
            if (state is OpportunityFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.message),
                ),
              );
            }
          },
          builder: (context, state) {
            return RefreshIndicator(
              onRefresh: () async {
                context
                    .read<OpportunityCubit>()
                    .watchOpenOpportunities();

                await Future<void>.delayed(
                  const Duration(milliseconds: 500),
                );
              },
              child: ListView(
                physics:
                    const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  20,
                  16,
                  20,
                  32,
                ),
                children: [
                  Text(
                    'Hello, $firstName 👋',
                    style: const TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.navy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Discover practical opportunities with verified ALU student ventures.',
                    style: TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 22),

                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppTheme.navy,
                      borderRadius:
                          BorderRadius.circular(24),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 52,
                          height: 52,
                          decoration: BoxDecoration(
                            color: Colors.white.withAlpha(25),
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                          child: const Icon(
                            Icons.auto_awesome,
                            color: AppTheme.gold,
                            size: 28,
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Smart opportunity matching',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 17,
                                  fontWeight:
                                      FontWeight.w800,
                                ),
                              ),
                              SizedBox(height: 5),
                              Text(
                                'Your profile skills are compared with each role to calculate a transparent match score.',
                                style: TextStyle(
                                  color: Colors.white70,
                                  height: 1.4,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 22),

                  TextField(
                    controller: _searchController,
                    onChanged: (_) {
                      setState(() {});
                    },
                    decoration: InputDecoration(
                      hintText:
                          'Search roles, startups or skills',
                      prefixIcon:
                          const Icon(Icons.search),
                      suffixIcon:
                          _searchController.text.isEmpty
                              ? null
                              : IconButton(
                                  tooltip: 'Clear search',
                                  onPressed: () {
                                    _searchController
                                        .clear();

                                    setState(() {});
                                  },
                                  icon: const Icon(
                                    Icons.close,
                                  ),
                                ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Row(
                    children: [
                      Expanded(
                        child: _FilterDropdown(
                          value: _selectedWorkMode,
                          items: const [
                            'All',
                            'On-campus',
                            'Remote',
                            'Hybrid',
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedWorkMode = value;
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: _FilterDropdown(
                          value: _selectedType,
                          items: const [
                            'All',
                            'Internship',
                            'Volunteer',
                            'Project-based',
                            'Part-time',
                          ],
                          onChanged: (value) {
                            setState(() {
                              _selectedType = value;
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 28),

                  Row(
                    children: [
                      const Expanded(
                        child: Text(
                          'Open opportunities',
                          style: TextStyle(
                            fontSize: 21,
                            fontWeight:
                                FontWeight.w800,
                            color: AppTheme.navy,
                          ),
                        ),
                      ),
                      if (state is OpportunityLoaded)
                        Container(
                          padding:
                              const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 6,
                          ),
                          decoration: BoxDecoration(
                            color:
                                const Color(0xFFF1EDFF),
                            borderRadius:
                                BorderRadius.circular(20),
                          ),
                          child: Text(
                            _filterOpportunities(
                              state.opportunities,
                            ).length.toString(),
                            style: const TextStyle(
                              color: AppTheme.purple,
                              fontWeight:
                                  FontWeight.w800,
                            ),
                          ),
                        ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  if (state is OpportunityLoading ||
                      state is OpportunityInitial)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(30),
                        child:
                            CircularProgressIndicator(),
                      ),
                    )
                  else if (state is OpportunityLoaded &&
                      _filterOpportunities(
                        state.opportunities,
                      ).isEmpty)
                    const _EmptyStudentState()
                  else if (state is OpportunityLoaded)
                    ..._filterOpportunities(
                      state.opportunities,
                    ).map(
                      (opportunity) {
                        final isSaved =
                            savedIds.contains(
                          opportunity.id,
                        );

                        final matchPercentage =
                            _calculateMatchPercentage(
                          widget.user,
                          opportunity,
                        );

                        return OpportunityCard(
                          opportunity: opportunity,
                          matchPercentage:
                              matchPercentage,
                          trailing: IconButton(
                            tooltip: isSaved
                                ? 'Remove from saved'
                                : 'Save opportunity',
                            onPressed: () {
                              context
                                  .read<BookmarkCubit>()
                                  .toggleBookmark(
                                    userId:
                                        widget.user.uid,
                                    opportunity:
                                        opportunity,
                                  );
                            },
                            icon: Icon(
                              isSaved
                                  ? Icons.bookmark
                                  : Icons
                                      .bookmark_border_outlined,
                              color: isSaved
                                  ? AppTheme.purple
                                  : null,
                            ),
                          ),
                          onTap: () {
                            Navigator.of(context).push(
                              MaterialPageRoute<void>(
                                builder: (_) =>
                                    OpportunityDetailScreen(
                                  student:
                                      widget.user,
                                  opportunity:
                                      opportunity,
                                ),
                              ),
                            );
                          },
                        );
                      },
                    )
                  else if (state is OpportunityFailure)
                    _ErrorState(
                      message: state.message,
                    )
                  else
                    const SizedBox.shrink(),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}

class _FilterDropdown extends StatelessWidget {
  final String value;
  final List<String> items;
  final ValueChanged<String> onChanged;

  const _FilterDropdown({
    required this.value,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: const Color(0xFFE4E7EC),
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          borderRadius: BorderRadius.circular(16),
          items: items.map((item) {
            return DropdownMenuItem<String>(
              value: item,
              child: Text(
                item,
                overflow: TextOverflow.ellipsis,
              ),
            );
          }).toList(),
          onChanged: (selectedValue) {
            if (selectedValue == null) {
              return;
            }

            onChanged(selectedValue);
          },
        ),
      ),
    );
  }
}

class _EmptyStudentState extends StatelessWidget {
  const _EmptyStudentState();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(
          color: const Color(0xFFE4E7EC),
        ),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.search_off_outlined,
            size: 48,
            color: AppTheme.purple,
          ),
          SizedBox(height: 14),
          Text(
            'No matching opportunities',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppTheme.navy,
            ),
          ),
          SizedBox(height: 8),
          Text(
            'Try changing the search phrase or filters.',
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.5,
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _ErrorState extends StatelessWidget {
  final String message;

  const _ErrorState({
    required this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(26),
      decoration: BoxDecoration(
        color: const Color(0xFFFFEEEE),
        borderRadius: BorderRadius.circular(22),
      ),
      child: Column(
        children: [
          Icon(
            Icons.error_outline,
            size: 45,
            color: Colors.red.shade700,
          ),
          const SizedBox(height: 13),
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.5,
              color: Colors.red.shade700,
            ),
          ),
        ],
      ),
    );
  }
}