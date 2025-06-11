import 'package:equatable/equatable.dart';

class UserInfoModel extends Equatable {
  final String chatId;
  final String userId;
  final String name;
  final String userName;

  const UserInfoModel(
      {required this.chatId, required this.name, required this.userId, required this.userName,});
  @override
  List<Object?> get props => [chatId, name, userId];
}
