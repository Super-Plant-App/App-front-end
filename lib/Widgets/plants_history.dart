import 'dart:collection';

class PlantRepository {
  // Singleton pattern
  static final PlantRepository _instance = PlantRepository._internal();
  factory PlantRepository() => _instance;
  PlantRepository._internal();

  final List<Plant> _plants = [];

  UnmodifiableListView<Plant> get plants => UnmodifiableListView(_plants);

  void addPlant(Plant plant) {
    _plants.add(plant);
  }
}

class Plant {
  final String plantName;
  final String diseaseName;
  final String date;
  final String imagePath;

  Plant({
    required this.plantName,
    required this.diseaseName,
    required this.date,
    required this.imagePath,
  });
}
