import 'package:flutter/material.dart';

Widget buildGestureDetectors(
    BuildContext context,
    Function ontap,
    IconData icon,
    Color color,
    Color shadowColor,
    Color iconColor,
    double size) {
  return GestureDetector(
    onTap: () => ontap(),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: EdgeInsets.all(size),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        boxShadow: [
          BoxShadow(
            color: shadowColor.withOpacity(0.4),
            blurRadius: 10,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Icon(
        icon,
        color: iconColor,
        size: 20,
      ),
    ),
  );
}
