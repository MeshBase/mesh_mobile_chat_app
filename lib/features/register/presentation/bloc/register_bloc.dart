import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mesh_mobile/database/database_helper.dart';
import 'package:mesh_mobile/features/register/domain/register_model.dart';

part 'register_event.dart';
part 'register_state.dart';

class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  RegisterBloc() : super(RegisterInitial()) {
    on<GetIsRegistered>(_getIsRegistered);
    on<ChangeName>(_changeName);
    on<SubmitRegistration>(_submitRegistration);
  }

  FutureOr<void> _getIsRegistered(event, emit) async {
    emit(RegisterLoading());
    final user = await DatabaseHelper.getRegisteredUser();
    debugPrint('[X] user is $user');

    if (user != null) {
      emit(Registered(
          user: RegisterModel(name: user.name, userName: user.userName),
          wasAlreadyRegistered: true));
    } else {
      emit(FormActiveRegistration(
        pending: false,
        error: '',
        name: '',
        userNameBase: '',
        userNameAppended:
            '_${generateRandomString(length: 4)}_${generateRandomString(length: 4)}',
      ));
    }
  }

  _changeName(ChangeName event, emit) {
    if (state is FormActiveRegistration) {
      final formState = state as FormActiveRegistration;
      emit(
        FormActiveRegistration(
          error: '',
          pending: false,
          name: event.name,
          userNameBase: _toUserNameBase(event.name),
          userNameAppended: formState.userNameAppended,
        ),
      );
    }
  }

  _toUserNameBase(String name) {
    return '@${name.trim().split(' ').where((char) => char.isNotEmpty).join('_').toLowerCase()}';
  }

  String generateRandomString({int length = 12}) {
    final random = Random();

    const lowercaseLetters = 'abcdefghijklmnopqrstuvwxyz';
    final chars = List.generate(
        length,
        (index) => lowercaseLetters
            .codeUnitAt(random.nextInt(lowercaseLetters.length)));

    return String.fromCharCodes(chars);
  }

  FutureOr<void> _submitRegistration(SubmitRegistration event, emit) async {
    if (state is FormActiveRegistration) {
      final formState = state as FormActiveRegistration;

      try {
        await DatabaseHelper.upsertRegisteredUser(
          formState.name,
          formState.userNameBase + formState.userNameAppended,
        );
        final user = await DatabaseHelper.getRegisteredUser();
        if (user == null) {
          throw Exception('User not found after registration');
        }
        emit(Registered(
            user: RegisterModel(name: user.name, userName: user.userName),
            wasAlreadyRegistered: false));
      } catch (e) {
        emit(formState.copyWith(
          error: 'Something went wrong - ${e.toString()}',
          pending: false,
        ));
      }
    }
  }
}
