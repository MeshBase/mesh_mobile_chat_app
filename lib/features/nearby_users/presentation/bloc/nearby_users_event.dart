part of 'nearby_users_bloc.dart';

sealed class NearbyUsersEvent extends Equatable {
  const NearbyUsersEvent();

  @override
  List<Object?> get props => [];
}

class LoadNearbyUsers extends NearbyUsersEvent {}

class UpdateNearbyUsers extends NearbyUsersEvent {
  final List<NearbyUserSummary> nearbyUsers;
  final String? error;
  const UpdateNearbyUsers({required this.nearbyUsers, required this.error});

  @override
  get props => [...nearbyUsers];
}
