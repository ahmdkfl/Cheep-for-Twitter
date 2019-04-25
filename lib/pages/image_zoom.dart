import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class ImageZoom extends StatelessWidget {
  final String url;

  ImageZoom({Key key, @required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(),
      body: GestureDetector(
        child: Center(
          child: Hero(
            tag: url,
            child: CachedNetworkImage(
                placeholder: (context, string) {
                  return CircularProgressIndicator();
                },
                imageUrl: url),
          ),
        ),
        onTap: () {
          Navigator.pop(context);
        },
      ),
    );
  }
}
