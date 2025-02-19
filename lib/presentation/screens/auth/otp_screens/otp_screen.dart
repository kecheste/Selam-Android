import 'package:selam/presentation/screens/auth/otp_screens/widgets/otp_form.dart';
import 'package:flutter/material.dart';

class OtpScreen extends StatelessWidget {
  static String routeName = "/otp";

  final String phone;

  const OtpScreen({super.key, required this.phone});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade900,
      appBar: AppBar(
        backgroundColor: Colors.grey.shade900,
        elevation: 0,
      ),
      body: SizedBox(
        width: double.infinity,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 16),
                const Text(
                  "OTP Verification",
                  style: TextStyle(
                      color: Colors.pinkAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 30),
                ),
                Text(
                  "We sent your code to $phone",
                  style: TextStyle(color: Colors.grey.shade300),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "This code will expired in ",
                      style: TextStyle(color: Colors.grey[300]),
                    ),
                    TweenAnimationBuilder(
                      tween: Tween(begin: 60.0, end: 0.0),
                      duration: const Duration(seconds: 60),
                      onEnd: () {
                        Navigator.pop(context);
                      },
                      builder: (_, dynamic value, child) => Text(
                        "00:${value.toInt()}",
                        style: const TextStyle(color: Colors.pinkAccent),
                      ),
                    ),
                  ],
                ),
                OtpForm(phone: phone),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
