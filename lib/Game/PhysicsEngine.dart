import 'dart:math';
import '../Models/Terian.dart';
import '../Models/Vehical.dart';

class PhysicsEngine {
  static const double gravity = 0.5;
  static const double acceleration = 0.3;
  static const double reverseForce = 0.25;
  static const double airResistance = 0.99;
  static const double groundFriction = 0.94;
  static const double rotationDamping = 0.92;
  static const double maxSpeed = 10.0;
  static const double maxReverseSpeed = 5.0;
  static const double jumpForce = -12.0;
  static const double groundThreshold = 5.0;

  bool canJump = true;

  void update(Vehicle vehicle, Terrain terrain, bool isAccelerating, bool isReversing, bool isJumping) {
    // Apply gravity
    vehicle.velocityY += gravity;

    // Get terrain height at vehicle center
    double groundY = terrain.getHeightAt(vehicle.x);
    double distanceToGround = vehicle.y - groundY;

    // Check if on ground
    bool onGround = distanceToGround.abs() < groundThreshold && vehicle.velocityY >= -1;

    if (onGround) {
      // Place vehicle on ground
      vehicle.y = groundY;
      vehicle.velocityY = 0;
      canJump = true;

      // Get front and rear wheel positions for rotation
      double frontWheelX = vehicle.x + 20;
      double rearWheelX = vehicle.x - 20;
      double frontGroundY = terrain.getHeightAt(frontWheelX);
      double rearGroundY = terrain.getHeightAt(rearWheelX);

      // Calculate target rotation based on terrain slope
      double slopeDy = frontGroundY - rearGroundY;
      double slopeDx = 40;
      double targetRotation = atan2(slopeDy, slopeDx);

      // Smooth rotation transition
      double rotationDiff = targetRotation - vehicle.rotation;
      while (rotationDiff > pi) rotationDiff -= 2 * pi;
      while (rotationDiff < -pi) rotationDiff += 2 * pi;
      vehicle.rotation += rotationDiff * 0.15;

      // Apply acceleration
      if (isAccelerating) {
        vehicle.velocityX += acceleration;
      }

      // Apply reverse
      if (isReversing) {
        vehicle.velocityX -= reverseForce;
      }

      // Jump
      if (isJumping && canJump) {
        vehicle.velocityY = jumpForce;
        canJump = false;
      }

      // Ground friction
      vehicle.velocityX *= groundFriction;

      // Slope gravity effect
      double slope = terrain.getSlopeAt(vehicle.x);
      vehicle.velocityX -= sin(slope) * 0.25;

      // Reset angular velocity on ground
      vehicle.angularVelocity *= 0.3;
    } else {
      // Air physics
      vehicle.velocityX *= airResistance;

      // Rotation in air based on controls
      if (isAccelerating) {
        vehicle.angularVelocity -= 0.002;
      } else if (isReversing) {
        vehicle.angularVelocity += 0.002;
      }

      vehicle.rotation += vehicle.angularVelocity;
      vehicle.angularVelocity *= rotationDamping;
    }

    // Limit max speed (both forward and reverse)
    vehicle.velocityX = vehicle.velocityX.clamp(-maxReverseSpeed, maxSpeed);

    // Update position
    vehicle.x += vehicle.velocityX;
    vehicle.y += vehicle.velocityY;

    // Prevent vehicle from going below terrain
    if (vehicle.y > groundY) {
      vehicle.y = groundY;
      vehicle.velocityY = 0;
    }

    // Allow limited backward movement
    if (vehicle.x < 30) {
      vehicle.x = 30;
      vehicle.velocityX = 0;
    }
  }
}