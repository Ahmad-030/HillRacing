import 'dart:async';
import 'package:hillclimb/Models/Obstacle.dart';

import '../Game/PhysicsEngine.dart';
import '../Models/Terian.dart';
import '../Models/Vehical.dart';

class GameController {
  final Vehicle vehicle = Vehicle();
  final TerrainModels terrain = TerrainModels();
  final PhysicsEngine physics = PhysicsEngine();

  Timer? _gameTimer;
  final Function onUpdate;

  bool isAccelerating = false;
  bool isReversing = false;
  bool isJumping = false;
  bool isGameOver = false;
  bool gameOverShown = false;

  double fuel = 100.0;
  double distance = 0.0;
  int coins = 0;

  int frameCount = 0;
  double maxDistanceReached = 0;

  GameController({required this.onUpdate}) {
    // Initialize vehicle position based on terrain
    _initializeVehiclePosition();
  }

  void _initializeVehiclePosition() {
    // Get the terrain height at the starting position and place vehicle there
    double groundHeight = terrain.getHeightAt(vehicle.x);
    vehicle.y = groundHeight;
    vehicle.velocityY = 0;
  }

  void start() {
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (isGameOver) return;
      _update();
      onUpdate();
    });
  }

  void _update() {
    frameCount++;

    // Only consume fuel when actively accelerating or reversing (not on idle)
    if (isAccelerating && fuel > 0 && vehicle.velocityX < 9.5) {
      fuel -= 0.08;
    }

    // Reversing consumes more fuel
    if (isReversing && fuel > 0 && vehicle.velocityX > -4.5) {
      fuel -= 0.12;
    }

    // No passive fuel consumption - only when using controls

    if (fuel <= 0) {
      fuel = 0;
      isGameOver = true;
      return;
    }

    // Update physics with jump and reverse
    physics.update(vehicle, terrain, isAccelerating && fuel > 0, isReversing && fuel > 0, isJumping);

    // Reset jump after applied
    if (isJumping) {
      Future.delayed(const Duration(milliseconds: 100), () {
        isJumping = false;
      });
    }

    // Update distance (only forward movement counts)
    if (vehicle.velocityX > 0) {
      distance += vehicle.velocityX * 0.1;
      if (distance > maxDistanceReached) {
        maxDistanceReached = distance;
      }
    }

    // Collect coins
    terrain.coins.removeWhere((coin) {
      double dx = vehicle.x - coin.dx;
      double dy = vehicle.y - coin.dy;
      double distanceToVehicle = dx * dx + dy * dy;

      if (distanceToVehicle < 1000) {
        coins++;
        fuel = (fuel + 3).clamp(0.0, 100.0);
        return true;
      }
      return false;
    });

    // Collect fuel cans
    terrain.fuelCans.removeWhere((fuelCan) {
      double dx = vehicle.x - fuelCan.dx;
      double dy = vehicle.y - fuelCan.dy;
      double distanceToVehicle = dx * dx + dy * dy;

      if (distanceToVehicle < 1000) {
        fuel = (fuel + 20).clamp(0.0, 100.0);
        return true;
      }
      return false;
    });

    // Check if flipped
    double normalizedRotation = vehicle.rotation % (2 * 3.14159);
    if (normalizedRotation > 3.14159) normalizedRotation -= 2 * 3.14159;
    if (normalizedRotation < -3.14159) normalizedRotation += 2 * 3.14159;

    if (normalizedRotation.abs() > 2.3) {
      isGameOver = true;
    }

    // Prevent getting stuck
    if (vehicle.velocityX.abs() < 0.1 && frameCount % 180 == 0 && distance > 10) {
      vehicle.velocityX += 1.0;
    }
  }

  void jump() {
    isJumping = true;
  }

  void restart() {
    vehicle.reset();
    terrain.generate();

    // Re-initialize vehicle position on new terrain
    _initializeVehiclePosition();

    fuel = 100;
    distance = 0;
    coins = 0;
    isGameOver = false;
    gameOverShown = false;
    isAccelerating = false;
    isReversing = false;
    isJumping = false;
    frameCount = 0;
    physics.canJump = true;
  }

  void dispose() {
    _gameTimer?.cancel();
  }
}