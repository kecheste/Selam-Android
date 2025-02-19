import 'package:selam/data/models/user_model.dart';
import 'package:selam/data/repositories/auth.dart';
import 'package:selam/data/repositories/user.dart';
import 'package:selam/presentation/screens/home/home_page.dart';
import 'package:selam/presentation/widgets/loading/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UpdateExtraInfo extends StatefulWidget {
  final MyUser user;

  const UpdateExtraInfo({super.key, required this.user});

  @override
  State<UpdateExtraInfo> createState() => _UpdateExtraInfoState();
}

class _UpdateExtraInfoState extends State<UpdateExtraInfo> {
  final AuthRepository authRepository = AuthRepository();
  final UserRepository userRepository = UserRepository();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  String bio = '';
  bool isLoading = false;
  String errorMessage = '';

  final List<Map<String, dynamic>> interests = [
    {"name": "Art", "icon": FontAwesomeIcons.palette},
    {"name": "Travel", "icon": FontAwesomeIcons.plane},
    {"name": "Food", "icon": FontAwesomeIcons.utensils},
    {"name": "Movies", "icon": FontAwesomeIcons.film},
    {"name": "Music", "icon": FontAwesomeIcons.music},
    {"name": "Sports", "icon": FontAwesomeIcons.personRunning},
    {"name": "Hiking", "icon": FontAwesomeIcons.personHiking},
    {"name": "Gym", "icon": FontAwesomeIcons.dumbbell},
    {"name": "Yoga", "icon": FontAwesomeIcons.spa},
    {"name": "Fashion", "icon": FontAwesomeIcons.shirt},
    {"name": "Games", "icon": FontAwesomeIcons.gamepad},
    {"name": "Culture", "icon": FontAwesomeIcons.globe},
    {"name": "Love", "icon": FontAwesomeIcons.heart},
    {"name": "Romance", "icon": FontAwesomeIcons.faceKissWinkHeart},
  ];

  List<String> selectedInterests = [];

  @override
  void initState() {
    super.initState();
    selectedInterests = (widget.user.interestedIn ?? []).cast<String>();
    bio = widget.user.bio ?? '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Personalize Your Profile",
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "Tell us about yourself and your interests!",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 30),
                Container(
                  padding: EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Your Bio",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 8),
                      TextFormField(
                        style: TextStyle(color: Colors.white),
                        initialValue: bio,
                        maxLines: 3,
                        decoration: InputDecoration(
                          hintText: "Write something about yourself...",
                          hintStyle: TextStyle(color: Colors.grey.shade500),
                          border: InputBorder.none,
                        ),
                        onChanged: (value) => setState(() => bio = value),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your bio';
                          }
                          return null;
                        },
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 25),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Select Your Interests",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
                SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: interests.map((interest) {
                    bool isSelected =
                        selectedInterests.contains(interest["name"]);
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          if (isSelected) {
                            selectedInterests.remove(interest["name"]);
                          } else {
                            selectedInterests.add(interest["name"]);
                          }
                        });
                      },
                      child: Container(
                        padding:
                            EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.pink.shade400
                              : Colors.grey.shade800,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected
                              ? [
                                  BoxShadow(
                                    color: Colors.pink.withOpacity(0.4),
                                    blurRadius: 10,
                                    spreadRadius: 2,
                                    offset: Offset(0, 3),
                                  ),
                                ]
                              : [],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              interest["icon"],
                              size: 14,
                              color: Colors.white,
                            ),
                            SizedBox(width: 8),
                            Text(
                              interest["name"],
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                SizedBox(height: 40),
                GestureDetector(
                  onTap: isLoading
                      ? null
                      : () async {
                          if (_formKey.currentState!.validate()) {
                            setState(() => isLoading = true);
                            try {
                              await userRepository.updateBio(
                                  bio, widget.user.id);
                              await userRepository.updateInterests(
                                  selectedInterests, widget.user.id);
                              if (mounted) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => HomePage(),
                                  ),
                                );
                              }
                            } catch (e) {
                              setState(() => errorMessage = e.toString());
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(errorMessage),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            } finally {
                              if (mounted) {
                                setState(() => isLoading = false);
                              }
                            }
                          }
                        },
                  child: AnimatedContainer(
                    duration: Duration(milliseconds: 300),
                    padding: EdgeInsets.symmetric(vertical: 15),
                    width: double.infinity,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(15),
                      gradient: LinearGradient(
                        colors: isLoading
                            ? [Colors.grey.shade600, Colors.grey.shade600]
                            : [Colors.pink, Colors.pink.shade700],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      boxShadow: isLoading
                          ? []
                          : [
                              BoxShadow(
                                color: Colors.pink.withOpacity(0.4),
                                blurRadius: 10,
                                spreadRadius: 2,
                                offset: Offset(0, 3),
                              ),
                            ],
                    ),
                    child: Center(
                      child: isLoading
                          ? buildLoadingIndicator(24, Colors.white)
                          : Text(
                              "Save & Continue",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
