import 'dart:ui';
import 'package:selam/data/models/user_model.dart';
import 'package:selam/data/repositories/chat.dart';
import 'package:selam/data/repositories/user.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:carousel_slider/carousel_slider.dart';

class DetailsView extends StatefulWidget {
  const DetailsView({super.key, required this.opponentId});

  final String opponentId;

  @override
  State<DetailsView> createState() => _DetailsViewState();
}

class _DetailsViewState extends State<DetailsView> {
  final UserRepository userRepository = UserRepository();
  final ChatRepository chatRepository = ChatRepository();
  int _currentImageIndex = 0;
  final CarouselSliderController _carouselController =
      CarouselSliderController();

  MyUser? opponent;

  @override
  void initState() {
    super.initState();
    _fetchOpponent();
  }

  void _fetchOpponent() async {
    final fetchedUser = await userRepository.getUserById(widget.opponentId);
    setState(() {
      opponent = fetchedUser;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (opponent == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: GestureDetector(
        onHorizontalDragEnd: (details) {
          if (details.primaryVelocity! < 0) {
            _carouselController.nextPage();
          } else if (details.primaryVelocity! > 0) {
            _carouselController.previousPage();
          }
        },
        child: Stack(
          children: [
            Positioned.fill(
              child: CarouselSlider(
                carouselController: _carouselController,
                options: CarouselOptions(
                  height: double.infinity,
                  viewportFraction: 1.0,
                  enableInfiniteScroll: true,
                  onPageChanged: (index, reason) {
                    setState(() {
                      _currentImageIndex = index;
                    });
                  },
                ),
                items: opponent!.images?.map((photoUrl) {
                      return Image.network(
                        photoUrl,
                        fit: BoxFit.cover,
                      );
                    }).toList() ??
                    [],
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).size.height * 0.65,
              left: 0,
              right: 0,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: opponent!.images?.asMap().entries.map((entry) {
                      return Container(
                        width: _currentImageIndex == entry.key ? 20 : 8,
                        height: 8,
                        margin: const EdgeInsets.symmetric(horizontal: 3.0),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5.0),
                          color: _currentImageIndex == entry.key
                              ? Colors.white
                              : const Color.fromARGB(255, 186, 186, 186),
                        ),
                      );
                    }).toList() ??
                    [],
              ),
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [Colors.black.withOpacity(0.8), Colors.transparent],
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "${opponent!.name.split(" ")[0]}\n${opponent!.name.split(" ")[1]}, ${opponent!.age}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                              ),
                            )
                          ],
                        ),
                        GestureDetector(
                          onTap: () {},
                          child: Container(
                            height: 60,
                            width: 60,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color.fromARGB(255, 43, 43, 43)
                                  .withOpacity(0.4),
                              border: Border.all(color: Colors.red, width: 2),
                            ),
                            child: const Icon(
                              FontAwesomeIcons.solidHeart,
                              color: Colors.red,
                              size: 28,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Icon(FontAwesomeIcons.locationDot,
                            color: Colors.grey.shade300, size: 16),
                        const SizedBox(width: 5),
                        Text(
                          opponent!.location ?? "Unknown",
                          style: TextStyle(color: Colors.grey.shade300),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: opponent!.interestedIn?.map((interest) {
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: BackdropFilter(
                                filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withOpacity(0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withOpacity(0.1),
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    interest,
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }).toList() ??
                          [],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
