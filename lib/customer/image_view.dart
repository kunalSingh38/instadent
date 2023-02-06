import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';

class ImageView extends StatefulWidget {
  String path = "";
  ImageView({required this.path});

  @override
  _ImageViewState createState() => _ImageViewState();
}

class _ImageViewState extends State<ImageView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.teal[300],
        elevation: 0,
      ),
      body: PhotoView(
        imageProvider: NetworkImage(widget.path),
      ),
    );
  }
}
