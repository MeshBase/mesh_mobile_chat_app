import 'dart:async';
import 'dart:math';

import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mesh_mobile/database/database_helper.dart';

part 'settings_event.dart';
part 'settings_state.dart';

class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  SettingsBloc() : super(SettingsInitial()) {
    on<GetSettings>(_getSettings);
    on<ChangeName>(_changeName);
    on<SubmitUpdatedSettings>(_submitRegistration);
  }

  _splitUserName(String userName) {
    final chunks = userName.split('_');
    final appended =
        '_${chunks[chunks.length - 1]}_${chunks[chunks.length - 2]}';
    final base = chunks.sublist(0, chunks.length - 2).join('_');
    return (base, appended);
  }

  FutureOr<void> _getSettings(event, emit) async {
    emit(SettingsLoading());
    try {
      final user = await DatabaseHelper.getRegisteredUser();
      if (user == null) {
        throw Exception('User not found');
      }

      final (userNameBase, userNameAppended) = _splitUserName(user.userName);

      emit(SettingsFormState(
        pending: false,
        saved: false,
        error: '',
        name: user.name,
        userNameBase: userNameBase,
        userNameAppended: userNameAppended,
      ));
    } catch (e) {
      emit(SettingsFormState(
        pending: false,
        saved: false,
        error: 'Something went wrong - ${e.toString()}',
        name: '',
        userNameBase: '',
        userNameAppended: '',
      ));
    }
  }

  _changeName(ChangeName event, emit) {
    if (state is SettingsFormState) {
      final formState = state as SettingsFormState;
      emit(
        SettingsFormState(
          error: '',
          pending: false,
          saved: false,
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

  FutureOr<void> _submitRegistration(SubmitUpdatedSettings event, emit) async {
    if (state is SettingsFormState) {
      final formState = state as SettingsFormState;

      try {
        await DatabaseHelper.upsertRegisteredUser(
          formState.name,
          formState.userNameBase + formState.userNameAppended,
        );
        final user = await DatabaseHelper.getRegisteredUser();
        if (user == null) {
          throw Exception('User not found after updating');
        }
        emit(SettingsFormState(
          name: user.name,
          userNameBase: formState.userNameBase,
          userNameAppended: formState.userNameAppended,
          pending: false,
          saved: true,
          error: '',
        ));
      } catch (e) {
        emit(formState.copyWith(
          error: 'Something went wrong - ${e.toString()}',
          pending: false,
        ));
      }
    }
  }
}
