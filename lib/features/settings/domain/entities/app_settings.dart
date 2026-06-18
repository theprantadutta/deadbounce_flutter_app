import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  const AppSettings({
    this.soundEnabled = true,
    this.hapticsEnabled = true,
    this.musicEnabled = true,
  });

  final bool soundEnabled;
  final bool hapticsEnabled;
  final bool musicEnabled;

  AppSettings copyWith({
    bool? soundEnabled,
    bool? hapticsEnabled,
    bool? musicEnabled,
  }) =>
      AppSettings(
        soundEnabled: soundEnabled ?? this.soundEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
        musicEnabled: musicEnabled ?? this.musicEnabled,
      );

  @override
  List<Object?> get props => [soundEnabled, hapticsEnabled, musicEnabled];
}
