import 'package:flutter/material.dart';

/// A purchasable permanent ("Gunsmith") perk. Definitions live in Dart; the
/// database only stores the owned LEVEL per [id].
class MetaPerk {
  const MetaPerk({
    required this.id,
    required this.name,
    required this.blurb,
    required this.icon,
    required this.maxLevel,
    required this.baseCost,
    this.costStep = 0,
  });

  final String id;
  final String name;
  final String blurb;
  final IconData icon;

  /// Highest level the player can own (1 = one-shot unlock).
  final int maxLevel;

  /// Cost of the first level; each further level costs [costStep] more.
  final int baseCost;
  final int costStep;

  /// Coins to buy the NEXT level, given how many are already owned.
  int costForLevel(int ownedLevel) => baseCost + costStep * ownedLevel;
}

/// The Gunsmith catalog. Perk effects are applied at run start (see the meta
/// loadout); unlock-card perks gate cards in the draft deck.
abstract final class MetaCatalog {
  static const reinforcedHeart = 'reinforced_heart';
  static const ironResolve = 'iron_resolve';
  static const quickHands = 'quick_hands';
  static const keenEye = 'keen_eye';
  static const luckyStrike = 'lucky_strike';
  static const secondWind = 'second_wind';

  static const List<MetaPerk> all = [
    MetaPerk(
      id: reinforcedHeart,
      name: 'Reinforced Heart',
      blurb: 'Ride out with +1 max heart.',
      icon: Icons.favorite,
      maxLevel: 2,
      baseCost: 150,
      costStep: 300,
    ),
    MetaPerk(
      id: ironResolve,
      name: 'Iron Resolve',
      blurb: 'Longer mercy after a hit — wider i-frames.',
      icon: Icons.shield_moon,
      maxLevel: 2,
      baseCost: 120,
      costStep: 200,
    ),
    MetaPerk(
      id: quickHands,
      name: 'Quick Hands',
      blurb: 'Draw a touch faster — shorter fire cooldown.',
      icon: Icons.bolt,
      maxLevel: 3,
      baseCost: 100,
      costStep: 160,
    ),
    MetaPerk(
      id: keenEye,
      name: 'Keen Eye',
      blurb: 'See one more bounce on the aim line.',
      icon: Icons.visibility,
      maxLevel: 2,
      baseCost: 120,
      costStep: 220,
    ),
    MetaPerk(
      id: luckyStrike,
      name: 'Lucky Strike',
      blurb: '+15% coins earned per level.',
      icon: Icons.savings,
      maxLevel: 3,
      baseCost: 100,
      costStep: 140,
    ),
    MetaPerk(
      id: secondWind,
      name: 'Second Wind',
      blurb: 'Begin each run with one free upgrade in hand.',
      icon: Icons.auto_awesome,
      maxLevel: 1,
      baseCost: 400,
    ),
  ];

  static MetaPerk byId(String id) => all.firstWhere((p) => p.id == id);
}
