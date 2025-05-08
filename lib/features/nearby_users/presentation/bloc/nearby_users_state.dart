part of 'nearby_users_bloc.dart';

sealed class NearbyUsersState extends Equatable {
  const NearbyUsersState();

  @override
  List<Object?> get props => [];
}

final class NearbyUsersInitial extends NearbyUsersState {}

final class NearbyUsersLoading extends NearbyUsersState {}

final class NearbyUsersLoaded extends NearbyUsersState {
  final List<NearbyUserSummary> nearbyUsers;

  const NearbyUsersLoaded(this.nearbyUsers);

  @override
  List<Object?> get props => [nearbyUsers];
}

final class NearbyUsersError extends NearbyUsersState {
  final String message;

  const NearbyUsersError(this.message);

  @override
  List<Object> get props => [message];
}
