import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../core/config/game_balance.dart';
import '../../../../core/config/game_balance_store.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_dimens.dart';
import '../game/components/deadbounce_game.dart';
import '../game/hud_model.dart';

/// Developer-only live tuning panel. Sliders for every [GameBalance] value,
/// grouped by section, plus a live readout of the run. Changes apply in real
/// time (continuous values are felt immediately; wave/run-scoped values apply
/// on the next wave/run — labeled per row) and persist via [GameBalanceStore].
///
/// **Debug-gated**: only ever instantiated behind `kDebugMode` (see the HUD
/// button in `game_page.dart`), so it is dead code in release builds.
class TuningPanel extends StatefulWidget {
  const TuningPanel({super.key, required this.game, required this.hud});

  final DeadbounceGame game;
  final HudModel hud;

  @override
  State<TuningPanel> createState() => _TuningPanelState();
}

class _TuningPanelState extends State<TuningPanel> {
  // The readout values (alive enemies, run time) aren't notifiers, so poll.
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _ticker = Timer.periodic(const Duration(milliseconds: 300), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  List<String> get _groupOrder {
    final seen = <String>[];
    for (final p in GameBalance.I.params) {
      if (!seen.contains(p.group)) seen.add(p.group);
    }
    return seen;
  }

  void _reset() {
    GameBalance.I.resetToDefaults();
    GameBalanceStore.clear();
    setState(() {});
    _toast('Reset to defaults');
  }

  Future<void> _copy() async {
    await Clipboard.setData(ClipboardData(text: GameBalance.I.toDartCode()));
    _toast('Config copied as Dart');
  }

  void _toast(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ));
  }

  @override
  Widget build(BuildContext context) {
    return FractionallySizedBox(
      heightFactor: 0.85,
      child: Container(
        decoration: const BoxDecoration(
          color: AppColors.ink900,
          borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
          border: Border(top: BorderSide(color: AppColors.amber500, width: 2)),
        ),
        child: Column(
          children: [
            _header(),
            _readout(),
            const Divider(height: 1, color: AppColors.outlineFaint),
            Expanded(
              child: ListView(
                padding: const EdgeInsets.only(bottom: AppSpacing.xl),
                children: [
                  for (final group in _groupOrder) _section(group),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _header() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
          AppSpacing.md, AppSpacing.sm, AppSpacing.sm, AppSpacing.xs),
      child: Row(
        children: [
          const Icon(Icons.tune, color: AppColors.amber400, size: 20),
          const SizedBox(width: AppSpacing.xs),
          Text('TUNING (debug)',
              style: Theme.of(context).textTheme.titleMedium),
          const Spacer(),
          TextButton.icon(
            onPressed: _copy,
            icon: const Icon(Icons.copy, size: 16),
            label: const Text('Copy'),
          ),
          TextButton.icon(
            onPressed: _reset,
            icon: const Icon(Icons.restart_alt, size: 16),
            label: const Text('Reset'),
          ),
          IconButton(
            tooltip: 'Close',
            onPressed: () => Navigator.of(context).maybePop(),
            icon: const Icon(Icons.close, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _readout() {
    final game = widget.game;
    final bullet = game.modifiers.effectiveBulletStats();
    final player = game.modifiers.effectivePlayerStats();
    // Crude "what is my output" gauge: damage of a typical ~3-bounce shot per
    // fire interval. Not real DPS — just a number to feel relative changes.
    final estDps = player.fireCooldown <= 0
        ? 0
        : (bullet.damagePerBounce * 3 / player.fireCooldown).round();

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: AppSpacing.xs),
      child: Wrap(
        spacing: AppSpacing.md,
        runSpacing: AppSpacing.xxs,
        children: [
          _stat('Wave', '${widget.hud.wave.value}'),
          _stat('Alive', '${game.aliveEnemies.length}'),
          _stat('Coins', '${game.coinsEarned}'),
          _stat('Score', '${widget.hud.score.value}'),
          _stat('Time', '${game.runTime.toStringAsFixed(1)}s'),
          _stat('~dmg/s', '$estDps'),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    final textTheme = Theme.of(context).textTheme;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text('$label ',
            style: textTheme.labelSmall?.copyWith(color: AppColors.ink400)),
        Text(value,
            style: textTheme.labelMedium?.copyWith(color: AppColors.blue300)),
      ],
    );
  }

  Widget _section(String group) {
    final params =
        GameBalance.I.params.where((p) => p.group == group).toList();
    return ExpansionTile(
      title: Text(group, style: Theme.of(context).textTheme.titleSmall),
      childrenPadding: const EdgeInsets.only(bottom: AppSpacing.sm),
      children: [for (final p in params) _ParamRow(param: p, onChanged: _save)],
    );
  }

  void _save() {
    setState(() {});
    GameBalanceStore.save();
  }
}

class _ParamRow extends StatelessWidget {
  const _ParamRow({required this.param, required this.onChanged});

  final TuningParam param;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final value = param.get().clamp(param.min, param.max);
    final divisions = ((param.max - param.min) / param.step).round();
    final display =
        param.isInt ? value.round().toString() : value.toStringAsFixed(2);

    return Padding(
      padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(param.label, style: textTheme.bodySmall),
              ),
              _scopeChip(param.scope, textTheme),
              const SizedBox(width: AppSpacing.xs),
              SizedBox(
                width: 52,
                child: Text(display,
                    textAlign: TextAlign.right,
                    style: textTheme.labelMedium
                        ?.copyWith(color: AppColors.amber300)),
              ),
            ],
          ),
          Slider(
            value: value.toDouble(),
            min: param.min,
            max: param.max,
            divisions: divisions > 0 ? divisions : null,
            onChanged: (v) {
              param.set(v);
              onChanged();
            },
          ),
        ],
      ),
    );
  }

  Widget _scopeChip(TuneScope scope, TextTheme textTheme) {
    final (label, color) = switch (scope) {
      TuneScope.live => ('LIVE', AppColors.blue400),
      TuneScope.nextWave => ('WAVE', AppColors.amber400),
      TuneScope.nextRun => ('RUN', AppColors.ink400),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4),
        border: Border.all(color: color),
      ),
      child: Text(label,
          style: textTheme.labelSmall?.copyWith(color: color, fontSize: 9)),
    );
  }
}
