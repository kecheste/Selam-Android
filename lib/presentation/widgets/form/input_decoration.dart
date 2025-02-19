import 'package:flutter/material.dart';

InputDecoration inputDecoration({String? hintText, IconData? icon}) {
  return InputDecoration(
    prefixIcon: Icon(icon, color: Colors.pink.shade300),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(15)),
    hintText: hintText,
    hintStyle: TextStyle(color: Colors.white54),
  );
}
