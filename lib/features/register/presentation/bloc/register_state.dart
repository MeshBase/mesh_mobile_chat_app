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
  final RegisterModel registration;

  const FormActiveRegistration({required this.registration});

  @override
  List<Object> get props => [...registration.props];
}

final class PendingRegistration extends RegisterState {
  final RegisterModel registration;

  const PendingRegistration({required this.registration});

  @override
  List<Object> get props => [...registration.props];
}
