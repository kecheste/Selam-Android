import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

Widget buildLoadingIndicator(double size, Color color) {
  return Center(
    child: LoadingAnimationWidget.fallingDot(
      color: color,
      size: size,
    ),
  );
}
