import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../applications/presentation/screens/my_applications_screen.dart';
import '../../../applications/presentation/screens/opportunity_detail_screen.dart';
import '../../../auth/data/models/app_user.dart';
import '../../../auth/presentation/cubit/auth_cubit.dart';
import '../../../bookmarks/presentation/cubit/bookmark_cubit.dart';
import '../../../bookmarks/presentation/cubit/bookmark_state.dart';
import '../../../bookmarks/presentation/screens/saved_opportunities_screen.dart';
import '../../../opportunities/data/models/opportunity_model.dart';
import '../../../opportunities/presentation/cubit/opportunity_cubit.dart';
import '../../../opportunities/presentation/cubit/opportunity_state.dart';
import '../../../opportunities/presentation/widgets/opportunity_card.dart';
import '../../../profiles/presentation/screens/student_profile_screen.dart';
import '../../../notifications/presentation/cubit/notification_cubit.dart';
import '../../../notifications/presentation/screens/notifications_screen.dart';
import '../../../notifications/presentation/widgets/notification_bell.dart';

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

class _StudentHomeScreenState extends State<StudentHomeScreen> {
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
          opportunity.title.toLowerCase().contains(query) ||
          opportunity.startupName
              .toLowerCase()
              .contains(query) ||
          opportunity.requiredSkills.any(
            (skill) =>
                skill.toLowerCase().contains(query),
          );

      final matchesWorkMode =
          _selectedWorkMode == 'All' ||
              opportunity.workMode == _selectedWorkMode;

      final matchesType =
          _selectedType == 'All' ||
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

    return ((matchedSkills / requiredSkills.length) * 100)
        .round();
  }

  void _openMyApplications() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => MyApplicationsScreen(
          user: widget.user,
        ),
      ),
    );
  }

  void _openSavedOpportunities() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => SavedOpportunitiesScreen(
          user: widget.user,
        ),
      ),
    );
  }

  void _openStudentProfile() {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const StudentProfileScreen(),
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
  onPressed: () {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => NotificationsScreen(
          user: widget.user,
        ),
      ),
    );
  },
),
            IconButton(
              tooltip: 'Saved opportunities',
              onPressed: _openSavedOpportunities,
              icon: const Icon(
                Icons.bookmark_border_outlined,
              ),
            ),
            IconButton(
              tooltip: 'My applications',
              onPressed: _openMyApplications,
              icon: const Icon(
                Icons.assignment_outlined,
              ),
            ),
            IconButton(
              tooltip: 'My profile',
              onPressed: _openStudentProfile,
              icon: const Icon(
                Icons.person_outline,
              ),
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
            return ListView(
              padding: const EdgeInsets.fromLTRB(
                24,
                16,
                24,
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
                  'Discover startup opportunities created by ALU founders.',
                  style: TextStyle(
                    fontSize: 16,
                    height: 1.5,
                    color: AppTheme.textSecondary,
                  ),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: _searchController,
                  onChanged: (_) {
                    setState(() {});
                  },
                  decoration: const InputDecoration(
                    hintText:
                        'Search by role, startup, or skill...',
                    prefixIcon: Icon(Icons.search),
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

                const SizedBox(height: 24),

                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppTheme.navy,
                    borderRadius:
                        BorderRadius.circular(24),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.auto_awesome,
                        color: AppTheme.gold,
                        size: 30,
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'Complete your profile skills to receive personalized opportunity match percentages.',
                          style: TextStyle(
                            color: Colors.white,
                            height: 1.45,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 28),

                const Text(
                  'Open opportunities',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w800,
                    color: AppTheme.navy,
                  ),
                ),

                const SizedBox(height: 14),

                if (state is OpportunityLoading)
                  const Center(
                    child: Padding(
                      padding: EdgeInsets.all(24),
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
                          tooltip:
                              isSaved ? 'Unsave' : 'Save',
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
                else
                  const SizedBox.shrink(),
              ],
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
      padding:
          const EdgeInsets.symmetric(horizontal: 14),
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
      padding: const EdgeInsets.all(22),
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
            size: 42,
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
            'Try changing your search or filters.',
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