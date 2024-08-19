// ignore_for_file: avoid_print

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'result_page.dart';
import 'package:image/image.dart' as img;

class ScannerPage extends StatefulWidget {
  final String imagePath;
  final String selectedOption;

  const ScannerPage({
    super.key,
    required this.imagePath,
    required this.selectedOption,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ScannerPageState createState() => _ScannerPageState();
}

class _ScannerPageState extends State<ScannerPage>
    with SingleTickerProviderStateMixin {
  late bool uploadingDone;
  late bool detectingDone;
  late bool identifyingDone;
  late AnimationController _animationController;
  late Animation<double> _scanAnimation;
  late String _predictedClass = '';
  late double _confidence = 0.0;
  late List<double> _boundingBox = [];
  late int _originalHeight = 0;
  late int _originalWidth = 0;
  late Uint8List _preprocessedImage = Uint8List(0);
  late bool noPlantDetected = false;

  @override
  void initState() {
    super.initState();
    uploadingDone = false;
    detectingDone = false;
    identifyingDone = false;

    // Initialize AnimationController and Animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();

    _scanAnimation = Tween<double>(begin: -1.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.linear,
      ),
    );

    // Start uploading the image and loading indicators concurrently
    Future(() async {
      final uploadFuture = uploadImage();

      Future.wait([
        Future.delayed(const Duration(seconds: 4)).then((_) {
          setState(() {
            uploadingDone = true;
            _checkNavigation();
          });
        }),
        Future.delayed(const Duration(seconds: 8)).then((_) {
          setState(() {
            detectingDone = true;
            _checkNavigation();
          });
        }),
      ]);

      await uploadFuture;
    });
  }

  void _checkNavigation() {
    if (uploadingDone && detectingDone && identifyingDone) {
      if (_predictedClass == 'No Plant Detected') {
        // Stop navigation and clear text and indicators
        setState(() {
          noPlantDetected = true;
        });
        return; // Exit without navigating
      } else {
        Navigator.push(
          // ignore: use_build_context_synchronously
          context,
          MaterialPageRoute(
            builder: (context) => ResultsPage(
              imagePath: widget.imagePath,
              predictedClass: _predictedClass,
              boundingBox: _boundingBox,
              originalHeight: _originalHeight,
              originalWidth: _originalWidth,
              confidence: _confidence,
              preprocessedImage: _preprocessedImage,
              selectedOption: widget.selectedOption,
            ),
          ),
        );
      }
    }
  }

  Future<void> uploadImage() async {
    // Select URL based on the selected option
    final url = widget.selectedOption == 'Object Detection'
        ? Uri.parse('http://20.54.112.25/model/predict-image/')
        : Uri.parse('http://20.54.112.25/model/segment/');

    try {
      var request = http.MultipartRequest('POST', url);

      request.files
          .add(await http.MultipartFile.fromPath('file', widget.imagePath));

      var response = await request.send();

      final responseBody = await response.stream.bytesToString();

      print('Response Body: $responseBody');

      if (response.statusCode == 200) {
        final data = json.decode(responseBody) as Map<String, dynamic>;

        setState(() {
          identifyingDone = true;
          final List<dynamic> preprocessedImageList;

          if (widget.selectedOption == 'Object Detection') {
            _predictedClass = data['predicted_class'] ?? 'No Plant Detected';
            _confidence = data['Yolo result']['conf'][0] ?? 0.0;
            _boundingBox = List<double>.from(data['Yolo result']['xyxy'][0]);
            _originalHeight = data['orig_shape'][0];
            _originalWidth = data['orig_shape'][1];

            preprocessedImageList = data['preprocessd image'] ?? [];

            if (preprocessedImageList.isNotEmpty) {
              final int height = preprocessedImageList.length;
              final int width = preprocessedImageList.isNotEmpty
                  ? preprocessedImageList[0].length
                  : 0;

              final img.Image image = img.Image(width, height);

              for (int y = 0; y < height; y++) {
                for (int x = 0; x < width; x++) {
                  final pixel = preprocessedImageList[y][x];
                  if (pixel is List && pixel.length == 3) {
                    final r = (pixel[0] * 255).toInt();
                    final g = (pixel[1] * 255).toInt();
                    final b = (pixel[2] * 255).toInt();
                    image.setPixel(x, y, img.getColor(r, g, b));
                  }
                }
              }

              final pngData = img.encodePng(image);
              _preprocessedImage = Uint8List.fromList(pngData);
            }
          } else {
            _predictedClass = data['predicted_class'][0] ?? 'No Plant Detected';

            preprocessedImageList = data['Photo'] ?? [];

            if (preprocessedImageList.isNotEmpty) {
              final int height = preprocessedImageList.length;
              final int width = preprocessedImageList.isNotEmpty
                  ? preprocessedImageList[0].length
                  : 0;

              final img.Image image = img.Image(width, height);

              for (int y = 0; y < height; y++) {
                for (int x = 0; x < width; x++) {
                  final pixel = preprocessedImageList[y][x];
                  if (pixel is List && pixel.length == 3) {
                    final r = (pixel[0]).toInt();
                    final g = (pixel[1]).toInt();
                    final b = (pixel[2]).toInt();
                    image.setPixel(x, y, img.getColor(r, g, b));
                  }
                }
              }

              final pngData = img.encodePng(image);
              _preprocessedImage = Uint8List.fromList(pngData);
            }
          }
          _checkNavigation();
        });

        print('Predicted Class: ${data['predicted_class']}');
        print('Confidence: ${data['Yolo result']['conf'][0]}');
        print('YOLO Result: ${data['Yolo result']}');
      } else {
        print('Failed to upload image. Status Code: ${response.statusCode}');
        setState(() {});
      }
    } catch (e) {
      print('Exception occurred: $e');
      setState(() {});
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image with Blur Effect
          Positioned.fill(
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                ),
                BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 6.0, sigmaY: 6.0),
                  child: Container(
                    color: Colors.black.withOpacity(
                        0.5), // Add opacity for better visibility of the foreground elements
                  ),
                ),
              ],
            ),
          ),
          // Scanning Effect Overlay
          AnimatedBuilder(
            animation: _scanAnimation,
            builder: (context, child) {
              return Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      stops: const [0.0, 0.1, 0.2, 0.3],
                      colors: [
                        Colors.transparent,
                        Colors.white.withOpacity(0.3),
                        Colors.transparent,
                        Colors.transparent,
                      ],
                    ),
                  ),
                  transform: Matrix4.translationValues(
                    0.0,
                    _scanAnimation.value * MediaQuery.of(context).size.height,
                    0.0,
                  ),
                ),
              );
            },
          ),
          // Foreground Content
          Positioned(
            top: 150, // Adjust this value to move the image up or down
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                width: 320, // Adjust width as needed
                height: 320, // Adjust height as needed
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.white, width: 3),
                  borderRadius: BorderRadius.circular(16.0),
                  color: Colors.white, // Background color of the container
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16.0),
                  child: Image.file(
                    File(widget.imagePath),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            bottom: 110.0,
            left: 0,
            right: 0,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text(
                  'Scanning...',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10.0),
                const Text(
                  'We are checking our garden\njust wait a second 😌',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16.0,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 60.0),
                // Status indicators with loading indicator and check marks
                if (uploadingDone || detectingDone || identifyingDone)
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!uploadingDone)
                            const SizedBox(
                              width: 20, // Width of the loading indicator
                              height: 20, // Height of the loading indicator
                              child: CircularProgressIndicator(
                                strokeWidth: 2, // Thickness of the indicator
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          else
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                          const SizedBox(width: 10),
                          const Text(
                            'Uploading image',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!detectingDone)
                            const SizedBox(
                              width: 20, // Width of the loading indicator
                              height: 20, // Height of the loading indicator
                              child: CircularProgressIndicator(
                                strokeWidth: 2, // Thickness of the indicator
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          else
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                          const SizedBox(width: 10),
                          const Text(
                            'Detecting plant',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!identifyingDone)
                            const SizedBox(
                              width: 20, // Width of the loading indicator
                              height: 20, // Height of the loading indicator
                              child: CircularProgressIndicator(
                                strokeWidth: 2, // Thickness of the indicator
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          else if (uploadingDone && detectingDone)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                          const SizedBox(width: 10),
                          const Text(
                            'Identifying disease',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                      // Display "No Plant Detected" message if applicable
                      Visibility(
                        visible: noPlantDetected,
                        child: const Padding(
                          padding: EdgeInsets.fromLTRB(0.0, 10.0, 0.0, 0.0),
                          child: Text(
                            'No Plant Detected',
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                else
                  // Display loading indicators only if not all are done
                  Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!uploadingDone)
                            const SizedBox(
                              width: 20, // Width of the loading indicator
                              height: 20, // Height of the loading indicator
                              child: CircularProgressIndicator(
                                strokeWidth: 2, // Thickness of the indicator
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          else
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                          const SizedBox(width: 10),
                          const Text(
                            'Uploading image',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!detectingDone)
                            const SizedBox(
                              width: 20, // Width of the loading indicator
                              height: 20, // Height of the loading indicator
                              child: CircularProgressIndicator(
                                strokeWidth: 2, // Thickness of the indicator
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          else
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                          const SizedBox(width: 10),
                          const Text(
                            'Detecting plant',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10.0),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          if (!identifyingDone)
                            const SizedBox(
                              width: 20, // Width of the loading indicator
                              height: 20, // Height of the loading indicator
                              child: CircularProgressIndicator(
                                strokeWidth: 2, // Thickness of the indicator
                                valueColor:
                                    AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          else if (uploadingDone && detectingDone)
                            const Icon(
                              Icons.check_circle,
                              color: Colors.green,
                              size: 20,
                            ),
                          const SizedBox(width: 10),
                          const Text(
                            'Identifying disease',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16.0,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
