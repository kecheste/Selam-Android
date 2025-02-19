import 'package:selam/data/models/user_model.dart';
import 'package:selam/data/repositories/user.dart';
import 'package:flutter/material.dart';

void unmatchUser(BuildContext context, MyUser match) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text(
        "Unmatch ${match.name.split(" ")[0]}?",
        style: TextStyle(color: Colors.white),
      ),
      content: Text(
        "Are you sure you want to remove this match?",
        style: TextStyle(color: Colors.grey[100]),
      ),
      actions: [
        TextButton(
          child: const Text("Cancel"),
          onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: const Text("Unmatch", style: TextStyle(color: Colors.red)),
          onPressed: () {
            UserRepository().sendFavorite(match.id);
            Navigator.pop(context);
          },
        ),
      ],
    ),
  );
}
