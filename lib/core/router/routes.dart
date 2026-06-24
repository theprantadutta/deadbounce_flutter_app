/// Route locations — single place for every path string.
abstract final class Routes {
  static const String splash = '/';

  /// First-launch legal gate (Privacy Policy + Terms). Shown before login when
  /// the accepted legal version is behind the current one.
  static const String legal = '/legal';

  /// Read-only viewer for the legal documents, opened from Settings → About.
  /// Append `?tab=0` (Privacy) or `?tab=1` (Terms) to pick the initial tab.
  static const String legalView = '/legal/view';

  static const String login = '/login';
  static const String signup = '/signup';
  static const String home = '/home';
  static const String game = '/game';
  static const String dailyChallengeRun = '/game/daily';
  static const String dailyChallenge = '/daily-challenge';
  static const String leaderboard = '/leaderboard';
  static const String awards = '/awards';
  static const String profile = '/profile';
  static const String settings = '/settings';
  static const String statistics = '/statistics';
  static const String howToPlay = '/how-to-play';
  static const String credits = '/credits';
  static const String gunsmith = '/gunsmith';
  static const String cosmetics = '/outfitter';
  static const String trickShot = '/trick-shot';

  /// Trick-shot run — append the level id, e.g. `/trick-shot/run/<id>`.
  static const String trickShotRun = '/trick-shot/run';
  static const String tournaments = '/tournaments';

  /// Tournament detail — append the id, e.g. `/tournament/<id>`.
  static const String tournamentDetail = '/tournament';

  /// Tournament run — append the tournament id, e.g. `/game/tournament/<id>`.
  static const String tournamentRun = '/game/tournament';

  static const String logs = '/logs'; // debug-only diagnostics viewer
}
