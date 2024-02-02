import 'package:flutter/material.dart';

class ImageSlider extends StatelessWidget {
  final Function(int) onChange;
  final int currentImage;
  final List<String> imageUrls;

  const ImageSlider({
    Key? key,
    required this.onChange,
    required this.currentImage,
    required this.imageUrls,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    print('Image URLs: $imageUrls'); // Print URLs for debugging

    return Expanded(
      child: SizedBox(
        height: 250,
        child: PageView.builder(
          itemCount: imageUrls.length,
          onPageChanged: onChange,
          itemBuilder: (context, index) {
            return Image.network(
              imageUrls[index],
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
      ),
    );
  }
}
