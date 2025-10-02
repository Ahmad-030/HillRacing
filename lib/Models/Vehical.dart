import 'dart:math';

class Vehicle {
  double x;
  double y;
  double velocityX;
  double velocityY;
  double rotation;
  double angularVelocity;

  final double width = 60;
  final double height = 40;
  final double wheelRadius = 15;
  final double wheelBase = 40;

  double targetRotation = 0;

  Vehicle({
    this.x = 100,
    this.y = 300,  // Changed from 200 to 300 to match terrain
    this.velocityX = 0,
    this.velocityY = 0,
    this.rotation = 0,
    this.angularVelocity = 0,
  });

  void reset() {
    x = 100;
    y = 300;  // Changed from 200 to 300
    velocityX = 0;
    velocityY = 0;
    rotation = 0;
    angularVelocity = 0;
    targetRotation = 0;
  }

  double getFrontWheelX() => x + cos(rotation) * 20;
  double getFrontWheelY() => y + sin(rotation) * 20;

  double getRearWheelX() => x - cos(rotation) * 20;
  double getRearWheelY() => y - sin(rotation) * 20;
}