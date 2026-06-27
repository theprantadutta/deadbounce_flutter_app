import 'package:flutter/material.dart';

import '../../../core/network/api_client.dart';
import '../../../core/sync/sync_worker.dart';
import '../../../core/theme/app_colors.dart';
import '../domain/entities/tournament.dart';
import '../domain/repositories/tournament_repository.dart';

/// Shared join/claim UI flows so the tournaments list and detail screens stay
/// in lockstep — one confirm-dialog copy, one error mapping, one snackbar.

/// Confirms the entry fee, joins (online), nudges sync, and reports the result.
Future<void> confirmAndJoinTournament(
  BuildContext context,
  Tournament t, {
  required TournamentRepository repo,
  required SyncWorker syncWorker,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  final confirmed = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: AppColors.ink800,
      title: Text('Join ${t.name}?'),
      content: Text(
        'Entry costs ${t.entryFeeCoins} coins. Play as many times as you '
        'like before it ends — your best score counts.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('CANCEL'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('JOIN'),
        ),
      ],
    ),
  );
  if (confirmed != true) return;

  String? error;
  try {
    await repo.join(t.id);
    syncWorker.requestSync();
  } on TournamentException catch (e) {
    error = e.message;
  } on ApiException catch (e) {
    error = e.message;
  }
  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(content: Text(error ?? "You're in. Good luck, partner.")),
    );
}

/// Claims the finalized reward and reports the result. [claimReward] is
/// offline-capable (local credit + a synced, server-revalidated `coinTxn`), so
/// it never throws [ApiException] — no network error path here.
Future<void> claimTournamentReward(
  BuildContext context,
  Tournament t, {
  required TournamentRepository repo,
  required SyncWorker syncWorker,
}) async {
  final messenger = ScaffoldMessenger.of(context);
  String? error;
  try {
    await repo.claimReward(t);
    syncWorker.requestSync();
  } on TournamentException catch (e) {
    error = e.message;
  }
  messenger
    ..clearSnackBars()
    ..showSnackBar(
      SnackBar(
        content: Text(error ?? 'Claimed ${t.rewardCoins} coins. Well shot.'),
      ),
    );
}
