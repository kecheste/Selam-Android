import 'package:selam/data/models/user_model.dart';
import 'package:selam/data/repositories/auth.dart';
import 'package:selam/presentation/screens/feeds/widgets/details_view.dart';
import 'package:flutter/material.dart';

class FavoriteTile extends StatefulWidget {
  final String opponentId;

  const FavoriteTile({super.key, required this.opponentId});

  @override
  State<FavoriteTile> createState() => _FavoriteTileState();
}

class _FavoriteTileState extends State<FavoriteTile> {
  final AuthRepository authRepository = AuthRepository();
  MyUser liker = MyUser.empty;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
  }

  Future<void> _fetchUserInfo() async {
    MyUser likeUser = await authRepository.getMyUser(widget.opponentId);
    setState(() {
      liker = likeUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DetailsView(
              opponentId: widget.opponentId,
            ),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
        padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(50),
                  child: liker.profilePicture?.isNotEmpty == true
                      ? Image.network(
                          liker.profilePicture!,
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                        )
                      : Image.asset(
                          'assets/icons/user1.png',
                          height: 40,
                          width: 40,
                          fit: BoxFit.cover,
                        ),
                ),
              ],
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                "${liker.name} liked you.",
                style: const TextStyle(
                  color: Color.fromARGB(255, 238, 238, 238),
                  fontSize: 15,
                  fontWeight: FontWeight.w300,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
