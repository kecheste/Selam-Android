import 'package:selam/core/utils.dart';
import 'package:selam/logic/auth_bloc/auth_bloc.dart';
import 'package:selam/presentation/screens/auth/otp_screens/otp_screen.dart';
import 'package:selam/presentation/widgets/buttons/rectangular_button.dart';
import 'package:selam/presentation/widgets/loading/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_field/intl_phone_field.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String countryCode = "+251";
  bool isPhoneValidated = false;
  bool isLoading = false;
  String errorMsg = "";

  Widget buttonChild = const Text(
    "Next",
    style: TextStyle(
      color: Colors.white,
      fontSize: 18,
      fontWeight: FontWeight.w500,
    ),
  );

  @override
  void dispose() {
    _phoneController.dispose();
    super.dispose();
  }

  void login() async {
    if (_formKey.currentState!.validate() && isPhoneValidated) {
      setState(() {
        isLoading = true;
        buttonChild = buildLoadingIndicator(24, Colors.white);
        errorMsg = "";
      });
      hideKeyboard(context);
      BlocProvider.of<AuthBloc>(context).add(
        SendOtp(countryCode + _phoneController.text, () {
          setState(() {
            isLoading = false;
            errorMsg = "Something went wrong. Try again.";
            buttonChild = const Text(
              "Next",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            );
          });
        }, () {
          setState(() {
            isLoading = false;
            buttonChild = const Text(
              "Next",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            );
          });
          Navigator.of(context).push(MaterialPageRoute(
              builder: (context) =>
                  OtpScreen(phone: countryCode + _phoneController.text)));
        }),
      );
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/images/background.jpg',
              width: double.infinity,
              height: double.infinity,
              fit: BoxFit.cover,
            ),
          ),
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    Colors.black.withOpacity(1),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 80,
            left: 24,
            right: 24,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text(
                  "Inclusive, reliable, safe.",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  "Go beyond your social circle & connect\nwith people near and far.",
                  style: TextStyle(
                    color: Colors.grey.shade400,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 30),
                Form(
                  key: _formKey,
                  child: IntlPhoneField(
                    dropdownIcon: const Icon(
                      Icons.arrow_drop_down,
                      color: Colors.white,
                    ),
                    dropdownTextStyle: TextStyle(color: Colors.grey.shade100),
                    keyboardType: TextInputType.phone,
                    initialCountryCode: 'ET',
                    disableLengthCheck: true,
                    cursorColor: Colors.white,
                    onChanged: (value) {
                      setState(() {
                        countryCode = value.countryCode;
                        isPhoneValidated = value.number.isNotEmpty;
                      });
                    },
                    controller: _phoneController,
                    style: const TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: Colors.grey.withOpacity(0.3),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade500),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.pink.shade400),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      hintText: '000-000-0000',
                      hintStyle: TextStyle(
                        color: Colors.grey.shade400,
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          vertical: 16, horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: rectangularButton(context, buttonChild, login),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
