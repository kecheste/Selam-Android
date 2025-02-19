import 'package:selam/data/models/user_model.dart';
import 'package:selam/data/repositories/user.dart';
import 'package:selam/presentation/widgets/buttons/rectangular_button.dart';
import 'package:selam/presentation/widgets/loading/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class EditProfilePage extends StatefulWidget {
  final MyUser user;

  const EditProfilePage({super.key, required this.user});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final UserRepository userRepository = UserRepository();
  late final TextEditingController _nameController;
  late final TextEditingController _bioController;
  late final TextEditingController _jobController;
  late List<String> newInterest;
  Widget buttonChild = const Text(
    "Save",
    style: TextStyle(
        fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
  );

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

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _bioController = TextEditingController(text: widget.user.bio ?? '');
    _jobController = TextEditingController(text: widget.user.jobTitle ?? '');
    newInterest = List<String>.from(widget.user.interestedIn ?? []);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _bioController.dispose();
    _jobController.dispose();
    super.dispose();
  }

  void saveProfile() async {
    setState(() {
      buttonChild = buildLoadingIndicator(24, Colors.white);
    });

    await userRepository.updateName(_nameController.text, widget.user.id);
    await userRepository.updateBio(_bioController.text, widget.user.id);
    await userRepository.updateInterests(newInterest, widget.user.id);
    await userRepository.updateJob(_jobController.text, widget.user.id);

    setState(() {
      buttonChild = const Text(
        "Save",
        style: TextStyle(
            fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("Edit Profile",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        centerTitle: true,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(FontAwesomeIcons.arrowLeft, color: Colors.white),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField("Full Name", _nameController),
              _buildTextField("Bio", _bioController, maxLines: 3),
              _buildTextField("Job Title", _jobController),
              const SizedBox(height: 15),
              const Text("Select Your Interests",
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildInterestChips(),
              const SizedBox(height: 20),
              rectangularButton(
                context,
                buttonChild,
                saveProfile,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(String label, TextEditingController controller,
      {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: TextField(
        controller: controller,
        style: const TextStyle(color: Colors.white, fontSize: 16),
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          filled: true,
          fillColor: Colors.grey.shade900,
          border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: BorderSide.none),
          focusedBorder: OutlineInputBorder(
              borderSide: const BorderSide(color: Colors.pinkAccent),
              borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }

  Widget _buildInterestChips() {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: interests.map((interest) {
        final isSelected = newInterest.contains(interest["name"]);
        return GestureDetector(
          onTap: () {
            setState(() {
              isSelected
                  ? newInterest.remove(interest["name"])
                  : newInterest.add(interest["name"]);
            });
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: isSelected ? Colors.pinkAccent : Colors.grey.shade800,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(interest["icon"], color: Colors.white, size: 18),
                const SizedBox(width: 6),
                Text(
                  interest["name"],
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
