import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mesh_mobile/common/mesh_helpers/nearyby_discovery_service.dart';
import 'package:mesh_mobile/common/repositories/message_repository.dart';
import 'package:mesh_mobile/database/database_helper.dart';
import 'package:mesh_mobile/features/nearby_users/data/nearby_repository.dart';
import 'package:mesh_mobile/features/nearby_users/domain/nearby_user_summary.dart';

import '../../../../common/mesh_helpers/mesh_dto.dart';

part 'nearby_users_event.dart';
part 'nearby_users_state.dart';

class NearbyUsersBloc extends Bloc<NearbyUsersEvent, NearbyUsersState> {
  final NearbyRepository nearbyRepository;
  final MessageRepository messageRepository;
  NearbyDiscoveryListener? discoveryListener;

  NearbyUsersBloc({
    required this.nearbyRepository,
    required this.messageRepository,
  }) : super(NearbyUsersInitial()) {
    on<LoadNearbyUsers>(_onLoadNearbyUsers);
    on<UpdateNearbyUsers>(_onUpdateUsers);

    _startListeningToMessages();
  }

  Future<List<NearbyUserSummary>> _prepareNearbyUsersList(
      List<(String, BroadcastedIdentityDTO)> identities) async {
    final List<NearbyUserSummary> nearbyUsers = await Future.wait(
      identities.map((item) async {
        var (uuid, identity) = item;
        var user = await nearbyRepository.fetchNearbyUserSummary(uuid);
        if (user == null) {
          debugPrint("[X] user will always be null $uuid, $identity");
          return NearbyUserSummary(
              userId: uuid,
              name: identity.name,
              username: identity.userName,
              initial: (identity.name).isNotEmpty ? (identity.name)[0] : '-',
              isOnline: true);
        } else {
          return user;
        }
      }),
    );
    return nearbyUsers;
  }

  Future<void> _onLoadNearbyUsers(
    LoadNearbyUsers event,
    Emitter<NearbyUsersState> emit,
  ) async {
    emit(NearbyUsersLoading());
    //listen to new nearby devices changes
    try {
      await DatabaseHelper.db;
      var user = await DatabaseHelper.getRegisteredUser();
      if (user == null) {
        emit(const NearbyUsersError("User not registered yet!"));
        return;
      }

      discoveryListener = (identities) async {
        try {
          var users = await _prepareNearbyUsersList(identities);
          add(UpdateNearbyUsers(nearbyUsers: users, error: null));
        } catch (e) {
          List<NearbyUserSummary> users = [];
          if (state is NearbyUsersLoaded) {
            users = (state as NearbyUsersLoaded).nearbyUsers;
          }
          //TODO: Implement a snack bar to show loaded state errors even though they shouldn't happen
          add(UpdateNearbyUsers(nearbyUsers: users, error: e.toString()));
        }
      };
      NearbyDiscoveryService.addListener(discoveryListener!);
      await NearbyDiscoveryService.start(user.name, user.userName);
    } catch (e) {
      emit(NearbyUsersError(
          'Failed to get Nearby Devices, Exception: ${e.toString()}'));
    }
  }

  Future<void> _onUpdateUsers(
      UpdateNearbyUsers event, Emitter<NearbyUsersState> emit) async {
    emit(NearbyUsersLoaded(event.nearbyUsers));
  }

  @override
  Future<void> close() {
    if (discoveryListener != null) {
      NearbyDiscoveryService.removeListener(discoveryListener!);
    }
    return super.close();
  }

  void _startListeningToMessages() {
    messageRepository.messageStream.listen((message) async {
      add(UpdateNearbyUsers(
          nearbyUsers: await _prepareNearbyUsersList(
              NearbyDiscoveryService.getIdentities()),
          error: ""));
    });
  }
}
