import 'dart:ui';

import 'package:selam/logic/matches/matches_bloc.dart';
import 'package:selam/data/repositories/user.dart';
import 'package:selam/presentation/screens/feeds/widgets/buildGestureDetectors.dart';
import 'package:selam/presentation/screens/feeds/widgets/buildMatchNotFound.dart';
import 'package:selam/presentation/screens/feeds/widgets/details_view.dart';
import 'package:selam/presentation/widgets/loading/loading_indicator.dart';
import 'package:selam/presentation/widgets/popup/super_like_popup.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class FeedsPage extends StatefulWidget {
  const FeedsPage({super.key});

  @override
  State<FeedsPage> createState() => _FeedsPageState();
}

class _FeedsPageState extends State<FeedsPage> with TickerProviderStateMixin {
  final PageController _pageController = PageController();
  final UserRepository userRepository = UserRepository();
  final int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    context.read<MatchesBloc>().add(GetPossibleMatches());
  }

  void _nextMatch() {
    if (_pageController.hasClients) {
      _pageController.nextPage(
          duration: const Duration(milliseconds: 500), curve: Curves.easeInOut);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MatchesBloc, MatchesState>(
      builder: (context, state) {
        if (state is MatchLoadingState) {
          return Center(child: buildLoadingIndicator(40, Colors.pink.shade600));
        } else if (state is MatchSuccessState) {
          if (state.matches.isEmpty) {
            return buildMatchNotFound(context);
          }
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: BlocListener<MatchesBloc, MatchesState>(
              listener: (context, state) {
                if (state is MatchSuccessState) {
                  _pageController.jumpToPage(0);
                }
              },
              child: PageView.builder(
                controller: _pageController,
                itemCount: state.matches.length,
                physics: const BouncingScrollPhysics(),
                itemBuilder: (context, index) {
                  final match = state.matches[index];

                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: 1,
                    child: Card(
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      elevation: 8,
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: GestureDetector(
                              onTap: () {
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) =>
                                        DetailsView(opponentId: match.id)));
                              },
                              child: CarouselSlider(
                                options: CarouselOptions(
                                  height: double.infinity,
                                  viewportFraction: 1.0,
                                  enlargeCenterPage: false,
                                ),
                                items: match.images?.map((imgUrl) {
                                      return Image.network(
                                        imgUrl,
                                        fit: BoxFit.cover,
                                      );
                                    }).toList() ??
                                    [
                                      Image.network(
                                        'https://via.placeholder.com/400',
                                        fit: BoxFit.cover,
                                      )
                                    ],
                              ),
                            ),
                          ),
                          Positioned(
                            top: MediaQuery.of(context).size.height * 0.5,
                            left: 0,
                            right: 0,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children:
                                  match.images?.asMap().entries.map((entry) {
                                        return Container(
                                          width: _currentImageIndex == entry.key
                                              ? 20
                                              : 8,
                                          height: 8,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 3.0),
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5.0),
                                            color:
                                                _currentImageIndex == entry.key
                                                    ? Colors.white
                                                    : const Color.fromARGB(
                                                        255, 186, 186, 186),
                                          ),
                                        );
                                      }).toList() ??
                                      [],
                            ),
                          ),
                          Positioned(
                              right: 0,
                              left: 0,
                              bottom: 0,
                              child: Container(
                                padding: const EdgeInsets.all(20),
                                decoration: BoxDecoration(
                                  gradient: LinearGradient(
                                    begin: Alignment.bottomCenter,
                                    end: Alignment.topCenter,
                                    colors: [
                                      Colors.black.withOpacity(0.8),
                                      Colors.transparent
                                    ],
                                  ),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "${match.name.split(" ")[0]}, ${match.age}",
                                      style: const TextStyle(
                                        fontSize: 30,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 3),
                                    SizedBox(
                                      width: (match.location?.length ?? 0) *
                                          13 /
                                          1.5,
                                      child: ClipRRect(
                                        borderRadius: BorderRadius.circular(20),
                                        child: BackdropFilter(
                                          filter: ImageFilter.blur(
                                              sigmaX: 10.0, sigmaY: 10.0),
                                          child: Container(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            decoration: BoxDecoration(
                                              color:
                                                  Colors.white.withOpacity(0.2),
                                              borderRadius:
                                                  BorderRadius.circular(20),
                                            ),
                                            child: Row(
                                              children: [
                                                const Icon(Icons.location_on,
                                                    color: Colors.white,
                                                    size: 18),
                                                const SizedBox(width: 5),
                                                Text(
                                                  match.location ?? "Unknown",
                                                  style: const TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 13),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 20),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceEvenly,
                                      children: [
                                        buildGestureDetectors(
                                            context,
                                            _nextMatch,
                                            FontAwesomeIcons.xmark,
                                            Colors.white,
                                            Colors.red,
                                            Colors.red,
                                            15),
                                        buildGestureDetectors(context,
                                            () async {
                                          await userRepository
                                              .sendFavorite(match.id);
                                          _nextMatch();
                                        }, FontAwesomeIcons.heart, Colors.pink,
                                            Colors.pink, Colors.white, 20),
                                        buildGestureDetectors(context, () {
                                          showDialog(
                                              context: context,
                                              builder: (context) =>
                                                  const SuperLikePopup());
                                        },
                                            FontAwesomeIcons.solidStar,
                                            Colors.white,
                                            Colors.blue,
                                            Colors.blue,
                                            15),
                                      ],
                                    ),
                                  ],
                                ),
                              )),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          );
        }
        return Center(child: buildLoadingIndicator(40, Colors.pink.shade600));
      },
    );
  }
}
