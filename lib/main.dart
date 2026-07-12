import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'app/app.dart';
import 'features/analytics/data/repositories/startup_analytics_repository.dart';
import 'features/analytics/presentation/cubit/analytics_cubit.dart';
import 'features/applications/data/repositories/application_repository.dart';
import 'features/applications/presentation/cubit/application_cubit.dart';
import 'features/auth/data/repositories/auth_repository.dart';
import 'features/auth/presentation/cubit/auth_cubit.dart';
import 'features/bookmarks/data/repositories/bookmark_repository.dart';
import 'features/bookmarks/presentation/cubit/bookmark_cubit.dart';
import 'features/notifications/data/repositories/notification_repository.dart';
import 'features/notifications/presentation/cubit/notification_cubit.dart';
import 'features/opportunities/data/repositories/opportunity_repository.dart';
import 'features/opportunities/presentation/cubit/opportunity_cubit.dart';
import 'features/profiles/data/repositories/profile_repository.dart';
import 'features/profiles/presentation/cubit/profile_cubit.dart';
import 'features/startups/data/repositories/startup_repository.dart';
import 'features/startups/presentation/cubit/startup_cubit.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  final authRepository = AuthRepository();
  final opportunityRepository = OpportunityRepository();
  final applicationRepository = ApplicationRepository();
  final bookmarkRepository = BookmarkRepository();
  final startupRepository = StartupRepository();
  final profileRepository = ProfileRepository();
  final notificationRepository = NotificationRepository();
  final startupAnalyticsRepository = StartupAnalyticsRepository();

  runApp(
    MultiRepositoryProvider(
      providers: [
        RepositoryProvider<AuthRepository>.value(value: authRepository),
        RepositoryProvider<OpportunityRepository>.value(
          value: opportunityRepository,
        ),
        RepositoryProvider<ApplicationRepository>.value(
          value: applicationRepository,
        ),
        RepositoryProvider<BookmarkRepository>.value(value: bookmarkRepository),
        RepositoryProvider<StartupRepository>.value(value: startupRepository),
        RepositoryProvider<ProfileRepository>.value(value: profileRepository),
        RepositoryProvider<NotificationRepository>.value(
          value: notificationRepository,
        ),
        RepositoryProvider<StartupAnalyticsRepository>.value(
          value: startupAnalyticsRepository,
        ),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider<AuthCubit>(create: (_) => AuthCubit(authRepository)),
          BlocProvider<OpportunityCubit>(
            create: (_) => OpportunityCubit(opportunityRepository),
          ),
          BlocProvider<ApplicationCubit>(
            create: (_) => ApplicationCubit(applicationRepository),
          ),
          BlocProvider<BookmarkCubit>(
            create: (_) => BookmarkCubit(bookmarkRepository),
          ),
          BlocProvider<StartupCubit>(
            create: (_) => StartupCubit(startupRepository),
          ),
          BlocProvider<ProfileCubit>(
            create: (_) => ProfileCubit(profileRepository),
          ),
          BlocProvider<NotificationCubit>(
            create: (_) => NotificationCubit(notificationRepository),
          ),
          BlocProvider<AnalyticsCubit>(
            create: (_) => AnalyticsCubit(startupAnalyticsRepository),
          ),
        ],
        child: const VentureLinkApp(),
      ),
    ),
  );
}
