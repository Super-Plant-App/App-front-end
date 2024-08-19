import 'package:flutter/material.dart';
import 'dart:io';

class FullScreenImagePage extends StatelessWidget {
  final String imagePath;
  final List<double> boundingBox;
  final int originalHeight;
  final int originalWidth;
  final double confidence;

  const FullScreenImagePage({
    super.key,
    required this.imagePath,
    required this.boundingBox,
    required this.originalHeight,
    required this.originalWidth,
    required this.confidence,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final screenWidth = constraints.maxWidth;
          final screenHeight = constraints.maxHeight;
          final imageAspectRatio = originalWidth / originalHeight;

          // Calculate image size based on screen dimensions and aspect ratio
          final imageWidth = screenWidth;
          final imageHeight = screenWidth / imageAspectRatio;

          if (imageHeight < screenHeight) {
            // Image is smaller than the screen height
            return Stack(
              fit: StackFit.expand,
              children: [
                Positioned(
                  top: (screenHeight - imageHeight) / 2,
                  child: Image.file(
                    File(imagePath),
                    width: imageWidth,
                    height: imageHeight,
                    fit: BoxFit.contain,
                  ),
                ),
                if (boundingBox.isNotEmpty)
                  Positioned(
                    left: boundingBox[0] * screenWidth / originalWidth,
                    top: boundingBox[1] * screenWidth / originalWidth +
                        (screenHeight - imageHeight) / 2,
                    width: (boundingBox[2] - boundingBox[0]) *
                        screenWidth /
                        originalWidth,
                    height: (boundingBox[3] - boundingBox[1]) *
                        screenWidth /
                        originalWidth,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 2),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          top: 0,
                          child: Container(
                            color: Colors.red.withOpacity(0.7),
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              'Confidence: ${(confidence * 100).toStringAsFixed(2)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
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
            );
          } else {
            // Image is larger than or equal to the screen height
            return Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                ),
                if (boundingBox.isNotEmpty)
                  Positioned(
                    left: boundingBox[0] * screenWidth / originalWidth,
                    top: boundingBox[1] * screenHeight / originalHeight,
                    width: (boundingBox[2] - boundingBox[0]) *
                        screenWidth /
                        originalWidth,
                    height: (boundingBox[3] - boundingBox[1]) *
                        screenHeight /
                        originalHeight,
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: Border.all(color: Colors.red, width: 2),
                          ),
                        ),
                        Positioned(
                          left: 0,
                          bottom: 0,
                          child: Container(
                            color: Colors.red.withOpacity(0.6),
                            padding: const EdgeInsets.all(4.0),
                            child: Text(
                              '${confidence.toStringAsFixed(2)}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
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
            );
          }
        },
      ),
    );
  }
}
