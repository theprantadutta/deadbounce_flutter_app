import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app.dart';
import '../../../core/router/routes.dart';
import '../../../core/widgets/db_loading_scene.dart';
import '../../game/presentation/game/tournament_run_context.dart';
import '../../game/presentation/game_page.dart';
import '../domain/entities/tournament.dart';

/// Loads the joined tournament from the local cache (offline-safe) and starts
/// a seeded run with its ruleset. Reached via `/game/tournament/<id>`.
class TournamentRunPage extends StatelessWidget {
  const TournamentRunPage({super.key, required this.tournamentId});

  final String tournamentId;

  @override
  Widget build(BuildContext context) {
    final repo = context.sessionDependencies.tournamentRepository;
    return FutureBuilder<Tournament?>(
      future: repo.getById(tournamentId),
      builder: (context, snapshot) {
        if (snapshot.connectionState != ConnectionState.done) {
          return const DbLoadingScene(
            title: 'ENTERING THE LISTS',
            subtitle: 'Loading the tournament board…',
            showLogo: false,
            tips: ['Same board for everyone.', 'Your best score counts.'],
          );
        }
        final tournament = snapshot.data;
        if (tournament == null) {
          // Not cached (shouldn't happen post-join) — bounce home.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (context.mounted) context.go(Routes.home);
          });
          return const SizedBox.shrink();
        }
        return GamePage(
          tournamentContext: TournamentRunContext(
            tournamentId: tournament.id,
            seed: tournament.seed,
            config: tournament.toChallengeConfig(),
          ),
        );
      },
    );
  }
}
