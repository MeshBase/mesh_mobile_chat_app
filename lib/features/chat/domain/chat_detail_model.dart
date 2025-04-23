import 'package:equatable/equatable.dart';

class ChatDetailModel extends Equatable {
  final bool isSender;
  final String content;

  const ChatDetailModel({required this.isSender, required this.content});

  @override
  List<Object?> get props => [isSender, content];
}
