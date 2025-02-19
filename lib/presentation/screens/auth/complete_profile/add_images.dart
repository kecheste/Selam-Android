import 'package:selam/data/models/user_model.dart';
import 'package:selam/data/repositories/auth.dart';
import 'package:selam/data/repositories/user.dart';
import 'package:selam/presentation/screens/home/home_page.dart';
import 'package:selam/presentation/screens/profile/setting/widgets/gallery_picker_screen.dart';
import 'package:selam/presentation/widgets/buttons/rectangular_button.dart';
import 'package:selam/presentation/widgets/loading/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'dart:typed_data';

class AddImagesScreen extends StatefulWidget {
  const AddImagesScreen({super.key, required this.user});

  final MyUser user;

  @override
  State<AddImagesScreen> createState() => AddImagesScreenState();
}

class AddImagesScreenState extends State<AddImagesScreen> {
  final List<File> _selectedImages = [];
  final AuthRepository authRepository = AuthRepository();
  final UserRepository userRepository = UserRepository();

  bool _isUploading = false;

  void _openGalleryPicker() async {
    final List<File>? pickedImages = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GalleryPickerScreen()),
    );

    if (pickedImages != null) {
      setState(() {
        _selectedImages.addAll(pickedImages);
      });
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Future<void> _uploadImages() async {
    if (_selectedImages.isEmpty) {
      return;
    }
    setState(() {
      _isUploading = true;
    });

    List<Uint8List> imageBytes = [];
    for (var image in _selectedImages) {
      imageBytes.add(await image.readAsBytes());
    }
    await userRepository.uploadImages(imageBytes, widget.user.id);
    Navigator.pushReplacement(
        context, MaterialPageRoute(builder: (context) => HomePage()));
    setState(() {
      _isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('Review photos',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            height: 4,
            color: Colors.redAccent,
          ),
          SizedBox(height: 10),
          Text("Add up to 7 photos",
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14)),
          SizedBox(height: 15),
          Expanded(
            child: Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: _selectedImages.length + 1,
                itemBuilder: (context, index) {
                  if (index == _selectedImages.length) {
                    return GestureDetector(
                      onTap: _openGalleryPicker,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(FontAwesomeIcons.plus,
                            color: Colors.grey.shade700, size: 40),
                      ),
                    );
                  }

                  return Stack(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.file(
                          _selectedImages[index],
                          fit: BoxFit.cover,
                          width: double.infinity,
                          height: double.infinity,
                        ),
                      ),
                      Positioned(
                        top: 5,
                        right: 5,
                        child: GestureDetector(
                          onTap: () => _removeImage(index),
                          child: CircleAvatar(
                            radius: 12,
                            backgroundColor: Colors.grey.shade700,
                            child: Icon(FontAwesomeIcons.xmark,
                                color: Colors.white, size: 16),
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Container(
              margin: EdgeInsets.symmetric(vertical: 20, horizontal: 10),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: rectangularButton(
                    context,
                    _isUploading
                        ? buildLoadingIndicator(20, Colors.white)
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Icon(
                                FontAwesomeIcons.camera,
                                color: Colors.white,
                                size: 16,
                              ),
                              SizedBox(width: 10),
                              Text(
                                "Add photos ${_selectedImages.length}/7",
                                style: TextStyle(
                                    fontSize: 16,
                                    color: _selectedImages.isNotEmpty
                                        ? Colors.white
                                        : Colors.grey.shade400),
                              ),
                            ],
                          ), () async {
                  await _uploadImages();
                }),
              ),
            ),
          )
        ],
      ),
    );
  }
}
