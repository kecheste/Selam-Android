import 'package:selam/config/app_config.dart';
import 'package:selam/config/routes.dart';
import 'package:selam/core/theme.dart';
import 'package:selam/data/repositories/match.dart';
import 'package:selam/logic/auth_bloc/auth_bloc.dart';
import 'package:selam/logic/matches/matches_bloc.dart';
import 'package:selam/config/firebase_options.dart';
import 'package:selam/data/repositories/auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/services.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
  ]);
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await Permission.notification.isDenied.then((value) {
    if (value) {
      Permission.notification.request();
    }
  });
  runApp(
    MultiBlocProvider(
      providers: [
        BlocProvider<AuthBloc>(
          create: (context) => AuthBloc(authRepository: AuthRepository()),
        ),
        BlocProvider<MatchesBloc>(
          create: (context) => MatchesBloc(matchRepository: MatchRepository()),
        )
      ],
      child: MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppConfig.appName,
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      theme: AppTheme.darkTheme(context),
      routes: routes,
    );
  }
}
