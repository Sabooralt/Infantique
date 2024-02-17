import 'package:flutter/material.dart';

class ImageSlider extends StatelessWidget {
  final Function(int) onChange;
  final int currentImage;
  final List<String> images;

  const ImageSlider({
    super.key,
    required this.onChange,
    required this.currentImage,
    required this.images,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 400,
      child: Stack(
        alignment: Alignment.center,
        children: [
          PageView.builder(
            itemCount: images.length,
            onPageChanged: onChange,
            itemBuilder: (context, index) {
              return Image.network(
                images[index],
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const Center(
                    child: Text('Error loading image'),
                  );
                },
              );
            },
          ),
          Positioned(
            left: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () {
                if (currentImage > 0) {
                  onChange(currentImage - 1);
                }
              },
            ),
          ),
          Positioned(
            right: 0,
            child: IconButton(
              icon: const Icon(Icons.arrow_forward_ios),
              onPressed: () {
                if (currentImage < images.length - 1) {
                  onChange(currentImage + 1);
                }
              },
            ),
          ),
        ],
      ),
    );
  }
}
