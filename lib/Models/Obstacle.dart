import 'dart:math';
import 'package:flutter/material.dart';

class TerrainModels {
  final List<Offset> points = [];
  final List<Offset> coins = [];
  final List<Offset> fuelCans = [];
  final List<ObstacleModel> obstacles = [];
  final Random _random = Random();

  int currentSegment = 0;
  final List<String> terrainTypes = ['hills', 'mountains', 'desert', 'valley', 'snow', 'night'];

  TerrainModels() {
    generate();
  }

  void generate() {
    points.clear();
    coins.clear();
    fuelCans.clear();
    obstacles.clear();
    currentSegment = 0;

    generateSegment(0);
  }

  void generateSegment(int segmentIndex) {
    double startX = segmentIndex == 0 ? 0 : points.last.dx;
    double startY = segmentIndex == 0 ? 200 : points.last.dy;

    String terrainType = terrainTypes[segmentIndex % terrainTypes.length];

    int pointsToAdd = 100;

    for (int i = 0; i < pointsToAdd; i++) {
      points.add(Offset(startX, startY));

      // Add coins randomly
      if (i % 5 == 0 && _random.nextDouble() > 0.65) {
        coins.add(Offset(startX, startY - 60 - _random.nextDouble() * 40));
      }

      // Add fuel cans - INCREASED frequency
      if (i % 6 == 0 && _random.nextDouble() > 0.65) {
        fuelCans.add(Offset(startX, startY - 50 - _random.nextDouble() * 30));
      }

      // Add obstacles
      if (i > 10 && i % 8 == 0 && _random.nextDouble() > 0.5) {
        ObstacleType type = ObstacleType.values[_random.nextInt(ObstacleType.values.length)];
        double obstacleWidth = type == ObstacleType.spike ? 25 : (type == ObstacleType.tree ? 20 : 30);
        double obstacleHeight = type == ObstacleType.spike ? 30 : (type == ObstacleType.tree ? 50 : 25);

        obstacles.add(ObstacleModel(
          position: Offset(startX, startY - obstacleHeight),
          type: type,
          width: obstacleWidth,
          height: obstacleHeight,
        ));
      }

      startX += 50 + _random.nextDouble() * 30;

      // Create different terrain patterns based on type
      double heightChange = 0;
      switch (terrainType) {
        case 'hills':
          heightChange = sin(i * 0.2) * 40 + (_random.nextDouble() - 0.5) * 30;
          break;
        case 'mountains':
          heightChange = sin(i * 0.15) * 60 + cos(i * 0.3) * 30 + (_random.nextDouble() - 0.5) * 40;
          break;
        case 'desert':
          heightChange = sin(i * 0.1) * 20 + (_random.nextDouble() - 0.5) * 15;
          break;
        case 'valley':
          heightChange = cos(i * 0.25) * 50 + (_random.nextDouble() - 0.5) * 25;
          break;
        case 'snow':
          heightChange = sin(i * 0.18) * 45 + cos(i * 0.25) * 25 + (_random.nextDouble() - 0.5) * 35;
          break;
        case 'night':
          heightChange = sin(i * 0.12) * 50 + (_random.nextDouble() - 0.5) * 30;
          break;
      }

      startY += heightChange * 0.25;
      startY = startY.clamp(200.0, 450.0);
    }
  }

  void extendTerrain() {
    currentSegment++;
    generateSegment(currentSegment);
  }

  void forceNextSegment() {
    currentSegment++;
  }

  double getHeightAt(double x) {
    for (int i = 0; i < points.length - 1; i++) {
      if (x >= points[i].dx && x <= points[i + 1].dx) {
        double t = (x - points[i].dx) / (points[i + 1].dx - points[i].dx);
        return points[i].dy + (points[i + 1].dy - points[i].dy) * t;
      }
    }

    if (points.isNotEmpty && x > points.last.dx - 2000) {
      extendTerrain();
      return getHeightAt(x);
    }

    return points.isNotEmpty ? points.last.dy : 200.0;
  }

  double getSlopeAt(double x) {
    for (int i = 0; i < points.length - 1; i++) {
      if (x >= points[i].dx && x <= points[i + 1].dx) {
        double dy = points[i + 1].dy - points[i].dy;
        double dx = points[i + 1].dx - points[i].dx;
        return atan2(dy, dx);
      }
    }
    return 0;
  }

  String getCurrentTerrainType() {
    return terrainTypes[currentSegment % terrainTypes.length];
  }

  bool isNightTheme() {
    return getCurrentTerrainType() == 'night';
  }

  bool isSnowTheme() {
    return getCurrentTerrainType() == 'snow';
  }
}

enum ObstacleType {
  rock,
  tree,
  spike,
  barrel,
}

class ObstacleModel {
  final Offset position;
  final ObstacleType type;
  final double width;
  final double height;

  ObstacleModel({
    required this.position,
    required this.type,
    required this.width,
    required this.height,
  });

  bool collidesWith(double vehicleX, double vehicleY, double vehicleRadius) {
    double obstacleX = position.dx + width / 2;
    double obstacleY = position.dy + height / 2;
    double obstacleRadius = max(width, height) / 2;

    double dx = vehicleX - obstacleX;
    double dy = vehicleY - obstacleY;
    double distance = sqrt(dx * dx + dy * dy);

    return distance < (vehicleRadius + obstacleRadius * 0.7);
  }
}