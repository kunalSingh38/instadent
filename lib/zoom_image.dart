import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:instadent/constants.dart';
import 'package:photo_view/photo_view.dart';

class ZoomImages extends StatefulWidget {
  List images = [];
  int selectedIndex = 0;
  ZoomImages({required this.images, required this.selectedIndex});
  @override
  _ZoomImagesState createState() => _ZoomImagesState();
}

class _ZoomImagesState extends State<ZoomImages> {
  int index = 0;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      index = widget.selectedIndex;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.white,
        actions: [
          InkWell(
            onTap: () {
              Navigator.of(context).pop();
            },
            child: Image.asset(
              "assets/close.png",
              // color: Colors.grey,
              scale: 12,
            ),
          )
        ],
      ),
      body: Container(
        height: MediaQuery.of(context).size.height / 1.5,
        child: PhotoView(
            backgroundDecoration: BoxDecoration(color: Colors.white),
            imageProvider: NetworkImage(widget.images[index]['image'])),
      ),
      bottomSheet: Container(
        height: 130,
        color: Colors.white,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: widget.images.map((e) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        index = widget.images.indexOf(e);
                      });
                    },
                    child: Container(
                      height: 90,
                      width: 90,
                      decoration: BoxDecoration(
                          border: widget.images.indexOf(e) == index
                              ? Border.all(color: Colors.blue, width: 1)
                              : Border.all(color: Colors.grey, width: 1),
                          borderRadius: BorderRadius.circular(20)),
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: cacheImage(e['image'].toString())),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      ),
    );
  }
}
