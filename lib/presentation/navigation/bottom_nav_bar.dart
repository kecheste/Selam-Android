import 'package:crystal_navigation_bar/crystal_navigation_bar.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

Widget bottomNavBar(BuildContext context, int selected, Function(int) onTap) {
  return CrystalNavigationBar(
    marginR: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
    currentIndex: selected,
    indicatorColor: Colors.transparent,
    backgroundColor: Colors.grey[850]!,
    outlineBorderColor: Colors.transparent,
    splashColor: Colors.transparent,
    borderRadius: 20,
    onTap: onTap,
    items: [
      CrystalNavigationBarItem(
        icon: FontAwesomeIcons.solidClone,
        selectedColor: Colors.pinkAccent,
        unselectedColor: Colors.grey[400],
        unselectedIcon: FontAwesomeIcons.clone,
      ),
      CrystalNavigationBarItem(
        icon: FontAwesomeIcons.solidHeart,
        selectedColor: Colors.pinkAccent,
        unselectedColor: Colors.grey[400],
        unselectedIcon: FontAwesomeIcons.heart,
      ),
      CrystalNavigationBarItem(
        icon: FontAwesomeIcons.solidComments,
        selectedColor: Colors.pinkAccent,
        unselectedColor: Colors.grey[400],
        unselectedIcon: FontAwesomeIcons.comments,
      ),
      CrystalNavigationBarItem(
        icon: FontAwesomeIcons.solidUser,
        selectedColor: Colors.pinkAccent,
        unselectedColor: Colors.grey[400],
        unselectedIcon: FontAwesomeIcons.user,
      ),
    ],
  );
}
