import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mesh_base_flutter/mesh_base_flutter.dart';

import 'mesh_dto.dart';

typedef NearbyDiscoveryListener = void Function(
    List<(String, BroadcastedIdentityDTO)> identity);

class NearbyDiscovery {
  static final MeshBaseFlutter mesh = MeshBaseFlutter();
  static String _name = "-";
  static String _userName = "-";
  static bool _isStarted = false;
  static List<NearbyDiscoveryListener> listeners = [];

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
    await mesh.turnOn();

    //show empty list at first
    for (NearbyDiscoveryListener listener in listeners) {
      listener(_currentIdentityList());
    }

    mesh.subscribe(MeshManagerListener(onDataReceivedForSelf: (protocol) {
      if (!BroadcastedIdentityDTO.canDecode(protocol.body)) return;

      final identity = BroadcastedIdentityDTO.fromBytes(protocol.body);
      final sender = protocol.sender;
      final expiry = DateTime.now().add(const Duration(seconds: 2));

      final isNew = !_identities.containsKey(sender);
      _identities[sender] = (expiry, identity);

      if (isNew) {
        for (var listener in listeners) {
          listener(_currentIdentityList());
        }
      }

      //to consider offline if no heartbeat is heard in 2 seconds
      Future.delayed(const Duration(seconds: 2), () {
        final now = DateTime.now();
        final newExpiryTime = _identities[sender]?.$1;
        if (newExpiryTime == null || newExpiryTime.isBefore(now)) {
          _identities.remove(sender);
          debugPrint('[X] ${identity.name} heart beat stopped');
          for (var listener in listeners) {
            listener(_currentIdentityList());
          }
        } else {
          debugPrint('[X] ${identity.name} heart beat continued');
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
    Timer.periodic(const Duration(seconds: 1), (timer) {
      mesh.send(
        protocol: MeshProtocol(
          messageType: ProtocolType.RAW_BYTES_MESSAGE,
          remainingHops: 100,
          messageId: -1,
          sender: id,
          destination: BROADCAST_UUID,
          body: myIdentity.toBytes(),
        ),
      );
    });
  }
}
