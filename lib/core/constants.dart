import 'package:flutter/material.dart';

const kPrimaryColor = Color.fromARGB(255, 255, 255, 255);
const kPrimaryLightColor = Color(0xFFFFECDF);
const kPrimaryGradientColor = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color.fromARGB(255, 132, 2, 102), Color.fromARGB(255, 247, 0, 160)],
);
const kSecondaryColor = Color.fromARGB(255, 255, 255, 255);
const kTextColor = Color.fromARGB(255, 255, 255, 255);
const kOutlineInputBorderColor = Color.fromARGB(255, 100, 100, 100);

const kAnimationDuration = Duration(milliseconds: 200);

const headingStyle = TextStyle(
  fontSize: 24,
  fontWeight: FontWeight.bold,
  color: Color.fromARGB(255, 255, 255, 255),
  height: 1.5,
);

const defaultDuration = Duration(milliseconds: 250);

const String kNamelNullError = "Please Enter your name";
const String kPhoneNumberNullError = "Please Enter your phone number";

final otpInputDecoration = InputDecoration(
  contentPadding: const EdgeInsets.symmetric(vertical: 16),
  border: outlineInputBorder(),
  focusedBorder: outlineInputBorder(),
  enabledBorder: outlineInputBorder(),
);

OutlineInputBorder outlineInputBorder() {
  return OutlineInputBorder(
    borderRadius: BorderRadius.circular(16),
    borderSide: const BorderSide(color: kOutlineInputBorderColor),
  );
}
