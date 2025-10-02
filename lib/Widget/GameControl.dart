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
    return LayoutBuilder(
      builder: (context, constraints) {
        // Responsive sizing based on screen width
        final screenWidth = constraints.maxWidth;
        final buttonSize = screenWidth < 400 ? 70.0 : 85.0;
        final jumpSize = screenWidth < 400 ? 65.0 : 75.0;
        final bottomPadding = screenWidth < 400 ? 30.0 : 40.0;
        final sidePadding = screenWidth < 400 ? 20.0 : 30.0;

        return Stack(
          children: [
            // Left side controls (Brake and Gas together)
            Positioned(
              left: sidePadding,
              bottom: bottomPadding,
              child: Row(
                children: [
                  // Brake button
                  GestureDetector(
                    onTapDown: (_) => onBrake(),
                    onTapUp: (_) => onBrakeRelease(),
                    onTapCancel: onBrakeRelease,
                    child: _buildControlButton(
                      icon: Icons.arrow_back,
                      label: 'BRAKE',
                      color: Colors.red,
                      size: buttonSize,
                    ),
                  ),
                  const SizedBox(width: 15),
                  // Gas button
                  GestureDetector(
                    onTapDown: (_) => onAccelerate(),
                    onTapUp: (_) => onAccelerateRelease(),
                    onTapCancel: onAccelerateRelease,
                    child: _buildControlButton(
                      icon: Icons.arrow_forward,
                      label: 'GAS',
                      color: Colors.green,
                      size: buttonSize,
                    ),
                  ),
                ],
              ),
            ),

            // Right side - Jump button
            Positioned(
              right: sidePadding,
              bottom: bottomPadding,
              child: GestureDetector(
                onTap: onJump,
                child: _buildControlButton(
                  icon: Icons.arrow_upward,
                  label: 'JUMP',
                  color: Colors.blue,
                  size: jumpSize,
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required Color color,
    required double size,
  }) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            color.withOpacity(0.9),
            color.withOpacity(0.7),
            color.withOpacity(0.5),
          ],
          stops: const [0.0, 0.7, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.6),
            blurRadius: 20,
            spreadRadius: 3,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.4),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
        border: Border.all(
          color: Colors.white.withOpacity(0.4),
          width: 3,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            color: Colors.white,
            size: size * 0.45,
            shadows: [
              Shadow(
                color: Colors.black.withOpacity(0.5),
                blurRadius: 4,
              ),
            ],
          ),
          SizedBox(height: size * 0.05),
          Text(
            label,
            style: TextStyle(
              color: Colors.white,
              fontSize: size * 0.14,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
              shadows: [
                Shadow(
                  color: Colors.black.withOpacity(0.7),
                  blurRadius: 6,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}