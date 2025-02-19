import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final String senderId;
  final String recieverId;
  final String message;
  final DateTime dateSent;

  const MessageEntity({
    required this.senderId,
    required this.message,
    required this.recieverId,
    required this.dateSent,
  });

  Map<String, Object?> toDocument() {
    return {
      'senderId': senderId,
      'recieverId': recieverId,
      'message': message,
      'dateSent': dateSent,
    };
  }

  static MessageEntity fromDocument(Map<String, dynamic> doc) {
    return MessageEntity(
      senderId: doc['senderId'] as String,
      recieverId: doc['recieverId'] as String,
      message: doc['message'] as String,
      dateSent: doc['dateSent'] as DateTime,
    );
  }

  @override
  List<Object?> get props => [senderId, recieverId, message, dateSent];
}
