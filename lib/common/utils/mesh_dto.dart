import 'dart:convert';
import 'dart:typed_data';

// Data Transfer Object Types
enum DtoType {
  broadcastedIdentity(0x01),
  message(0x02);

  final int value;
  const DtoType(this.value);
}

abstract class DTO {
  DtoType get type;
  Uint8List toBytes();
}

Uint8List _writeUint16(int value) {
  final data = Uint8List(2);
  ByteData.view(data.buffer).setUint16(0, value, Endian.big);
  return data;
}

int _readUint16(Uint8List bytes, int offset) {
  return ByteData.sublistView(bytes, offset, offset + 2)
      .getUint16(0, Endian.big);
}

class BroadcastedIdentityDTO implements DTO {
  final String name;
  final String userName;

  BroadcastedIdentityDTO(this.name, this.userName);

  @override
  DtoType get type => DtoType.broadcastedIdentity;

  @override
  Uint8List toBytes() {
    final nameBytes = utf8.encode(name);
    final userNameBytes = utf8.encode(userName);

    //type + name length + name + username length + username
    final buffer =
        Uint8List(1 + 2 + nameBytes.length + 2 + userNameBytes.length);
    buffer[0] = type.value;

    int offset = 1;

    buffer.setRange(offset, offset + 2, _writeUint16(nameBytes.length));
    offset += 2;
    buffer.setRange(offset, offset + nameBytes.length, nameBytes);
    offset += nameBytes.length;

    buffer.setRange(offset, offset + 2, _writeUint16(userNameBytes.length));
    offset += 2;
    buffer.setRange(offset, offset + userNameBytes.length, userNameBytes);

    return buffer;
  }

  static BroadcastedIdentityDTO fromBytes(Uint8List bytes) {
    int offset = 1; // Skip type byte

    final nameLength = _readUint16(bytes, offset);
    offset += 2;
    final name = utf8.decode(bytes.sublist(offset, offset + nameLength));
    offset += nameLength;

    final userNameLength = _readUint16(bytes, offset);
    offset += 2;
    final userName =
        utf8.decode(bytes.sublist(offset, offset + userNameLength));

    return BroadcastedIdentityDTO(name, userName);
  }

  static bool canDecode(Uint8List bytes) {
    return bytes.isNotEmpty && bytes[0] == DtoType.broadcastedIdentity.value;
  }
}

// Message DTO
class MessageDTO implements DTO {
  final String message;

  MessageDTO(this.message);

  @override
  DtoType get type => DtoType.message;

  @override
  Uint8List toBytes() {
    final messageBytes = utf8.encode(message);
    final buffer = Uint8List(1 + 2 + messageBytes.length)..[0] = type.value;

    int offset = 1;
    buffer.setRange(offset, offset + 2, _writeUint16(messageBytes.length));
    offset += 2;
    buffer.setRange(offset, offset + messageBytes.length, messageBytes);

    return buffer;
  }

  static MessageDTO fromBytes(Uint8List bytes) {
    int offset = 1; // Skip type byte

    final messageLength = _readUint16(bytes, offset);
    offset += 2;
    final message = utf8.decode(bytes.sublist(offset, offset + messageLength));

    return MessageDTO(message);
  }

  static bool canDecode(Uint8List bytes) {
    return bytes.isNotEmpty && bytes[0] == DtoType.message.value;
  }
}
