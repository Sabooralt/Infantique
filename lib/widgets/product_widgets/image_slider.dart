import 'package:flutter/material.dart';

class ImageSlider extends StatelessWidget {
  final Function(int) onChange;
  final int currentImage;
  final List<String> images;

  const ImageSlider({
    Key? key,
    required this.onChange,
    required this.currentImage,
    required this.images,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 250,
      child: PageView.builder(
        itemCount: images.length,
        onPageChanged: onChange,
        itemBuilder: (context, index) {
          return Image.network(
            images[index],
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              print('Error loading image: $error');
              return Center(
                child: Text('Error loading image'),
              );
            },
          );
        },
      ),
    );
  }
}
