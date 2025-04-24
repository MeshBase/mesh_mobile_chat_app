part of 'register_bloc.dart';

sealed class RegisterEvent extends Equatable {
  const RegisterEvent();

  @override
  List<Object> get props => [];
}

final class GetIsRegistered extends RegisterEvent {}

final class ChangeName extends RegisterEvent {
  final String name;

  const ChangeName({required this.name});

  @override
  List<Object> get props => [name];
}

final class SubmitRegistration extends RegisterEvent {}
