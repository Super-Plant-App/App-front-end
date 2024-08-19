import 'dart:io';
import 'package:flutter/material.dart';
import 'package:zr3te/Widgets/plants_history.dart';

class MyPlantsPage extends StatelessWidget {
  const MyPlantsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final plants = PlantRepository().plants;

    return Scaffold(
      body: ListView.builder(
        itemCount: plants.length,
        itemBuilder: (context, index) {
          final plant = plants[index];
          return PlantCard(
            plantName: plant.plantName,
            diseaseName: plant.diseaseName,
            date: plant.date,
            imagePath: plant.imagePath,
            borderRadius: 20.0, // Set your desired radius here
          );
        },
      ),
    );
  }
}

class PlantCard extends StatelessWidget {
  final String plantName;
  final String diseaseName;
  final String date;
  final String imagePath;
  final double borderRadius; // Added parameter for image border radius

  const PlantCard({
    super.key,
    required this.plantName,
    required this.diseaseName,
    required this.date,
    required this.imagePath,
    this.borderRadius = 20.0, // Default radius value
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 10,
      margin: const EdgeInsets.all(15.0),
      child: Row(
        children: [
          ClipRRect(
            borderRadius:
                BorderRadius.circular(borderRadius), // Set circular radius here
            child: SizedBox(
              width: 140,
              height: 140,
              child: Image.file(
                File(imagePath),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    plantName,
                    style: const TextStyle(
                      fontSize: 23,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    diseaseName,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    date,
                    style: const TextStyle(
                      color: Colors.grey,
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
