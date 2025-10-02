import 'dart:async';
import '../Models/Terian.dart';
import '../Models/Vehical.dart';
import 'PhysicsEngine.dart';

class GameController {
  final Vehicle vehicle = Vehicle();
  final Terrain terrain = Terrain();
  final PhysicsEngine physics = PhysicsEngine();

  Timer? _gameTimer;
  final Function onUpdate;

  bool isAccelerating = false;
  bool isBraking = false;
  bool isJumping = false;
  bool isGameOver = false;
  bool gameOverShown = false;

  double fuel = 100.0;
  double distance = 0.0;
  int coins = 0;

  int frameCount = 0;
  double maxDistanceReached = 0;

  GameController({required this.onUpdate});

  void start() {
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (isGameOver) return;
      _update();
      onUpdate();
    });
  }

  void _update() {
    frameCount++;

    // Consume fuel
    if (isAccelerating && fuel > 0) {
      fuel -= 0.10;
    }

    // Passive fuel consumption
    fuel -= 0.02;

    if (fuel <= 0) {
      fuel = 0;
      isGameOver = true;
      return;
    }

    // Update physics with jump
    physics.update(vehicle, terrain, isAccelerating && fuel > 0, isBraking, isJumping);

    // Reset jump after applied
    if (isJumping) {
      Future.delayed(const Duration(milliseconds: 100), () {
        isJumping = false;
      });
    }

    // Update distance
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
    if (vehicle.velocityX < 0.1 && frameCount % 180 == 0 && distance > 10) {
      vehicle.velocityX += 1.0;
    }
  }

  void jump() {
    isJumping = true;
  }

  void restart() {
    vehicle.reset();
    terrain.generate();
    fuel = 100;
    distance = 0;
    coins = 0;
    isGameOver = false;
    gameOverShown = false;
    isAccelerating = false;
    isBraking = false;
    isJumping = false;
    frameCount = 0;
    physics.canJump = true;
  }

  void dispose() {
    _gameTimer?.cancel();
  }
}