import 'package:equatable/equatable.dart';

import '../../data/models/startup_profile_model.dart';

abstract class StartupState extends Equatable {
  const StartupState();

  @override
  List<Object?> get props => [];
}

class StartupInitial extends StartupState {
  const StartupInitial();
}

class StartupLoading extends StartupState {
  const StartupLoading();
}

class StartupProfileMissing extends StartupState {
  const StartupProfileMissing();
}

class StartupProfileLoaded extends StartupState {
  final StartupProfileModel profile;

  const StartupProfileLoaded(this.profile);

  @override
  List<Object?> get props => [profile];
}

class StartupProfilesLoaded extends StartupState {
  final List<StartupProfileModel> profiles;

  const StartupProfilesLoaded(this.profiles);

  @override
  List<Object?> get props => [profiles];
}

class StartupFailure extends StartupState {
  final String message;

  const StartupFailure(this.message);

  @override
  List<Object?> get props => [message];
}
