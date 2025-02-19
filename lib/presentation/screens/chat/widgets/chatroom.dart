import 'package:selam/data/models/user_model.dart';
import 'package:selam/data/repositories/auth.dart';
import 'package:selam/data/repositories/chat.dart';
import 'package:selam/presentation/widgets/loading/loading_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatRoom extends StatefulWidget {
  const ChatRoom({
    super.key,
    required this.user,
    required this.chatRoomId,
    required this.chatOponent,
  });

  final MyUser user;
  final MyUser chatOponent;
  final String chatRoomId;

  @override
  State<ChatRoom> createState() => _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  final TextEditingController _messageController = TextEditingController();
  final ChatRepository chatRepository = ChatRepository();

  String myId = FirebaseAuth.instance.currentUser!.uid;

  Stream? messageStream;

  Future addMessage(String text) async {
    if (_messageController.text.isNotEmpty) {
      Map<String, dynamic> messageInfoMap = {
        "message": text,
        "sentBy": widget.user.id,
        "sentDate": Timestamp.now(),
      };

      await chatRepository.sendMessage(
          widget.chatRoomId, messageInfoMap, widget.chatOponent.id);

      Map<String, dynamic> lastMessageInfoMap = {
        "lastMessage": text,
        "dateSent": DateTime.now(),
        "sentBy": widget.user.id,
      };
      await chatRepository.updateLastMessageSent(
          widget.chatRoomId, lastMessageInfoMap);
    }
  }

  Widget chatMessage() {
    return StreamBuilder(
      stream: messageStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (snapshot.hasData) {
          return ListView.builder(
            itemCount: snapshot.data.docs.length,
            reverse: true,
            itemBuilder: (context, index) {
              DocumentSnapshot ds = snapshot.data.docs[index];
              return chatMessageTile(
                ds["message"],
                widget.user.id == ds['sentBy'],
                ds['sentDate'].toDate(),
              );
            },
          );
        } else {
          return Center(child: buildLoadingIndicator(40, Colors.pink.shade600));
        }
      },
    );
  }

  Future<void> getAndSetMessage() async {
    messageStream = await chatRepository.getChatMessages(widget.chatRoomId);
    setState(() {});
  }

  @override
  void initState() {
    getAndSetMessage();
    super.initState();
  }

  Widget chatMessageTile(String message, bool sentByMe, DateTime dateSent) {
    return Container(
      margin: EdgeInsets.only(
        bottom: 10,
      ),
      child: Align(
        alignment: sentByMe ? Alignment.centerRight : Alignment.centerLeft,
        child: Column(
          crossAxisAlignment:
              sentByMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              margin: EdgeInsets.only(
                right: sentByMe ? 10 : 0,
                left: sentByMe ? 0 : 10,
              ),
              decoration: BoxDecoration(
                color: sentByMe
                    ? Color.fromARGB(255, 250, 77, 77)
                    : Color.fromARGB(255, 35, 40, 47),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(25),
                  topRight: const Radius.circular(25),
                  bottomLeft:
                      sentByMe ? const Radius.circular(25) : Radius.zero,
                  bottomRight:
                      sentByMe ? Radius.zero : const Radius.circular(25),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    blurRadius: 5,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
            ),
            Container(
              margin: EdgeInsets.only(
                right: sentByMe ? 10 : 0,
                left: sentByMe ? 0 : 10,
              ),
              child: Text(
                timeago.format(dateSent),
                style: TextStyle(
                  color: Colors.grey.shade600,
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AuthRepository authRepository = AuthRepository();

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(
            FontAwesomeIcons.arrowLeft,
            color: Colors.white,
          ),
        ),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 16,
              backgroundImage: NetworkImage(widget.chatOponent.profilePicture!),
            ),
            const SizedBox(width: 10),
            Text(
              widget.chatOponent.name,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(width: 5),
            StreamBuilder(
              stream: authRepository.usersCollection
                  .doc(widget.chatOponent.id)
                  .snapshots(),
              builder: (context, snapshot) {
                return Icon(
                  FontAwesomeIcons.circleCheck,
                  size: 10,
                  color: snapshot.data?['isOnline'] == true
                      ? Colors.green
                      : Colors.red,
                );
              },
            ),
          ],
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(
              FontAwesomeIcons.circleInfo,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
        centerTitle: true,
        backgroundColor: Colors.grey[900],
        elevation: 0,
      ),
      body: Container(
        color: Colors.black,
        child: Column(
          children: [
            Expanded(child: chatMessage()),
            Container(
              padding: const EdgeInsets.all(10),
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      style: const TextStyle(color: Colors.white),
                      controller: _messageController,
                      onSubmitted: (text) {
                        if (text.isNotEmpty) {
                          addMessage(text);
                          _messageController.clear();
                        }
                      },
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Color.fromARGB(255, 35, 40, 47),
                        hintText: 'Write your message',
                        hintStyle: TextStyle(
                          color: Colors.grey.shade200,
                          fontWeight: FontWeight.w300,
                          fontSize: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                          borderSide: BorderSide.none,
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 15),
                        suffixIcon: IconButton(
                          onPressed: () {
                            if (_messageController.text.isNotEmpty) {
                              addMessage(_messageController.text);
                              _messageController.clear();
                            }
                          },
                          icon: Icon(
                            Icons.send,
                            color: Color.fromARGB(255, 95, 177, 47),
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
