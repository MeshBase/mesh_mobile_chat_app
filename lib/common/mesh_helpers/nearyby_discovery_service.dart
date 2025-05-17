import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mesh_base_flutter/mesh_base_flutter.dart';

import 'mesh_dto.dart';

typedef NearbyDiscoveryListener = void Function(
    List<(String, BroadcastedIdentityDTO)> identity);

class NearbyDiscoveryService {
  static final MeshBaseFlutter mesh = MeshBaseFlutter();
  static String _name = "-";
  static String _userName = "-";
  static bool _isStarted = false;
  static List<NearbyDiscoveryListener> listeners = [];
  static int HEARTBEAT_SECONDS = 5;
  static int HEATBEAT_MAX_DELAY = 2;

  static final Map<String, (DateTime, BroadcastedIdentityDTO)> _identities = {};

  static start(
    String name,
    String userName,
  ) async {
    if (_isStarted) return;
    _name = name;
    _userName = userName;
    await _listen();
    await _broadcast();
    _isStarted = true;
  }

  static addListener(NearbyDiscoveryListener listener) {
    listeners.add(listener);
  }

  static removeListener(NearbyDiscoveryListener listener) {
    listeners.remove(listener);
  }

  static getIdentities() {
    return _currentIdentityList();
  }

  static _listen() async {
    debugPrint('[X] listening to nearby devices');
    await mesh.turnOn();

    //show empty list at first
    for (NearbyDiscoveryListener listener in listeners) {
      listener(_currentIdentityList());
    }

    await mesh.subscribe(MeshManagerListener(onDataReceivedForSelf: (protocol) {
      if (!BroadcastedIdentityDTO.canDecode(protocol.body)) {
        return;
      }

      final identity = BroadcastedIdentityDTO.fromBytes(protocol.body);
      final sender = protocol.sender;
      final expiry = DateTime.now()
          .add(Duration(seconds: HEARTBEAT_SECONDS + HEATBEAT_MAX_DELAY));

      final isNew = !_identities.containsKey(sender);
      _identities[sender] = (expiry, identity);

      if (isNew) {
        for (var listener in listeners) {
          listener(_currentIdentityList());
        }
      }

      Future.delayed(Duration(seconds: HEARTBEAT_SECONDS + HEATBEAT_MAX_DELAY),
          () {
        final now = DateTime.now();
        final newExpiryTime = _identities[sender]?.$1;
        if (newExpiryTime == null || newExpiryTime.isBefore(now)) {
          _identities.remove(sender);
          debugPrint(
              '[X] [${identity.name}][${identity.userName}] heart beat stopped');
        } else {
          debugPrint(
              '[X] ${identity.name}-${identity.userName} heart beat continued ${newExpiryTime.millisecondsSinceEpoch - now.millisecondsSinceEpoch}ms before expiry');
        }

        for (var listener in listeners) {
          listener(_currentIdentityList());
        }
      });
    }));
  }

  static List<(String, BroadcastedIdentityDTO)> _currentIdentityList() {
    return _identities.entries.map((e) => (e.key, e.value.$2)).toList();
  }

  static _broadcast() async {
    await mesh.turnOn();
    final id = await mesh.getId();
    final myIdentity = BroadcastedIdentityDTO(_name, _userName);

    //to broadcast heartbeat every second in 100 hop radius for online status
    Timer.periodic(Duration(seconds: HEARTBEAT_SECONDS), (timer) async {
      var neighbors = await mesh.getNeighbors();
      if (!neighbors.isNotEmpty) {
        debugPrint('[X] has no neighbors to broadcast to ${timer.tick}');
        return;
      }
      debugPrint('[X] broadcasting to ${neighbors.length} neighbors');

      var result = await mesh.send(
        protocol: MeshProtocol(
          messageType: ProtocolType.RAW_BYTES_MESSAGE,
          remainingHops: 100,
          messageId: -1,
          sender: id,
          destination: BROADCAST_UUID,
          body: myIdentity.toBytes(),
        ),
      );

      if (result.error != null) {
        debugPrint('[X] could not broadcast ${result.error?.message}');
      } else if (!result.acked) {
        debugPrint(
            '[X] broadcast was not acked - result was acked: ${result.acked},error: ${result.error}, response: ${result.response}');
      }
    });
  }
  //TODO: Implement stop()
}
