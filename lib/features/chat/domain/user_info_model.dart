import 'package:equatable/equatable.dart';

class UserInfoModel extends Equatable {
  final String chatId;
  final String name;

  const UserInfoModel({required this.chatId, required this.name});
  @override
  List<Object?> get props => [chatId, name];
}
