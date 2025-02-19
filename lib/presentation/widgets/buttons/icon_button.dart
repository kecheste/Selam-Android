import 'package:flutter/material.dart';

Widget iconButton(IconData icon, String text, Function onClick, bool primary) {
  return Column(
    children: [
      CircleAvatar(
        radius: 25,
        backgroundColor: primary ? Colors.pinkAccent : Colors.grey[800],
        child: IconButton(
          icon: Icon(icon, color: Colors.white, size: 22),
          onPressed: () => onClick(),
        ),
      ),
      const SizedBox(height: 5),
      Text(
        text,
        style: TextStyle(color: Colors.white, fontSize: 14),
      ),
    ],
  );
}
