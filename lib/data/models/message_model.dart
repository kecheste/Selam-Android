import 'package:selam/data/entities/message_entities.dart';

class Message {
  final String senderId;
  final String recieverId;
  final String message;
  final DateTime dateSent;

  Message({
    required this.senderId,
    required this.recieverId,
    required this.message,
    required this.dateSent,
  });

  Map<String, dynamic> toMap() {
    return {
      'senderId': senderId,
      'recieverId': recieverId,
      'message': message,
      'dateSent': dateSent,
    };
  }

  static Message fromEntity(MessageEntity entity) {
    return Message(
      senderId: entity.senderId,
      recieverId: entity.recieverId,
      message: entity.message,
      dateSent: entity.dateSent,
    );
  }
}
