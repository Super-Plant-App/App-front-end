import 'dart:ui'; // Import for BackdropFilter
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'scanning_page.dart'; // Update the import to your file

class CameraPage extends StatefulWidget {
  const CameraPage({super.key});

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  String _selectedOption = 'Object Detection'; // Default selected option

  @override
  void initState() {
    super.initState();
    // Initialize the camera
    _initializeControllerFuture = _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    // Get the list of available cameras
    final cameras = await availableCameras();
    // Use the first camera
    _controller = CameraController(cameras[0], ResolutionPreset.high);

    // Initialize the controller
    await _controller.initialize();
  }

  @override
  void dispose() {
    // Dispose the camera controller when the widget is disposed
    _controller.dispose();
    super.dispose();
  }

  Future<void> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ScannerPage(
            imagePath: pickedFile.path,
            selectedOption: _selectedOption, // Pass the selected option
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                // Background image with blur effect
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                    child: Container(
                      color: Colors.black.withOpacity(0.5),
                    ),
                  ),
                ),
                // Camera preview
                Positioned.fill(
                  child: CameraPreview(_controller),
                ),
                // Capture mark in the center
                Center(
                  child: Container(
                    width: 260,
                    height: 260,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                ),
                // Close button
                Positioned(
                  top: 40,
                  left: 20,
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
                // Dropdown button inside a white box at the top right
                Positioned(
                  top: 40,
                  right: 20,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      border: Border.all(
                        color: const Color.fromARGB(255, 44, 188, 169),
                        width: 2,
                      ), // Green border
                      borderRadius: BorderRadius.circular(30),
                    ),
                    child: DropdownButton<String>(
                      value: _selectedOption,
                      items: <String>['Object Detection', 'Segmentation']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedOption = newValue!;
                        });
                      },
                      underline: const SizedBox(), // Hide the underline
                    ),
                  ),
                ),
                // Container at the bottom of the screen
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    color: const Color.fromARGB(255, 245, 250, 254),
                    height: 160,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Photos button
                        Padding(
                          padding: const EdgeInsets.only(left: 20),
                          child: TextButton(
                            style: TextButton.styleFrom(
                              backgroundColor: Colors.white,
                              side: const BorderSide(
                                color: Color.fromARGB(255, 44, 188, 169),
                                width: 2,
                              ), // Green border
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(
                                    30), // Rounded corners
                              ),
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 35, vertical: 10),
                            ),
                            onPressed: _pickImageFromGallery,
                            child: const Text(
                              'Photos',
                              style: TextStyle(
                                color: Color.fromARGB(255, 44, 188, 169),
                                fontSize: 17,
                              ),
                            ),
                          ),
                        ),
                        const Spacer(), // Spacer to push the camera button to the center
                        // Camera button
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            shape: const CircleBorder(),
                            backgroundColor: const Color.fromARGB(
                                255, 44, 188, 169), // Button color
                            padding: const EdgeInsets.all(16),
                          ),
                          child: const Icon(
                            Icons.camera,
                            size: 50,
                            color: Colors.white,
                          ),
                          onPressed: () async {
                            try {
                              // Ensure the camera is initialized
                              await _initializeControllerFuture;

                              // Take a picture
                              final image = await _controller.takePicture();

                              // Navigate to ScannerPage with captured image and selected option
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => ScannerPage(
                                    imagePath: image.path,
                                    selectedOption:
                                        _selectedOption, // Pass the selected option
                                  ),
                                ),
                              );
                            } catch (e) {
                              // Handle errors
                              print(e);
                            }
                          },
                        ),
                        const SizedBox(width: 155),
                      ],
                    ),
                  ),
                ),
              ],
            );
          } else {
            // Display a loading indicator while the camera is initializing
            return const Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }
}
