import 'package:equatable/equatable.dart';

class AppSettings extends Equatable {
  const AppSettings({this.soundEnabled = true, this.hapticsEnabled = true});

  final bool soundEnabled;
  final bool hapticsEnabled;

  AppSettings copyWith({bool? soundEnabled, bool? hapticsEnabled}) =>
      AppSettings(
        soundEnabled: soundEnabled ?? this.soundEnabled,
        hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
      );

  @override
  List<Object?> get props => [soundEnabled, hapticsEnabled];
}
