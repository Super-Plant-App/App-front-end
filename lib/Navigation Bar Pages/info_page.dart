import 'package:flutter/material.dart';

class InfoPage extends StatelessWidget {
  const InfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    // List of types and corresponding image paths
    final List<Map<String, String>> types = [
      {'name': 'Apple', 'image': 'assets/apple.jpeg'},
      {'name': 'Cassava', 'image': 'assets/cassava.jpeg'},
      {'name': 'Cherry', 'image': 'assets/cherry.jpeg'},
      {'name': 'Chili', 'image': 'assets/chili.jpeg'},
      {'name': 'Coffee', 'image': 'assets/coffee.jpeg'},
      {'name': 'Corn', 'image': 'assets/corn.jpeg'},
      {'name': 'Cucumber', 'image': 'assets/cucumber.jpeg'},
      {'name': 'Guava', 'image': 'assets/guava.jpeg'},
      {'name': 'Grape', 'image': 'assets/grape.jpeg'},
      {'name': 'Jamun', 'image': 'assets/jamun.jpeg'},
      {'name': 'Lemon', 'image': 'assets/lemon.jpeg'},
      {'name': 'Mango', 'image': 'assets/mango.jpeg'},
      {'name': 'Peach', 'image': 'assets/peach.jpeg'},
      {'name': 'Pepper Bell', 'image': 'assets/pepper_bell.jpeg'},
      {'name': 'Pomegranate', 'image': 'assets/pomegranate.jpeg'},
      {'name': 'Potato', 'image': 'assets/potato.jpeg'},
      {'name': 'Rice', 'image': 'assets/rice.jpeg'},
      {'name': 'Soybean', 'image': 'assets/soybean.jpeg'},
      {'name': 'Strawberry', 'image': 'assets/strawberry.jpeg'},
      {'name': 'Sugarcane', 'image': 'assets/sugarcane.jpeg'},
      {'name': 'Tea', 'image': 'assets/tea.jpeg'},
      {'name': 'Tomato', 'image': 'assets/tomato.jpeg'},
      {'name': 'Wheat', 'image': 'assets/wheat.jpeg'},
    ];

    return Scaffold(
      body: ListView.builder(
        itemCount: types.length,
        itemBuilder: (context, index) {
          final type = types[index];
          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: InfoCard(
              title: type['name']!,
              imagePath: type['image']!,
            ),
          );
        },
      ),
    );
  }
}

class InfoCard extends StatelessWidget {
  final String title;
  final String imagePath;

  const InfoCard({
    super.key,
    required this.title,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 7,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        children: [
          Container(
            width: 130, // Adjust the width as needed
            height: 130, // Adjust the height as needed
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(15), // Adjust the circularity
              image: DecorationImage(
                image: AssetImage(imagePath),
                fit: BoxFit.fill,
              ),
            ),
          ),
          Expanded(
            child: ListTile(
              contentPadding: const EdgeInsets.all(16.0),
              title: Text(
                title,
                style: const TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w400,
                ),
              ),
              // Remove the leading icon
              leading: null,
            ),
          ),
        ],
      ),
    );
  }
}
