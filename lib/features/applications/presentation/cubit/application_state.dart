import 'package:equatable/equatable.dart';

import '../../data/models/application_model.dart';

abstract class ApplicationState extends Equatable {
  const ApplicationState();

  @override
  List<Object?> get props => [];
}

class ApplicationInitial extends ApplicationState {
  const ApplicationInitial();
}

class ApplicationLoading extends ApplicationState {
  const ApplicationLoading();
}

class ApplicationLoaded extends ApplicationState {
  final List<ApplicationModel> applications;

  const ApplicationLoaded(this.applications);

  @override
  List<Object?> get props => [applications];
}

class ApplicationActionSuccess extends ApplicationState {
  final String message;

  const ApplicationActionSuccess(this.message);

  @override
  List<Object?> get props => [message];
}

class ApplicationFailure extends ApplicationState {
  final String message;

  const ApplicationFailure(this.message);

  @override
  List<Object?> get props => [message];
}