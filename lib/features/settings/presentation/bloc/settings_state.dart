part of 'settings_bloc.dart';

sealed class SettingsState extends Equatable {
  const SettingsState();

  @override
  List<Object> get props => [];
}

final class SettingsInitial extends SettingsState {}

final class SettingsLoading extends SettingsState {}

final class SettingsLoadedState extends SettingsState {
  final String name;
  final String userNameBase;
  final String userNameAppended;

  final bool pending;
  final bool saved;
  final String error;

  const SettingsLoadedState({
    required this.name,
    required this.userNameBase,
    required this.userNameAppended,
    required this.pending,
    required this.error,
    required this.saved,
  });

  @override
  List<Object> get props =>
      [name, userNameBase, userNameAppended, pending, error, saved];

  copyWith({
    String? name,
    String? userNameBase,
    String? userNameAppended,
    bool? pending,
    String? error,
    bool? saved,
  }) {
    return SettingsLoadedState(
      name: name ?? this.name,
      userNameBase: userNameBase ?? this.userNameBase,
      userNameAppended: userNameAppended ?? this.userNameAppended,
      pending: pending ?? this.pending,
      error: error ?? this.error,
      saved: saved ?? this.saved,
    );
  }
}
