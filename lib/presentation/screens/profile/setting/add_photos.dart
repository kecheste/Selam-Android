import 'package:selam/data/models/user_model.dart';
import 'package:selam/data/repositories/user.dart';
import 'package:selam/presentation/widgets/buttons/rectangular_button.dart';
import 'package:selam/presentation/widgets/loading/loading_indicator.dart';
import 'package:flutter/material.dart';
import 'dart:io';
import 'widgets/gallery_picker_screen.dart';
import 'dart:typed_data';

class PhotoUploadScreen extends StatefulWidget {
  const PhotoUploadScreen({super.key, required this.user});

  final MyUser user;

  @override
  State<PhotoUploadScreen> createState() => PhotoUploadScreenState();
}

class PhotoUploadScreenState extends State<PhotoUploadScreen> {
  final List<File> _selectedImages = [];
  final UserRepository userRepository = UserRepository();
  bool _isUploading = false;

  void _openGalleryPicker() async {
    final List<File>? pickedImages = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => GalleryPickerScreen()),
    );

    if (pickedImages != null) {
      setState(() {
        if (pickedImages.isNotEmpty) {
          for (var image in pickedImages) {
            _selectedImages.add(image);
          }
        }
      });
    }
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
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Images uploaded successfully'),
        backgroundColor: Colors.green,
      ),
    );
    Navigator.pop(context);
    setState(() {
      _isUploading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Upload Photos', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: Column(
        children: [
          Expanded(
            child: GridView.builder(
              padding: EdgeInsets.all(10),
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
                        color: Colors.white10,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(Icons.add, color: Colors.white, size: 40),
                    ),
                  );
                }
                return Stack(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.file(
                        _selectedImages[index],
                        width: double.infinity,
                        height: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Positioned(
                      top: 5,
                      right: 5,
                      child: GestureDetector(
                        onTap: () {
                          setState(() {
                            _selectedImages.removeAt(index);
                          });
                        },
                        child: CircleAvatar(
                          radius: 12,
                          backgroundColor: Colors.black54,
                          child:
                              Icon(Icons.close, color: Colors.white, size: 16),
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
          SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.all(10),
              child: rectangularButton(
                context,
                _isUploading
                    ? buildLoadingIndicator(20, Colors.white)
                    : Text('Upload Images',
                        style: TextStyle(color: Colors.white)),
                () {
                  _uploadImages();
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
