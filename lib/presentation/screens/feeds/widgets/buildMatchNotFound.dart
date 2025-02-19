import 'package:selam/logic/matches/matches_bloc.dart';
import 'package:selam/presentation/widgets/buttons/rectangular_button.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:lottie/lottie.dart';

Widget buildMatchNotFound(BuildContext context) {
  return Center(
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Lottie.network(
          'https://assets10.lottiefiles.com/packages/lf20_ikvz7qhc.json',
          height: 200,
        ),
        const SizedBox(height: 20),
        const Text(
          "No Users Available!",
          style: TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        const SizedBox(height: 10),
        const Text(
          "Try refreshing or check back later for new profiles.",
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 14, color: Colors.white70),
        ),
        const SizedBox(height: 20),
        rectangularButton(
          context,
          const Text(
            "Refresh",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          () => context.read<MatchesBloc>().add(GetPossibleMatches()),
        ),
      ],
    ),
  );
}
