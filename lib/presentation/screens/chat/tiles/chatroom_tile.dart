import 'package:selam/data/models/user_model.dart';
import 'package:selam/data/repositories/auth.dart';
import 'package:selam/presentation/screens/chat/widgets/chatroom.dart';
import 'package:selam/presentation/widgets/loading/loading_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:timeago/timeago.dart' as timeago;

class ChatroomTile extends StatefulWidget {
  final String lastMessage, chatRoomId;
  final MyUser user;
  final Timestamp dateSent;
  const ChatroomTile(
      {super.key,
      required this.dateSent,
      required this.chatRoomId,
      required this.lastMessage,
      required this.user});

  @override
  State<ChatroomTile> createState() => _ChatroomTileState();
}

class _ChatroomTileState extends State<ChatroomTile> {
  final AuthRepository authRepository = AuthRepository();
  MyUser? chatOponent;

  getthisuserInfo() async {
    String opId =
        widget.chatRoomId.replaceAll("_", "").replaceAll(widget.user.id, "");
    MyUser chatUser = await authRepository.getMyUser(opId);
    if (mounted) {
      setState(() {
        chatOponent = chatUser;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    getthisuserInfo();
  }

  @override
  Widget build(BuildContext context) {
    if (chatOponent == null) {
      return Center(child: buildLoadingIndicator(40, Colors.pink.shade600));
    }

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatRoom(
              user: widget.user,
              chatOponent: chatOponent!,
              chatRoomId: widget.chatRoomId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 12),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(15),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(50),
                      child: chatOponent!.profilePicture!.isEmpty
                          ? Image.asset(
                              'assets/icons/user1.png',
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                            )
                          : Image.network(
                              chatOponent!.profilePicture!,
                              height: 40,
                              width: 40,
                              fit: BoxFit.cover,
                            ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          chatOponent!.name.length < 15
                              ? chatOponent!.name
                              : chatOponent!.name.substring(0, 15),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(width: 5),
                        StreamBuilder(
                          stream: authRepository.usersCollection
                              .doc(chatOponent!.id)
                              .snapshots(),
                          builder: (context, snapshot) {
                            if (snapshot.hasData &&
                                snapshot.data!['isOnline'] == true) {
                              return Icon(
                                FontAwesomeIcons.circleCheck,
                                size: 10,
                                color: Colors.green,
                              );
                            }
                            return Icon(
                              FontAwesomeIcons.circleCheck,
                              size: 10,
                              color: Colors.red,
                            );
                          },
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      widget.lastMessage.length < 25
                          ? widget.lastMessage
                          : "${widget.lastMessage.substring(0, 20)}...",
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade400,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
              ),
              child: Text(
                timeago.format(widget.dateSent.toDate()),
                style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  color: Color.fromARGB(255, 115, 128, 148),
                  fontSize: 10,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
