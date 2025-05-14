import 'package:mesh_base_flutter/mesh_base_flutter.dart';
import 'package:mesh_mobile/common/utils/mesh_dto.dart';

class MessageInteractions {
  static final mesh = MeshBaseFlutter();
  static start(
      void Function(MessageDTO messageDto, String sourceUUID) listener) async {
    await mesh.turnOn();
    mesh.subscribe(
        MeshManagerListener(onDataReceivedForSelf: (MeshProtocol protocol) {
      if (!MessageDTO.canDecode(protocol.body)) return;
      var messageDto = MessageDTO.fromBytes(protocol.body);
      listener(messageDto, protocol.sender);
    }));
  }
}
