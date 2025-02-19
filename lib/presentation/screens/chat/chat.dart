import 'package:selam/data/models/user_model.dart';
import 'package:selam/data/repositories/auth.dart';
import 'package:selam/data/repositories/chat.dart';
import 'package:selam/data/repositories/user.dart';
import 'package:selam/presentation/screens/chat/tiles/chatroom_tile.dart';
import 'package:selam/presentation/screens/chat/tiles/favorites_tile.dart';
import 'package:selam/presentation/widgets/loading/loading_indicator.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ChatPage extends StatefulWidget {
  final MyUser user;
  const ChatPage({super.key, required this.user});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final ChatRepository chatRepository = ChatRepository();
  final UserRepository userRepository = UserRepository();
  final AuthRepository authRepository = AuthRepository();

  Stream? chatRoomStream;
  Stream? favoriteStream;

  @override
  void initState() {
    super.initState();
    _loadStreams();
  }

  void _loadStreams() async {
    chatRoomStream = await chatRepository.getChatRooms();
    favoriteStream = await userRepository.getFavoriteSenders();
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          const SizedBox(height: 10),
          _buildSearchBox(),
          const SizedBox(height: 15),
          _buildTabBar(),
          const SizedBox(height: 15),
          Expanded(
            child: TabBarView(
              children: [
                _buildChatList(),
                _buildFavoriteList(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBox() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.grey.shade800,
        borderRadius: BorderRadius.circular(30),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: TextField(
        decoration: InputDecoration(
          hintText: "Search...",
          hintStyle: TextStyle(color: Colors.grey.shade400),
          border: InputBorder.none,
          icon: Icon(FontAwesomeIcons.magnifyingGlass,
              size: 20, color: Colors.grey.shade400),
        ),
        style: TextStyle(color: Colors.white),
        cursorColor: Colors.pinkAccent,
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.transparent,
      ),
      child: TabBar(
        indicatorSize: TabBarIndicatorSize.tab,
        unselectedLabelColor: Colors.grey.shade400,
        labelColor: Colors.pinkAccent,
        indicator: BoxDecoration(
          color: Colors.transparent,
        ),
        labelPadding: const EdgeInsets.symmetric(vertical: 10),
        tabs: const [
          Text("Messages",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          Text("Likes",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildChatList() {
    return StreamBuilder(
      stream: chatRoomStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return buildLoadingIndicator(50, Colors.pink.shade600);
        }
        List<DocumentSnapshot> docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemBuilder: (context, index) {
            DocumentSnapshot ds = docs[index];
            return ChatroomTile(
              chatRoomId: ds.id,
              dateSent: ds["dateSent"],
              lastMessage: ds['lastMessage'],
              user: widget.user,
            );
          },
          itemCount: docs.length,
        );
      },
    );
  }

  Widget _buildFavoriteList() {
    return StreamBuilder(
      stream: favoriteStream,
      builder: (context, AsyncSnapshot snapshot) {
        if (!snapshot.hasData) {
          return buildLoadingIndicator(50, Colors.pink.shade600);
        }
        List<DocumentSnapshot> docs = snapshot.data!.docs;
        return ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          itemBuilder: (context, index) {
            DocumentSnapshot ds = docs[index];
            return FavoriteTile(
              opponentId: ds.id,
            );
          },
          itemCount: docs.length,
        );
      },
    );
  }
}
