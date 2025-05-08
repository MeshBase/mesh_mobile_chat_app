import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mesh_mobile/features/nearby_users/data/nearby_repository.dart';
import 'package:mesh_mobile/features/nearby_users/domain/nearby_user_summary.dart';

part 'nearby_users_event.dart';
part 'nearby_users_state.dart';

class NearbyUsersBloc extends Bloc<NearbyUsersEvent, NearbyUsersState> {
  final NearbyRepository nearbyRepository;

  NearbyUsersBloc({required this.nearbyRepository})
      : super(NearbyUsersInitial()) {
    on<LoadNearbyUsers>(_onLoadNearbyUsers);
  }

  Future<void> _onLoadNearbyUsers(
    LoadNearbyUsers event,
    Emitter<NearbyUsersState> emit,
  ) async {
    emit(NearbyUsersLoading());

    final userIds = [
      "b01b1320-6660-4076-b847-c675ce8cb5f7",
      "1e184d65-ba62-40ca-a146-4192369af4ec",
      "032c9ca4-04e5-43b7-8c2e-56edbab33fa4",
    ];

    try {
      final List<NearbyUserSummary> nearbyUsers = await Future.wait(
        userIds.map((userId) async {
          return await nearbyRepository.fetchNearbyUserSummary(userId);
        }),
      );

      emit(NearbyUsersLoaded(nearbyUsers));
    } catch (e) {
      emit(NearbyUsersError(
          'Failed to get Nearby Devices, Exception: ${e.toString()}'));
    }
  }
}
