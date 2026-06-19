import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:talker_flutter/talker_flutter.dart';

import '../logging/app_logger.dart';
import '../../features/about/presentation/credits_screen.dart';
import '../../features/about/presentation/how_to_play_screen.dart';
import '../../features/achievements/presentation/awards_screen.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/signup_page.dart';
import '../../features/challenges/presentation/daily_challenge_screen.dart';
import '../../features/game/presentation/game_page.dart';
import '../../features/home/presentation/home_page.dart';
import '../../features/leaderboards/presentation/leaderboard_screen.dart';
import '../../features/meta/presentation/gunsmith_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/settings/presentation/settings_screen.dart';
import '../../features/splash/presentation/splash_page.dart';
import '../../features/statistics/presentation/statistics_screen.dart';
import '../../features/tournaments/presentation/tournament_detail_screen.dart';
import '../../features/tournaments/presentation/tournament_run_page.dart';
import '../../features/tournaments/presentation/tournaments_screen.dart';
import 'db_page_transition.dart';
import 'routes.dart';

/// App navigation. Splash owns the initial auth decision; login/home
/// pages react to [AuthCubit] state changes for the transitions between
/// the auth and main flows. The meta screens read the per-account session
/// through SessionHolder and so only mount after sign-in.
///
/// Every route animates with the signature [dbPage] ricochet transition.
GoRouter buildRouter() {
  return GoRouter(
    initialLocation: Routes.splash,
    routes: [
      GoRoute(
        path: Routes.splash,
        pageBuilder: (context, state) =>
            dbPage(state: state, child: const SplashPage()),
      ),
      GoRoute(
        path: Routes.login,
        pageBuilder: (context, state) =>
            dbPage(state: state, child: const LoginPage()),
      ),
      GoRoute(
        path: Routes.signup,
        pageBuilder: (context, state) =>
            dbPage(state: state, child: const SignupPage()),
      ),
      GoRoute(
        path: Routes.home,
        pageBuilder: (context, state) =>
            dbPage(state: state, child: const HomePage()),
      ),
      GoRoute(
        path: Routes.game,
        pageBuilder: (context, state) =>
            dbPage(state: state, child: const GamePage()),
      ),
      GoRoute(
        path: Routes.dailyChallengeRun,
        pageBuilder: (context, state) =>
            dbPage(state: state, child: const GamePage(dailyChallenge: true)),
      ),
      GoRoute(
        path: Routes.dailyChallenge,
        pageBuilder: (context, state) =>
            dbPage(state: state, child: const DailyChallengeScreen()),
      ),
      GoRoute(
        path: Routes.leaderboard,
        pageBuilder: (context, state) =>
            dbPage(state: state, child: const LeaderboardScreen()),
      ),
      GoRoute(
        path: Routes.awards,
        pageBuilder: (context, state) =>
            dbPage(state: state, child: const AwardsScreen()),
      ),
      GoRoute(
        path: Routes.profile,
        pageBuilder: (context, state) =>
            dbPage(state: state, child: const ProfileScreen()),
      ),
      GoRoute(
        path: Routes.settings,
        pageBuilder: (context, state) =>
            dbPage(state: state, child: const SettingsScreen()),
      ),
      GoRoute(
        path: Routes.statistics,
        pageBuilder: (context, state) =>
            dbPage(state: state, child: const StatisticsScreen()),
      ),
      GoRoute(
        path: Routes.howToPlay,
        pageBuilder: (context, state) =>
            dbPage(state: state, child: const HowToPlayScreen()),
      ),
      GoRoute(
        path: Routes.credits,
        pageBuilder: (context, state) =>
            dbPage(state: state, child: const CreditsScreen()),
      ),
      GoRoute(
        path: Routes.gunsmith,
        pageBuilder: (context, state) =>
            dbPage(state: state, child: const GunsmithScreen()),
      ),
      GoRoute(
        path: Routes.tournaments,
        pageBuilder: (context, state) =>
            dbPage(state: state, child: const TournamentsScreen()),
      ),
      GoRoute(
        path: '${Routes.tournamentDetail}/:id',
        pageBuilder: (context, state) => dbPage(
          state: state,
          child: TournamentDetailScreen(
            tournamentId: state.pathParameters['id']!,
          ),
        ),
      ),
      GoRoute(
        path: '${Routes.tournamentRun}/:id',
        pageBuilder: (context, state) => dbPage(
          state: state,
          child: TournamentRunPage(
            tournamentId: state.pathParameters['id']!,
          ),
        ),
      ),
      // Debug-only in-app log viewer.
      if (kDebugMode)
        GoRoute(
          path: Routes.logs,
          pageBuilder: (context, state) => dbPage(
            state: state,
            child: TalkerScreen(
              talker: AppLogger.talker,
              appBarTitle: 'LOGS',
            ),
          ),
        ),
    ],
  );
}
