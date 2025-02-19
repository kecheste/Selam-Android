import 'package:selam/data/repositories/user.dart';
import 'package:selam/logic/auth_bloc/auth_bloc.dart';
import 'package:selam/notifications/notification_system.dart';
import 'package:selam/data/repositories/auth.dart';
import 'package:selam/core/utils.dart';
import 'package:selam/presentation/navigation/bottom_nav_bar.dart';
import 'package:selam/presentation/screens/auth/complete_profile/add_images.dart';
import 'package:selam/presentation/screens/auth/complete_profile/update_extra_info.dart';
import 'package:selam/presentation/screens/auth/complete_profile/update_info.dart';
import 'package:selam/presentation/widgets/loading/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:selam/data/models/user_model.dart';
import 'package:selam/presentation/screens/chat/chat.dart';
import 'package:selam/presentation/screens/feeds/feeds.dart';
import 'package:selam/presentation/screens/matches/matches.dart';
import 'package:selam/presentation/screens/profile/profile.dart';
import 'package:selam/presentation/screens/auth/login.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geocoding/geocoding.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> with WidgetsBindingObserver {
  final AuthRepository authRepository = AuthRepository();
  final UserRepository userRepository = UserRepository();

  bool status = false;
  int selected = 0;
  bool _isMounted = true;

  @override
  void initState() {
    WidgetsBinding.instance.addObserver(this);
    super.initState();

    updateLocationData();
    PushNotoficationSystem notificationSystem = PushNotoficationSystem();
    notificationSystem.generateFCMToken();
    notificationSystem.notificationReceived(context);
  }

  @override
  void dispose() {
    _isMounted = false;
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void updateLocationData() async {
    final Placemark? location = await getLocation();
    if (location != null) {
      MyUser? currentUser = _getCurrentUser();
      if (currentUser != null) {
        await userRepository.updateLocation(
            "${location.administrativeArea!}, ${location.country}",
            currentUser.id);
      }
    }
  }

  MyUser? _getCurrentUser() {
    final state = context.read<AuthBloc>().state;
    if (state is AuthSuccessState) {
      return state.user;
    }
    return null;
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (!_isMounted) return;

    MyUser? currentUser = _getCurrentUser();
    if (currentUser == null) return;

    if (state == AppLifecycleState.resumed) {
      status = true;
    } else {
      status = false;
    }

    userRepository.updateStatus(status, currentUser.id);
  }

  void _navigateToNextScreen(BuildContext context, MyUser user) {
    if (user.name == "" ||
        user.dob == null ||
        user.gender == "" ||
        user.age == "") {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UpdateInfo(user: user)),
      );
    } else if (user.bio == "" || user.interestedIn!.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => UpdateExtraInfo(user: user)),
      );
    } else if (user.profilePicture == "" || user.images!.isEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => AddImagesScreen(user: user)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthLoggedOutState) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => LoginPage()),
          );
        }
      },
      child: BlocBuilder<AuthBloc, AuthState>(
        builder: (context, state) {
          if (state is AuthLoadingState) {
            return Scaffold(
              body: Center(
                child: buildLoadingIndicator(20, Colors.pink.shade600),
              ),
            );
          } else if (state is AuthFailureState) {
            return Scaffold(
              body: Center(child: Text("Error: ${state.errorMessage}")),
            );
          } else if (state is AuthSuccessState) {
            _navigateToNextScreen(context, state.user);

            MyUser user = state.user;
            List<Widget> screens = [
              FeedsPage(),
              MatchesPage(user: user),
              ChatPage(user: user),
              ProfilePage(),
            ];

            return Scaffold(
              backgroundColor: const Color.fromARGB(137, 31, 31, 31),
              appBar: AppBar(
                title: Text(
                  _getAppBarTitle(selected),
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.bold),
                ),
                backgroundColor: Colors.transparent,
                elevation: 0,
                centerTitle: true,
              ),
              body: screens[selected],
              bottomNavigationBar: SizedBox(
                width: MediaQuery.of(context).size.width,
                child: bottomNavBar(context, selected, (index) {
                  setState(() {
                    selected = index;
                  });
                }),
              ),
            );
          }
          return const Scaffold(
            body: Center(child: Text("Unexpected state")),
          );
        },
      ),
    );
  }

  String _getAppBarTitle(int index) {
    switch (index) {
      case 0:
        return 'Discover';
      case 1:
        return 'Matches';
      case 2:
        return 'Chats';
      case 3:
        return 'Profile';
      default:
        return 'Home';
    }
  }
}
