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
  bool isReversing = false;
  bool isJumping = false;
  bool isGameOver = false;
  bool gameOverShown = false;
  bool isPaused = false;

  double fuel = 100.0;
  double distance = 0.0;
  int coins = 0;

  int frameCount = 0;
  double maxDistanceReached = 0;

  // Terrain change timer (15 seconds = 900 frames at 60fps)
  int terrainChangeCounter = 0;
  final int terrainChangeInterval = 900; // 15 seconds

  GameController({required this.onUpdate}) {
    _initializeVehiclePosition();
  }

  void _initializeVehiclePosition() {
    double groundHeight = terrain.getHeightAt(vehicle.x);
    vehicle.y = groundHeight;
    vehicle.velocityY = 0;
  }

  void start() {
    _gameTimer = Timer.periodic(const Duration(milliseconds: 16), (timer) {
      if (isGameOver || isPaused) return;
      _update();
      onUpdate();
    });
  }

  void togglePause() {
    isPaused = !isPaused;
    onUpdate();
  }

  void _update() {
    frameCount++;
    terrainChangeCounter++;

    // Change terrain every 15 seconds
    if (terrainChangeCounter >= terrainChangeInterval) {
      terrainChangeCounter = 0;
      terrain.forceNextSegment();
    }

    // REDUCED FUEL CONSUMPTION - Only when actively using controls
    if (isAccelerating && fuel > 0) {
      fuel -= 0.05; // Reduced from 0.10
    }

    if (isReversing && fuel > 0) {
      fuel -= 0.08; // Reduced from 0.15
    }

    // Minimal passive fuel consumption
    fuel -= 0.01; // Reduced from 0.02

    if (fuel <= 0) {
      fuel = 0;
      isGameOver = true;
      return;
    }

    // Update physics
    physics.update(vehicle, terrain, isAccelerating && fuel > 0, isReversing && fuel > 0, isJumping);

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
        fuel = (fuel + 5).clamp(0.0, 100.0); // Increased reward from 3 to 5
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
        fuel = (fuel + 25).clamp(0.0, 100.0); // Increased from 20 to 25
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
    if (!isPaused) {
      isJumping = true;
    }
  }

  void restart() {
    vehicle.reset();
    terrain.generate();
    _initializeVehiclePosition();

    fuel = 100;
    distance = 0;
    coins = 0;
    isGameOver = false;
    gameOverShown = false;
    isAccelerating = false;
    isReversing = false;
    isJumping = false;
    isPaused = false;
    frameCount = 0;
    terrainChangeCounter = 0; // Reset terrain timer
    physics.canJump = true;
  }

  void dispose() {
    _gameTimer?.cancel();
  }
}