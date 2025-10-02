import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Game/Game_Controller.dart';
import '../Widget/GameCanvas.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  late GameController controller;

  @override
  void initState() {
    super.initState();

    // Lock to landscape orientation
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    controller = GameController(
      onUpdate: () {
        if (mounted) {
          setState(() {});
        }
      },
    );

    controller.start();
  }

  @override
  void dispose() {
    controller.dispose();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Game Canvas
          GameCanvas(controller: controller),

          // Game Over Overlay
          if (controller.isGameOver) _buildGameOverOverlay(),

          // HUD - Top Stats
          _buildHUD(),

          // Controls
          _buildControls(),
        ],
      ),
    );
  }

  Widget _buildHUD() {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left side stats
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildStatCard(
                  icon: Icons.straighten,
                  label: 'Distance',
                  value: '${controller.distance.toInt()}m',
                  color: Colors.blue,
                ),
                const SizedBox(height: 8),
                _buildStatCard(
                  icon: Icons.monetization_on,
                  label: 'Coins',
                  value: '${controller.coins}',
                  color: Colors.amber,
                ),
              ],
            ),

            // Right side stats
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _buildFuelBar(),
                const SizedBox(height: 8),
                _buildStatCard(
                  icon: Icons.speed,
                  label: 'Speed',
                  value: '${(controller.vehicle.velocityX * 10).toInt()} km/h',
                  color: Colors.green,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.5), width: 2),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFuelBar() {
    return Container(
      width: 150,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: controller.fuel > 30
              ? Colors.green.withOpacity(0.5)
              : Colors.red.withOpacity(0.5),
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Icon(
                Icons.local_gas_station,
                color: controller.fuel > 30 ? Colors.green : Colors.red,
                size: 18,
              ),
              const SizedBox(width: 6),
              Text(
                'FUEL: ${controller.fuel.toInt()}%',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: controller.fuel / 100,
              minHeight: 8,
              backgroundColor: Colors.grey.shade800,
              valueColor: AlwaysStoppedAnimation<Color>(
                controller.fuel > 30 ? Colors.green : Colors.red,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildControls() {
    return Stack(
      children: [
        // Left side - Brake Button
        Positioned(
          left: 30,
          bottom: 40,
          child: GestureDetector(
            onTapDown: (_) => setState(() => controller.isBraking = true),
            onTapUp: (_) => setState(() => controller.isBraking = false),
            onTapCancel: () => setState(() => controller.isBraking = false),
            child: _buildControlButton(
              icon: Icons.arrow_back,
              label: 'BRAKE',
              color: Colors.red,
              isPressed: controller.isBraking,
            ),
          ),
        ),

        // Right side - Gas Button
        Positioned(
          right: 30,
          bottom: 40,
          child: GestureDetector(
            onTapDown: (_) => setState(() => controller.isAccelerating = true),
            onTapUp: (_) => setState(() => controller.isAccelerating = false),
            onTapCancel: () => setState(() => controller.isAccelerating = false),
            child: _buildControlButton(
              icon: Icons.arrow_forward,
              label: 'GAS',
              color: Colors.green,
              isPressed: controller.isAccelerating,
            ),
          ),
        ),

        // Right side - Jump Button (above gas)
        Positioned(
          right: 30,
          bottom: 150,
          child: GestureDetector(
            onTap: () => controller.jump(),
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
    bool isPressed = false,
  }) {
    return AnimatedScale(
      scale: isPressed ? 0.9 : 1.0,
      duration: const Duration(milliseconds: 100),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: isPressed
                ? [
              color.withOpacity(1.0),
              color.withOpacity(0.8),
            ]
                : [
              color.withOpacity(0.8),
              color.withOpacity(0.6),
            ],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isPressed ? 0.7 : 0.5),
              blurRadius: isPressed ? 20 : 15,
              spreadRadius: isPressed ? 3 : 2,
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
            SizedBox(height: size * 0.05),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.13,
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
      ),
    );
  }

  Widget _buildGameOverOverlay() {
    return Container(
      color: Colors.black.withOpacity(0.8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.all(32),
          margin: const EdgeInsets.symmetric(horizontal: 40),
          decoration: BoxDecoration(
            color: const Color(0xFF1a1a1a),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.red.withOpacity(0.5), width: 3),
            boxShadow: [
              BoxShadow(
                color: Colors.red.withOpacity(0.3),
                blurRadius: 30,
                spreadRadius: 5,
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                Icons.sports_score,
                color: Colors.red,
                size: 80,
              ),
              const SizedBox(height: 16),
              const Text(
                'GAME OVER',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 42,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 24),
              _buildGameOverStat('Distance', '${controller.distance.toInt()}m', Icons.straighten),
              const SizedBox(height: 12),
              _buildGameOverStat('Coins', '${controller.coins}', Icons.monetization_on),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    controller.restart();
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.refresh, size: 28),
                    SizedBox(width: 12),
                    Text(
                      'RESTART',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGameOverStat(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.3),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: Colors.white70, size: 24),
              const SizedBox(width: 12),
              Text(
                label,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 18,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}