import 'dart:io';
import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:zr3te/Widgets/plants_history.dart';
import 'package:zr3te/main.dart';
import 'chatbot_page.dart';
import 'fullscreen_page.dart';
import 'preprocessed_image_page.dart';

class ResultsPage extends StatefulWidget {
  final String imagePath;
  final String predictedClass;
  final List<double> boundingBox;
  final int originalHeight;
  final int originalWidth;
  final Uint8List preprocessedImage;
  final double confidence;
  final String selectedOption;

  const ResultsPage({
    super.key,
    required this.imagePath,
    required this.predictedClass,
    required this.boundingBox,
    required this.originalHeight,
    required this.originalWidth,
    required this.preprocessedImage,
    required this.confidence,
    required this.selectedOption,
  });

  @override
  // ignore: library_private_types_in_public_api
  _ResultsPageState createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  bool _isLoading = false;
  bool _isSuccess = false;

  void _handleAddToMyPlants() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate a loading process
    await Future.delayed(const Duration(seconds: 1));

    // Get the current date and time
    final now = DateTime.now();
    // ignore: prefer_interpolation_to_compose_strings
    final dateTimeString = "${now.toLocal()}".split(' ')[0] +
        ' ' +
        "${now.hour}:${now.minute}:${now.second}";

    // Add the plant data to the repository
    PlantRepository().addPlant(
      Plant(
        plantName: widget.predictedClass.split(RegExp(r'_+')).first,
        diseaseName:
            widget.predictedClass.split(RegExp(r'_+')).sublist(1).join(' '),
        date: dateTimeString,
        imagePath: widget.imagePath,
      ),
    );

    setState(() {
      _isLoading = false;
      _isSuccess = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final parts = widget.predictedClass.split(RegExp(r'_+'));
    final plantName = parts.isNotEmpty ? parts[0] : 'Unknown';
    final diseaseName =
        parts.length > 1 ? parts.sublist(1).join(' ') : 'Unknown';
    final diseaseColor =
        diseaseName.toLowerCase() == 'healthy' ? Colors.green : Colors.red;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 400,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: GestureDetector(
                onTap: () {
                  if (widget.selectedOption == 'Segmentation') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => PreprocessedImagePage(
                          preprocessedImage: widget.preprocessedImage,
                        ),
                      ),
                    );
                  } else {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => FullScreenImagePage(
                          imagePath: widget.imagePath,
                          boundingBox: widget.boundingBox,
                          originalHeight: widget.originalHeight,
                          originalWidth: widget.originalWidth,
                          confidence: widget.confidence,
                        ),
                      ),
                    );
                  }
                },
                child: Image.file(
                  File(widget.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            automaticallyImplyLeading: false,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 30,
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const HomePage()),
                  (route) => false,
                );
              },
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '$plantName Leaf',
                    style: const TextStyle(
                      fontSize: 35,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'Disease: ${diseaseName.split(' ').map((word) => '${word[0].toUpperCase()}${word.substring(1)}').join(' ')}',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                      color: diseaseColor,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            plantName: plantName,
                            diseaseName: diseaseName,
                          ),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color.fromARGB(255, 33, 159, 142),
                      minimumSize: const Size(double.infinity, 52),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: const Text(
                      'Get Cure Plan',
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                    ),
                  ),
                  const SizedBox(height: 30),
                  Row(
                    children: [
                      const Icon(
                        Icons.add,
                        color: Colors.grey,
                        size: 25,
                      ),
                      const SizedBox(width: 10),
                      const Text(
                        'Add to My Plants',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (!_isLoading && !_isSuccess)
                        ElevatedButton(
                          onPressed: _handleAddToMyPlants,
                          style: ElevatedButton.styleFrom(
                            backgroundColor:
                                const Color.fromARGB(255, 112, 174, 166),
                            minimumSize: const Size(100, 40),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            'ADD',
                            style: TextStyle(color: Colors.white),
                          ),
                        )
                      else if (_isLoading)
                        const SizedBox(
                          width: 100,
                          height: 40,
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Color.fromARGB(255, 33, 159, 142),
                            ),
                          ),
                        )
                      else if (_isSuccess)
                        const Icon(
                          Icons.check,
                          color: Colors.green,
                          size: 27,
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Divider(),
                  const SizedBox(height: 20),
                  const Text(
                    'Plant Overview',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Early Harvest Apple Tree is a medium-sized tree that produces red apples. It is known for its early harvest season and is widely cultivated for its fruit.',
                    style: TextStyle(
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 20),
                  if (widget.selectedOption == 'Object Detection')
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => PreprocessedImagePage(
                                preprocessedImage: widget.preprocessedImage,
                              ),
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              const Color.fromARGB(255, 112, 174, 166),
                          minimumSize: const Size(30, 52),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                        child: const Text(
                          'Preprocessed Image',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
