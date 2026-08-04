import 'consumable_catalog.dart';

/// The one-run effects of the consumables taken into a run.
///
/// A sibling of `MetaLoadout` / `CosmeticLoadout` / `GameFeel`: an immutable
/// value built once in `GameSessionCubit.startRun` and handed to the game, so
/// the engine never has to know that consumables exist as a concept.
///
/// **Always empty for daily challenges and tournaments** — those stay fair and
/// identical worldwide. That is enforced at the one construction site rather
/// than trusted to every reader.
class ConsumableLoadout {
  const ConsumableLoadout({
    this.bonusHearts = 0,
    this.freeRareCard = false,
    this.coinMultiplier = 1.0,
    this.freeRerolls = 0,
  });

  /// Extra hearts on top of the run's normal maximum (Field Dressing).
  final int bonusHearts;

  /// Open holding a free rare upgrade (Loaded Deck). Stacks with the Gunsmith's
  /// Opening Hand perk — two separate purchases, two cards, which is fair.
  final bool freeRareCard;

  /// Multiplier on coins earned during the run (Prospector's Charm).
  final double coinMultiplier;

  /// Draft rerolls that cost nothing before the escalating price kicks in
  /// (Second Opinion).
  final int freeRerolls;

  static const empty = ConsumableLoadout();

  bool get isEmpty =>
      bonusHearts == 0 &&
      !freeRareCard &&
      coinMultiplier == 1.0 &&
      freeRerolls == 0;

  /// Folds a chosen set of item ids into their combined effect.
  ///
  /// Takes ids rather than [Consumable]s so callers can't invent effects —
  /// the mapping from id to effect lives here and nowhere else.
  factory ConsumableLoadout.fromIds(Iterable<String> ids) {
    var hearts = 0;
    var rare = false;
    var multiplier = 1.0;
    var rerolls = 0;

    for (final id in ids) {
      switch (id) {
        case ConsumableCatalog.extraHeart:
          hearts += 1;
        case ConsumableCatalog.openingRare:
          rare = true;
        case ConsumableCatalog.coinDoubler:
          multiplier *= 2.0;
        case ConsumableCatalog.rerollCharge:
          rerolls += 1;
      }
    }

    return ConsumableLoadout(
      bonusHearts: hearts,
      freeRareCard: rare,
      coinMultiplier: multiplier,
      freeRerolls: rerolls,
    );
  }
}
