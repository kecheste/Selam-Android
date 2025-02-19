import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:photo_manager/photo_manager.dart';

class GalleryPickerScreen extends StatefulWidget {
  const GalleryPickerScreen({super.key});

  @override
  State<GalleryPickerScreen> createState() => GalleryPickerScreenState();
}

class GalleryPickerScreenState extends State<GalleryPickerScreen> {
  List<AssetPathEntity> _albums = [];
  // ignore: prefer_final_fields
  List<AssetEntity> _galleryImages = [];
  // ignore: prefer_final_fields
  List<AssetEntity> _selectedImages = [];
  AssetPathEntity? _selectedAlbum;
  int _page = 0;
  final int _pageSize = 30;
  bool _isLoading = false;
  // ignore: prefer_final_fields
  ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _loadAlbums();
    _scrollController.addListener(_onScroll);
  }

  Future<void> _loadAlbums() async {
    final PermissionState ps = await PhotoManager.requestPermissionExtend();
    if (ps.isAuth) {
      List<AssetPathEntity> albums =
          await PhotoManager.getAssetPathList(type: RequestType.image);
      if (albums.isNotEmpty) {
        setState(() {
          _albums = albums;
          _selectedAlbum = albums[0];
        });
        _fetchMoreImages();
      }
    }
  }

  Future<void> _fetchMoreImages() async {
    if (_selectedAlbum == null || _isLoading) return;
    setState(() => _isLoading = true);

    List<AssetEntity> photos =
        await _selectedAlbum!.getAssetListPaged(page: _page, size: _pageSize);
    setState(() {
      _galleryImages.addAll(photos);
      _page++;
      _isLoading = false;
    });
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
            _scrollController.position.maxScrollExtent &&
        !_isLoading) {
      _fetchMoreImages();
    }
  }

  void _changeAlbum(AssetPathEntity album) {
    setState(() {
      _selectedAlbum = album;
      _galleryImages.clear();
      _page = 0;
    });
    _fetchMoreImages();
  }

  void _toggleSelection(AssetEntity image) {
    setState(() {
      _selectedImages.contains(image)
          ? _selectedImages.remove(image)
          : _selectedImages.add(image);
    });
  }

  void _confirmSelection() async {
    List<File> selectedFiles = [];
    for (var image in _selectedImages) {
      File? file = await image.file;
      if (file != null) {
        selectedFiles.add(file);
      }
    }
    if (mounted) {
      Navigator.pop(context, selectedFiles.isNotEmpty ? selectedFiles : null);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text('Select Images', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.black,
        iconTheme: IconThemeData(color: Colors.white),
        actions: [
          TextButton(
            onPressed: _confirmSelection,
            child: Text('Done (${_selectedImages.length})',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_albums.isNotEmpty)
            Container(
              padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              color: Colors.black,
              child: DropdownButton<AssetPathEntity>(
                dropdownColor: Colors.black,
                value: _selectedAlbum,
                isExpanded: true,
                onChanged: (album) => _changeAlbum(album!),
                items: _albums.map((album) {
                  return DropdownMenuItem(
                    value: album,
                    child:
                        Text(album.name, style: TextStyle(color: Colors.white)),
                  );
                }).toList(),
              ),
            ),
          Expanded(
            child: _galleryImages.isEmpty
                ? Center(child: CircularProgressIndicator())
                : GridView.builder(
                    controller: _scrollController,
                    padding: EdgeInsets.all(10),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                    ),
                    itemCount: _galleryImages.length + 1,
                    itemBuilder: (context, index) {
                      if (index == _galleryImages.length) {
                        return _isLoading
                            ? Center(child: CircularProgressIndicator())
                            : SizedBox.shrink();
                      }

                      final image = _galleryImages[index];
                      final isSelected = _selectedImages.contains(image);

                      return FutureBuilder<Uint8List?>(
                        future: image
                            .thumbnailDataWithSize(ThumbnailSize(150, 150)),
                        builder: (context, snapshot) {
                          if (!snapshot.hasData) {
                            return Container(color: Colors.grey);
                          }

                          return GestureDetector(
                            onTap: () => _toggleSelection(image),
                            child: Stack(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.memory(snapshot.data!,
                                      fit: BoxFit.cover,
                                      width: double.infinity),
                                ),
                                if (isSelected)
                                  Positioned(
                                    top: 5,
                                    right: 5,
                                    child: CircleAvatar(
                                      radius: 12,
                                      backgroundColor: Colors.white,
                                      child: Icon(Icons.check,
                                          color: Colors.black, size: 16),
                                    ),
                                  ),
                              ],
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
