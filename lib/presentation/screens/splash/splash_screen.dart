import 'package:selam/logic/auth_bloc/auth_bloc.dart';
import 'package:selam/presentation/screens/auth/login.dart';
import 'package:selam/presentation/screens/home/home_page.dart';
import 'package:selam/presentation/widgets/loading/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    context.read<AuthBloc>().add(CheckAuth());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthSuccessState) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        } else if (state is AuthLoggedOutState) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      },
      child: Scaffold(
        backgroundColor: Colors.grey.shade900,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: MediaQuery.sizeOf(context).width * 0.5,
                child: Image.asset('assets/icons/logo.png'),
              ),
              const SizedBox(height: 40),
              const Text(
                "SELAM",
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 50,
                ),
              ),
              const SizedBox(height: 30),
              buildLoadingIndicator(30, Colors.pink.shade600),
            ],
          ),
        ),
      ),
    );
  }
}
