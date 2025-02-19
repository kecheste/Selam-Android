import 'package:flutter/material.dart';

Widget rectangularButton(
    BuildContext context, Widget child, Function() onPressed) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      padding: const EdgeInsets.symmetric(vertical: 16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      backgroundColor: const Color.fromRGBO(236, 64, 122, 1),
      disabledBackgroundColor: Colors.grey.shade800,
    ),
    onPressed: onPressed,
    child: child,
  );
}
