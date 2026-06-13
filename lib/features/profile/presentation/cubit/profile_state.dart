part of 'profile_cubit.dart';

sealed class ProfileState extends Equatable {
  const ProfileState();

  @override
  List<Object?> get props => [];
}

final class ProfileLoading extends ProfileState {
  const ProfileLoading();
}

final class ProfileError extends ProfileState {
  const ProfileError(this.message);
  final String message;

  @override
  List<Object?> get props => [message];
}

final class ProfileLoaded extends ProfileState {
  const ProfileLoaded(this.data);
  final ProfileData data;

  @override
  List<Object?> get props => [data];
}
