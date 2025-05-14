part of 'settings_bloc.dart';

sealed class SettingsEvent extends Equatable {
  const SettingsEvent();

  @override
  List<Object> get props => [];
}

final class GetSettings extends SettingsEvent {}

final class ChangeName extends SettingsEvent {
  final String name;

  const ChangeName({required this.name});

  @override
  List<Object> get props => [name];
}

final class SubmitUpdatedSettings extends SettingsEvent {}
