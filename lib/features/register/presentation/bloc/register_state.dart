part of 'register_bloc.dart';

sealed class RegisterState extends Equatable {
  const RegisterState();

  @override
  List<Object> get props => [];
}

final class RegisterInitial extends RegisterState {}

final class RegisterLoading extends RegisterState {}

final class AlreadyRegistered extends RegisterState {}

final class FormActiveRegistration extends RegisterState {
  final String name;
  final String userNameBase;
  final String userNameAppended;

  final bool pending;
  final String error;

  const FormActiveRegistration({
    required this.name,
    required this.userNameBase,
    required this.userNameAppended,
    required this.pending,
    required this.error,
  });

  @override
  List<Object> get props =>
      [name, userNameBase, userNameAppended, pending, error];

  copyWith({
    String? name,
    String? userNameBase,
    String? userNameAppended,
    bool? pending,
    String? error,
  }) {
    return FormActiveRegistration(
      name: name ?? this.name,
      userNameBase: userNameBase ?? this.userNameBase,
      userNameAppended: userNameAppended ?? this.userNameAppended,
      pending: pending ?? this.pending,
      error: error ?? this.error,
    );
  }
}

final class RegistrationSubmitted extends RegisterState {}
