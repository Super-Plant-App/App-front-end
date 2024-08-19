import 'package:flutter/material.dart';
import 'dart:typed_data';

class PreprocessedImagePage extends StatelessWidget {
  final Uint8List preprocessedImage;

  const PreprocessedImagePage({
    super.key,
    required this.preprocessedImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final screenWidth = constraints.maxWidth;
                final screenHeight = constraints.maxHeight;

                return Image.memory(
                  preprocessedImage,
                  width: screenWidth,
                  height: screenHeight,
                  fit: BoxFit.contain,
                );
              },
            ),
          ),
          Positioned(
            top: 50,
            left: 25,
            child: IconButton(
              icon: const Icon(
                Icons.close,
                color: Colors.white,
                size: 40,
              ),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ),
        ],
      ),
    );
  }
}
