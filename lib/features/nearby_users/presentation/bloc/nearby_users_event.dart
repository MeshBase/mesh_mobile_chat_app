part of 'nearby_users_bloc.dart';

sealed class NearbyUsersEvent extends Equatable {
  const NearbyUsersEvent();

  @override
  List<Object?> get props => [];
}

class LoadNearbyUsers extends NearbyUsersEvent {}