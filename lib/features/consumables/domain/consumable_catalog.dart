import 'package:flutter/material.dart' show IconData, Icons;

/// A one-run item: bought with coins, carried into a run, gone afterwards.
///
/// **This is the sink that recurs.** Perks and cosmetics are bought once and
/// owned forever, so a committed player eventually has nothing left to spend
/// on — which is exactly why coin packs would have had no durable demand.
/// Consumables are spent every time they're used, so demand comes back.
///
/// Guardrails, same as everything else purchasable: **never flat bullet
/// damage** (that would break "no damage till it bounces"), and **normal runs
/// only** — daily challenges and tournaments stay identical worldwide.
class Consumable {
  const Consumable({
    required this.id,
    required this.name,
    required this.blurb,
    required this.icon,
    required this.cost,
  });

  /// Stable id — stored in Drift, synced, and mirrored in the backend's
  /// `ConsumableDefinitions`. Never rename one.
  final String id;
  final String name;

  /// The mechanical effect, stated plainly. These are bought before a run with
  /// no chance to try them first, so vagueness here reads as a con.
  final String blurb;
  final IconData icon;

  /// Coin price for ONE. Deliberately cheap relative to the Gunsmith: a
  /// consumable is a small, frequent decision, not a milestone purchase.
  final int cost;
}

abstract final class ConsumableCatalog {
  static const String extraHeart = 'extra_heart';
  static const String openingRare = 'opening_rare';
  static const String coinDoubler = 'coin_doubler';
  static const String rerollCharge = 'reroll_charge';

  /// The most of any single item a player may hold. Mirrored (per id) by
  /// `ConsumableDefinitions.MaxStacks` on the backend, which clamps to it.
  static const int maxStack = 99;

  /// How many distinct items may be taken into one run.
  ///
  /// Capped at 2 on purpose: taking everything every time is not a decision,
  /// and a run that starts with every advantage stops resembling the run
  /// everyone else's leaderboard score came from.
  static const int maxEquipped = 2;

  static const List<Consumable> all = [
    Consumable(
      id: extraHeart,
      name: 'Field Dressing',
      blurb: 'Start this run with +1 heart.',
      icon: Icons.favorite_border,
      cost: 250,
    ),
    Consumable(
      id: openingRare,
      name: 'Loaded Deck',
      blurb: 'Open this run holding a free RARE upgrade.',
      icon: Icons.style_outlined,
      cost: 400,
    ),
    Consumable(
      id: coinDoubler,
      name: "Prospector's Charm",
      blurb: 'Double every coin this run earns.',
      icon: Icons.savings_outlined,
      cost: 350,
    ),
    Consumable(
      id: rerollCharge,
      name: 'Second Opinion',
      blurb: 'Your first upgrade reroll this run is free.',
      icon: Icons.casino_outlined,
      cost: 200,
    ),
  ];

  static Consumable byId(String id) =>
      all.firstWhere((c) => c.id == id, orElse: () => all.first);

  static bool isKnown(String id) => all.any((c) => c.id == id);
}
