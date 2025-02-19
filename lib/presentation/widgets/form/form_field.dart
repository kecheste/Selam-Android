import 'package:flutter/material.dart';

Widget buildFormField({required String label, required Widget field}) {
  return Padding(
    padding: const EdgeInsets.symmetric(vertical: 10),
    child: field,
  );
}
