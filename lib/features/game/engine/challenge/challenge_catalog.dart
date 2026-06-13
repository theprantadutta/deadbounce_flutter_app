import '../game_rng.dart';
import '../waves/wave_definition.dart';
import 'challenge_config.dart';

/// One day's challenge: name, rules copy, and the config that shapes the
/// run. Pure value — identical worldwide for a given UTC date.
class DailyChallengeDefinition {
  const DailyChallengeDefinition({
    required this.utcDate,
    required this.seed,
    required this.name,
    required this.tagline,
    required this.rules,
    required this.config,
  });

  /// yyyy-MM-dd UTC.
  final String utcDate;
  final int seed;
  final String name;
  final String tagline;

  /// Bullet-point rules, in the Deadbounce voice.
  final List<String> rules;
  final ChallengeConfig config;
}

/// Deterministically derives the day's challenge from its UTC-date seed.
/// Every player worldwide gets the same one, offline.
abstract final class ChallengeCatalog {
  static DailyChallengeDefinition forUtcDate(String utcDate, int seed) {
    final pick = GameRng(seed).fork('challenge-pick').nextInt(_templates.length);
    final template = _templates[pick];
    return DailyChallengeDefinition(
      utcDate: utcDate,
      seed: seed,
      name: template.name,
      tagline: template.tagline,
      rules: template.rules,
      config: template.config,
    );
  }

  static const List<_Template> _templates = [
    _Template(
      name: "GUNSLINGER'S GAUNTLET",
      tagline: 'One life. Triple the glory.',
      rules: ['Start with a single heart.', 'All score is tripled.'],
      config: ChallengeConfig(startingHearts: 1, scoreMultiplier: 3),
    ),
    _Template(
      name: 'STAMPEDE',
      tagline: 'Nothing but horns and dust.',
      rules: ['Chargers only — every wave.', 'Dodge or die.'],
      config: ChallengeConfig(forcedEnemyType: EnemyType.charger),
    ),
    _Template(
      name: 'HARD WALLS',
      tagline: 'The bricks bite back harder.',
      rules: ['Every bounce deals +2 damage.', 'Make the geometry work.'],
      config: ChallengeConfig(extraWallDamage: 2),
    ),
    _Template(
      name: 'WILD DRAW',
      tagline: 'No choosing. Just fate.',
      rules: ['Upgrades are dealt at random.', 'Play the hand you get.'],
      config: ChallengeConfig(randomUpgrades: true),
    ),
    _Template(
      name: 'GHOST TOWN',
      tagline: 'A swarm with no faces.',
      rules: ['Drifters only — endless swarms.', 'Score counts double.'],
      config: ChallengeConfig(
        forcedEnemyType: EnemyType.drifter,
        scoreMultiplier: 2,
      ),
    ),
    _Template(
      name: 'SPLIT DECISION',
      tagline: 'Kill one, make two.',
      rules: ['Splitters only.', 'The arena fills fast.'],
      config: ChallengeConfig(forcedEnemyType: EnemyType.splitter),
    ),
  ];
}

class _Template {
  const _Template({
    required this.name,
    required this.tagline,
    required this.rules,
    required this.config,
  });

  final String name;
  final String tagline;
  final List<String> rules;
  final ChallengeConfig config;
}
