import 'dart:async';

import 'package:mesh_base_flutter/mesh_base_flutter.dart';
import 'package:mesh_mobile/common/mesh_helpers/mesh_dto.dart';
import 'package:mesh_mobile/common/mesh_helpers/message_interactions_service.dart';
import 'package:mesh_mobile/database/database_helper.dart';

class MessageRepository {
  final _controller = StreamController<MessageDTO>.broadcast();
  late final StreamSubscription _subscription;

  Stream<MessageDTO> get messageStream => _controller.stream;

  MessageRepository() {
    _subscription = MessageInteractionsService.stream.listen(_handleMessage);
  }

  void _handleMessage((MessageDTO, MeshProtocol) data) async {
    final MessageDTO messageDTO = data.$1;
    final MeshProtocol protocol = data.$2;

    await DatabaseHelper.storeMessage(
      chatId: protocol.sender,
      senderId: protocol.sender,
      content: messageDTO.message,
      isSender: false,
    );

    _controller.add(messageDTO);
  }

  void dispose() {
    _subscription.cancel();
    _controller.close();
  }
}
