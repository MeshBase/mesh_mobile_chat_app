import 'dart:async';

import 'package:mesh_base_flutter/mesh_base_flutter.dart';
import 'package:mesh_mobile/common/utils/mesh_dto.dart';

class NearbyDiscovery {
  static final MeshBaseFlutter mesh = MeshBaseFlutter();
  static String _name = "<unknown name>";
  static String _userName = "<unknown user name>";

  static start(String name, String userName,
      void Function(BroadcastedIdentityDTO identity) listener) async {
    _name = name;
    _userName = userName;
    _listen(listener);
    _broadcast();
  }

  static _listen(
      void Function(BroadcastedIdentityDTO identity) listener) async {
    await mesh.turnOn();
    mesh.subscribe(MeshManagerListener(onDataReceivedForSelf: (protocol) {
      if (!BroadcastedIdentityDTO.canDecode(protocol.body)) return;
      final identity = BroadcastedIdentityDTO.fromBytes(protocol.body);
      listener(identity);
    }));
  }

  static _broadcast() async {
    await mesh.turnOn();
    var id = await mesh.getId();
    var myIdentity = BroadcastedIdentityDTO(_name, _userName);
    Timer.periodic(const Duration(seconds: 1), (Timer timer) {
      mesh.send(
          protocol: MeshProtocol(
              messageType: ProtocolType.RAW_BYTES_MESSAGE,
              remainingHops: 100,
              messageId: -1,
              sender: id,
              destination: BROADCAST_UUID,
              body: myIdentity.toBytes()));
    });
  }
}
