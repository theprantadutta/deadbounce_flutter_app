/// Permanent ("Gunsmith") bonuses applied to a run at start, built from the
/// owned perk levels. **Empty for daily challenges** — those stay fair and
/// identical worldwide, unaffected by meta-progression.
class MetaLoadout {
  const MetaLoadout({
    this.permanentCards = const {},
    this.invulnBonus = 0,
    this.grantFreeCard = false,
  });

  /// Upgrade-card id → permanent stacks pre-loaded into the run (e.g.
  /// heart_container, quickdraw, longer_sight, coin_magnet). These fold
  /// through the normal modifier pipeline and count toward each card's
  /// max-stacks cap (so they can't be double-dipped past the limit).
  final Map<String, int> permanentCards;

  /// Extra seconds of mercy invulnerability after a hit (Iron Resolve).
  final double invulnBonus;

  /// Start the run with one free random common upgrade in hand (Second Wind).
  final bool grantFreeCard;

  static const empty = MetaLoadout();

  bool get isEmpty =>
      permanentCards.isEmpty && invulnBonus == 0 && !grantFreeCard;
}
