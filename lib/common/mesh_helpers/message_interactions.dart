import 'package:flutter/cupertino.dart';
import 'package:mesh_base_flutter/mesh_base_flutter.dart';

import 'mesh_dto.dart';

typedef MessageInteractionsListener = void Function(
    MessageDTO messageDto, String sourceUUID);

class MessageInteractions {
  static final _mesh = MeshBaseFlutter();
  static bool _started = false;
  static List<MessageInteractionsListener> _listeners = [];

  static start() async {
    if (_started) return;
    await _mesh.turnOn();
    await _listen();
    _started = false;
  }

  static addListener(MessageInteractionsListener listener) {
    _listeners.add(listener);
  }

  static removeListener(MessageInteractionsListener listener) {
    _listeners.remove(listener);
  }

  static _listen() async {
    await _mesh.subscribe(
        MeshManagerListener(onDataReceivedForSelf: (MeshProtocol protocol) {
      if (!MessageDTO.canDecode(protocol.body)) return;
      var messageDto = MessageDTO.fromBytes(protocol.body);
      for (MessageInteractionsListener listener in _listeners) {
        listener(messageDto, protocol.sender);
      }
    }));
  }

  static send(String message, String destination) async {
    var id = await _mesh.getId();
    var res = await _mesh.send(
        protocol: MeshProtocol(
            messageType: ProtocolType.RAW_BYTES_MESSAGE,
            remainingHops: 100,
            messageId: -1,
            sender: id,
            destination: destination,
            body: MessageDTO(message).toBytes()));
    if (res.response != null || res.acked) {
      debugPrint('[X] $message sent successfully to $destination');
    } else if (res.error != null) {
      throw res.error!;
    }
  }
}
