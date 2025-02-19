import 'package:selam/presentation/screens/auth/login.dart';
import 'package:selam/presentation/screens/home/home_page.dart';
import 'package:selam/presentation/screens/profile/profile.dart';
import 'package:selam/presentation/screens/splash/splash_screen.dart';
import 'package:flutter/material.dart';

final Map<String, WidgetBuilder> routes = {
  '/splash': (context) => SplashScreen(),
  '/login': (context) => LoginPage(),
  '/home': (context) => HomePage(),
  '/profile': (context) => ProfilePage(),
};
