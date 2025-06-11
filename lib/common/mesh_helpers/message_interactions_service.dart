import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mesh_base_flutter/mesh_base_flutter.dart';

import 'mesh_dto.dart';

typedef MessageInteractionsListener = void Function(
    MessageDTO messageDto, String sourceUUID);

class MessageInteractionsService {
  static final _mesh = MeshBaseFlutter();
  static bool _started = false;
  static final List<MessageInteractionsListener> _listeners = [];

  static final StreamController<(MessageDTO, MeshProtocol)> _controller =
      StreamController.broadcast();

  static Stream<(MessageDTO, MeshProtocol)> get stream => _controller.stream;

  static start() async {
    if (_started) return;
    await _mesh.turnOn();
    await _listen();
    // await _broadcastRandomMessages();
    _started = false;
  }

  // TODO: LEGACY CODE REMOVE WHEN POSSIBLE
  static addListener(MessageInteractionsListener listener) {
    _listeners.add(listener);
  }

  // TODO: LEGACY CODE REMOVE WHEN POSSIBLE
  static removeListener(MessageInteractionsListener listener) {
    _listeners.remove(listener);
  }

  static _listen() async {
    await _mesh.subscribe(MeshManagerListener(
        onDataReceivedForSelf: (MeshProtocol protocol) async {
      if (!MessageDTO.canDecode(protocol.body)) {
        return;
      }
      var messageDto = MessageDTO.fromBytes(protocol.body);

      debugPrint(
          '[X] received from ${messageDto.message} from:${protocol.sender}');

      // ==== REPLACED WITH THE BOTTOM ONE LINER CODE ==== [LEGACY]
      // for (MessageInteractionsListener listener in _listeners) {
      //   listener(messageDto, protocol.sender);
      // }

      _controller.add((messageDto, protocol));

      //TODO: replace with ack
      final reply = MeshProtocol(
        messageType: ProtocolType.RAW_BYTES_MESSAGE,
        remainingHops: 100,
        messageId: protocol.messageId,
        sender: protocol.destination,
        destination: protocol.sender,
        body: MessageDTO("re: ${messageDto.message}").toBytes(),
      );
      var res = await _mesh.send(protocol: reply, keepMessageId: true);
      if (res.acked) {
        debugPrint('[X] Reply acked');
      } else if (res.error != null) {
        debugPrint('[X] Reply error: ${res.error}');
      } else if (res.response != null) {
        debugPrint(
          '[X] Reply to reply received (should not happen): ${res.response.toString()}',
        );
      }
    }));
  }

  static send(String message, String destination) async {
    var id = await _mesh.getId();
    final protocol = MeshProtocol(
      messageType: ProtocolType.RAW_BYTES_MESSAGE,
      remainingHops: -1,
      messageId: -1,
      sender: id,
      destination: destination,
      body: MessageDTO(message).toBytes(),
    );
    await _mesh.send(protocol: protocol, keepMessageId: false).then((
      res,
    ) {
      if (res.acked) {
        debugPrint('[X] Ack for "$message"');
      } else if (res.error != null) {
        debugPrint('[X] Send error: ${res.error}');
        throw Exception(res.error);
      } else if (res.response?.body != null) {
        debugPrint(
          "[X] Response received from :$destination ${MessageDTO.fromBytes(res.response!.body)}",
        );
      }
    });
  }

  //TODO: only for testing incoming messages, remove after testing
  static _broadcastRandomMessages() async {
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      var neighbors = await _mesh.getNeighbors();
      debugPrint('[X] sending hello world to ${neighbors.length} neighbors');
      for (var user in neighbors) {
        await send("hello world ${timer.tick}", user.uuid);
      }
    });
  }
}
