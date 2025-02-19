import 'package:selam/logic/matches/matches_bloc.dart';
import 'package:selam/data/models/user_model.dart';
import 'package:selam/data/repositories/auth.dart';
import 'package:selam/data/repositories/chat.dart';
import 'package:selam/data/repositories/user.dart';
import 'package:selam/presentation/screens/chat/widgets/chatroom.dart';
import 'package:selam/core/utils.dart';
import 'package:selam/presentation/screens/matches/widget/no_match_error.dart';
import 'package:selam/presentation/screens/matches/widget/unmatch_user_dialog.dart';
import 'package:selam/presentation/widgets/loading/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class MatchesPage extends StatefulWidget {
  const MatchesPage({super.key, required this.user});
  final MyUser user;

  @override
  State<MatchesPage> createState() => _MatchesPageState();
}

class _MatchesPageState extends State<MatchesPage> {
  final AuthRepository authRepository = AuthRepository();
  final ChatRepository chatRepository = ChatRepository();
  final UserRepository userRepository = UserRepository();

  @override
  void initState() {
    super.initState();
    context.read<MatchesBloc>().add(GetMatches());
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      child: BlocBuilder<MatchesBloc, MatchesState>(
        builder: (context, state) {
          if (state is MatchSuccessState) {
            if (state.matches.isEmpty) {
              return noMatchError(context);
            }

            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: state.matches.length,
              itemBuilder: (context, index) {
                final match = state.matches[index];

                return Card(
                  color: Colors.grey[900],
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    contentPadding: const EdgeInsets.all(10),
                    leading: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        match.profilePicture!,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                      ),
                    ),
                    title: Text(
                      "${match.name.split(" ")[0]}, ${match.age}",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(FontAwesomeIcons.locationDot,
                                size: 14, color: Colors.grey),
                            const SizedBox(width: 4),
                            Text(
                              match.location?.split(',')[0] ?? "",
                              style: TextStyle(
                                  fontSize: 14, color: Colors.grey.shade400),
                            ),
                          ],
                        ),
                        Padding(
                          padding: const EdgeInsets.only(left: 2.0),
                          child: StreamBuilder(
                            stream: authRepository.usersCollection
                                .doc(match.id)
                                .snapshots(),
                            builder: (context, snapshot) {
                              final isOnline =
                                  snapshot.data?["isOnline"] ?? false;
                              return Row(
                                children: [
                                  Icon(FontAwesomeIcons.circleCheck,
                                      size: 10,
                                      color:
                                          isOnline ? Colors.green : Colors.red),
                                  const SizedBox(width: 4),
                                  Text(
                                    isOnline ? "Online" : "Offline",
                                    style: TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey.shade500),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(FontAwesomeIcons.solidCommentDots,
                              color: Colors.grey.shade200),
                          onPressed: () async {
                            var chatRoomId = getChatRoomIdByUsername(
                                match.id, widget.user.id);
                            Map<String, dynamic> chatRoomInfoMap = {
                              "users": [match.id, widget.user.id]
                            };
                            await chatRepository.createChatRoom(
                                chatRoomId, chatRoomInfoMap);
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ChatRoom(
                                  user: widget.user,
                                  chatOponent: match,
                                  chatRoomId: chatRoomId,
                                ),
                              ),
                            );
                          },
                        ),
                        IconButton(
                          icon: const Icon(
                            FontAwesomeIcons.xmark,
                            color: Colors.red,
                          ),
                          onPressed: () => unmatchUser(context, match),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
          return Center(child: buildLoadingIndicator(40, Colors.pink.shade600));
        },
      ),
    );
  }
}
