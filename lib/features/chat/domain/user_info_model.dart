import 'package:equatable/equatable.dart';

class UserInfoModel extends Equatable {
  final String chatId;
  final String userId;
  final String name;

  const UserInfoModel(
      {required this.chatId, required this.name, required this.userId});
  @override
  List<Object?> get props => [chatId, name, userId];
}
