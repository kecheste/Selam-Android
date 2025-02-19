import 'package:selam/logic/matches/matches_bloc.dart';
import 'package:selam/presentation/widgets/buttons/rectangular_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

Widget noMatchError(BuildContext context) {
  return Column(
    mainAxisAlignment: MainAxisAlignment.center,
    crossAxisAlignment: CrossAxisAlignment.center,
    children: [
      SizedBox(
        height: 200,
        child: Lottie.network(
          'https://assets9.lottiefiles.com/packages/lf20_pNx6yH.json',
          height: 200,
        ),
      ),
      const SizedBox(height: 20),
      const Text(
        "No Matches Yet 🥺",
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      const SizedBox(height: 10),
      const Padding(
        padding: EdgeInsets.symmetric(horizontal: 30),
        child: Text(
          "Don't worry! Keep swiping and your perfect match could be just around the corner. 💖",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ),
      const SizedBox(height: 20),
      rectangularButton(
        context,
        const Text("Find New Matches 💘",
            style: TextStyle(fontSize: 16, color: Colors.white)),
        () => context.read<MatchesBloc>().add(GetMatches()),
      ),
    ],
  );
}
