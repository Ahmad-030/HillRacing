import 'dart:math';
import 'package:flutter/material.dart';

class Terrain {
  final List<Offset> points = [];
  final List<Offset> coins = [];
  final List<Offset> fuelCans = [];
  final Random _random = Random();

  int currentSegment = 0;
  final List<String> terrainTypes = ['hills', 'mountains', 'desert', 'valley', 'snow', 'night'];

  Terrain() {
    generate();
  }

  void generate() {
    points.clear();
    coins.clear();
    fuelCans.clear();
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
      if (i % 4 == 0 && _random.nextDouble() > 0.6) {
        coins.add(Offset(startX, startY - 60 - _random.nextDouble() * 40));
      }

      // Add fuel cans less frequently
      if (i % 8 == 0 && _random.nextDouble() > 0.7) {
        fuelCans.add(Offset(startX, startY - 50 - _random.nextDouble() * 30));
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

      // Keep terrain on screen - adjusted range
      startY = startY.clamp(200.0, 450.0);
    }
  }

  void extendTerrain() {
    currentSegment++;
    generateSegment(currentSegment);
  }

  double getHeightAt(double x) {
    // Find the segment containing x
    for (int i = 0; i < points.length - 1; i++) {
      if (x >= points[i].dx && x <= points[i + 1].dx) {
        double t = (x - points[i].dx) / (points[i + 1].dx - points[i].dx);
        return points[i].dy + (points[i + 1].dy - points[i].dy) * t;
      }
    }

    // FIXED: If beyond current terrain, extend it automatically
    if (points.isNotEmpty && x > points.last.dx - 2000) {
      extendTerrain();
      // Recursively call to get the height at the new extended terrain
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