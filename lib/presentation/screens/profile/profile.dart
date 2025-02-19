import 'package:selam/logic/auth_bloc/auth_bloc.dart';
import 'package:selam/data/models/user_model.dart';
import 'package:selam/presentation/screens/profile/setting/edit_profile.dart';
import 'package:selam/presentation/screens/profile/setting/add_photos.dart';
import 'package:selam/presentation/widgets/buttons/icon_button.dart';
import 'package:selam/presentation/widgets/buttons/rounded_button.dart';
import 'package:selam/presentation/widgets/loading/loading_indicator.dart';
import 'package:selam/presentation/widgets/popup/premium_popup.dart';
import 'package:selam/presentation/screens/profile/setting/setting.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is AuthSuccessState) {
          final MyUser user = state.user;

          return Container(
            color: Colors.transparent,
            child: Column(
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      height: 250,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          bottomLeft: Radius.circular(50),
                          bottomRight: Radius.circular(50),
                        ),
                      ),
                    ),
                    Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(50)),
                          child: user.profilePicture == ""
                              ? Image.asset(
                                  "assets/icons/user.jpg",
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                )
                              : Image.network(
                                  user.profilePicture!,
                                  width: 100,
                                  height: 100,
                                  fit: BoxFit.cover,
                                ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "${user.name}, ${user.age}",
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        Text(
                          user.bio ?? "No bio",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    iconButton(FontAwesomeIcons.gear, "Settings", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => SettingsScreen(user: user),
                        ),
                      );
                    }, false),
                    const SizedBox(width: 20),
                    iconButton(FontAwesomeIcons.camera, "Add Photos", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => PhotoUploadScreen(
                            user: user,
                          ),
                        ),
                      );
                    }, true),
                    const SizedBox(width: 20),
                    iconButton(FontAwesomeIcons.pen, "Edit Info", () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => EditProfilePage(user: user),
                        ),
                      );
                    }, false),
                  ],
                ),
                const SizedBox(height: 40),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                  margin: const EdgeInsets.symmetric(horizontal: 30),
                  decoration: BoxDecoration(
                    color: Colors.grey[900],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    children: [
                      Row(
                        children: const [
                          Icon(FontAwesomeIcons.bolt,
                              color: Colors.purpleAccent),
                          SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              "Get Matches Faster",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 5),
                      Text(
                        "Boost your profile once a week!",
                        style: TextStyle(color: Colors.grey[400]),
                      ),
                      const SizedBox(height: 15),
                      roundedButton(
                          context,
                          Center(
                            child: Text(
                              "GET SELAM PLUS",
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ), () {
                        showDialog(
                          context: context,
                          builder: (context) => const PremiumPopup(),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          );
        } else {
          // Handle loading or error states if necessary
          return Center(child: buildLoadingIndicator(40, Colors.pink.shade600));
        }
      },
    );
  }
}
