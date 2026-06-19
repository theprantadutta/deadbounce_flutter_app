import 'package:equatable/equatable.dart';

/// Particle density preset → the live particle budget the game enforces.
/// `medium` (600) is the historical default.
enum ParticleQuality {
  low(250),
  medium(600),
  high(1200);

  const ParticleQuality(this.budget);

  /// Max simultaneous particles for this preset.
  final int budget;

  static ParticleQuality fromName(String? name) => ParticleQuality.values
      .firstWhere((q) => q.name == name, orElse: () => ParticleQuality.medium);
}

class AppSettings extends Equatable {
  const AppSettings({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.musicEnabled = true,
    this.screenShakeEnabled = true,
    this.hitStopEnabled = true,
    this.aimGuideEnabled = true,
    this.combatTextEnabled = true,
    this.particleQuality = ParticleQuality.medium,
  });

  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool musicEnabled;

  /// Camera trauma shake on kills / chains / Warden hits.
  final bool screenShakeEnabled;

  /// Time-freeze on multi-kills and Warden phase breaks.
  final bool hitStopEnabled;

  /// The predicted ricochet preview line while aiming.
  final bool aimGuideEnabled;

  /// Floating bounce counters ("x2") and chain labels ("DOUBLE KILL").
  final bool combatTextEnabled;

  /// Particle density preset.
  final ParticleQuality particleQuality;

  AppSettings copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? musicEnabled,
    bool? screenShakeEnabled,
    bool? hitStopEnabled,
    bool? aimGuideEnabled,
    bool? combatTextEnabled,
    ParticleQuality? particleQuality,
  }) =>
      AppSettings(
        soundEnabled: soundEnabled ?? this.soundEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        musicEnabled: musicEnabled ?? this.musicEnabled,
        screenShakeEnabled: screenShakeEnabled ?? this.screenShakeEnabled,
        hitStopEnabled: hitStopEnabled ?? this.hitStopEnabled,
        aimGuideEnabled: aimGuideEnabled ?? this.aimGuideEnabled,
        combatTextEnabled: combatTextEnabled ?? this.combatTextEnabled,
        particleQuality: particleQuality ?? this.particleQuality,
      );

  @override
  List<Object?> get props => [
        soundEnabled,
        hapticsEnabled,
        musicEnabled,
        screenShakeEnabled,
        hitStopEnabled,
        aimGuideEnabled,
        combatTextEnabled,
        particleQuality,
      ];
}
