import 'package:flutter/material.dart';

class GameControls extends StatelessWidget {
  final VoidCallback onAccelerate;
  final VoidCallback onBrake;
  final VoidCallback onJump;
  final VoidCallback onAccelerateRelease;
  final VoidCallback onBrakeRelease;

  const GameControls({
    Key? key,
    required this.onAccelerate,
    required this.onBrake,
    required this.onJump,
    required this.onAccelerateRelease,
    required this.onBrakeRelease,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Left side - Brake (Back/Reverse)
        Positioned(
          left: 30,
          bottom: 40,
          child: GestureDetector(
            onTapDown: (_) => onBrake(),
            onTapUp: (_) => onBrakeRelease(),
            onTapCancel: onBrakeRelease,
            child: _buildControlButton(
              icon: Icons.arrow_back,
              label: 'BRAKE',
              color: Colors.red,
            ),
          ),
        ),

        // Right side - Accelerate (Forward)
        Positioned(
          right: 30,
          bottom: 40,
          child: GestureDetector(
            onTapDown: (_) => onAccelerate(),
            onTapUp: (_) => onAccelerateRelease(),
            onTapCancel: onAccelerateRelease,
            child: _buildControlButton(
              icon: Icons.arrow_forward,
              label: 'GAS',
              color: Colors.green,
            ),
          ),
        ),

        // Right side - Jump (Above accelerate)
        Positioned(
          right: 30,
          bottom: 150,
          child: GestureDetector(
            onTap: onJump,
            child: _buildControlButton(
              icon: Icons.arrow_upward,
              label: 'JUMP',
              color: Colors.blue,
              size: 70,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    double size = 90,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.8),
            color.withOpacity(0.6),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.5),
            blurRadius: 15,
            spreadRadius: 2,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.3),
          width: 3,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: size * 0.4,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.12,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.5),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// How to use in your game screen:
/*
GameControls(
  onAccelerate: () {
    setState(() => controller.isAccelerating = true);
  },
  onAccelerateRelease: () {
    setState(() => controller.isAccelerating = false);
  },
  onBrake: () {
    setState(() => controller.isBraking = true);
  },
  onBrakeRelease: () {
    setState(() => controller.isBraking = false);
  },
  onJump: () {
    controller.jump();
  },
)
*/