import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

/// Screen that displays the image in the whole screen
class ImageZoom extends StatelessWidget {
  // Url of the image to zoom is required
  final String url;

  ImageZoom({Key key, @required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: new AppBar(),
      body: GestureDetector(
        child: Center(
          child: CachedNetworkImage(
              placeholder: (context, string) {
                return Align(
                    alignment: Alignment.center,
                    child: CircularProgressIndicator());
              },
              imageUrl: url),
        ),
        onTap: () {
          // When the image is tapped go to the previous screen
          Navigator.pop(context);
        },
      ),
    );
  }
}
