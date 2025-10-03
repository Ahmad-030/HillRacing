import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../Game/Game_Controller.dart';
import '../Game/GameOver.dart';
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

  void _showPauseDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.9),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: Colors.orange, width: 2),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'PAUSED',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    controller.togglePause();
                  });
                },
                icon: const Icon(Icons.play_arrow),
                label: const Text('RESUME'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  setState(() {
                    controller.restart();
                  });
                },
                icon: const Icon(Icons.refresh),
                label: const Text('RESTART'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.exit_to_app),
                label: const Text('EXIT'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Game Canvas
          GameCanvas(controller: controller),

          // Game Over Overlay
          if (controller.isGameOver)
            GameOverScreen(
              distance: controller.distance,
              coins: controller.coins,
              onRestart: () {
                setState(() {
                  controller.restart();
                });
              },
            ),

          // HUD - Top Stats
          if (!controller.isGameOver) _buildHUD(),

          // Controls
          if (!controller.isGameOver && !controller.isPaused) _buildControls(),
        ],
      ),
    );
  }

  Widget _buildHUD() {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 700;
          final statPadding = isSmallScreen ? 6.0 : 12.0;

          return Padding(
            padding: EdgeInsets.all(statPadding),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Left side stats
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildStatCard(
                      icon: Icons.straighten,
                      label: 'Distance',
                      value: '${controller.distance.toInt()}m',
                      color: Colors.blue,
                      isSmall: isSmallScreen,
                    ),
                    SizedBox(height: isSmallScreen ? 5 : 7),
                    _buildStatCard(
                      icon: Icons.monetization_on,
                      label: 'Coins',
                      value: '${controller.coins}',
                      color: Colors.amber,
                      isSmall: isSmallScreen,
                    ),
                  ],
                ),

                // Center - Pause Button
                GestureDetector(
                  onTap: () {
                    setState(() {
                      controller.togglePause();
                    });
                    _showPauseDialog();
                  },
                  child: Container(
                    padding: EdgeInsets.all(isSmallScreen ? 8 : 10),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.65),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.orange, width: 2),
                    ),
                    child: Icon(
                      Icons.pause,
                      color: Colors.orange,
                      size: isSmallScreen ? 20 : 24,
                    ),
                  ),
                ),

                // Right side stats
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFuelBar(isSmall: isSmallScreen),
                    SizedBox(height: isSmallScreen ? 5 : 7),
                    _buildStatCard(
                      icon: Icons.speed,
                      label: 'Speed',
                      value: '${(controller.vehicle.velocityX * 10).toInt()}',
                      color: Colors.green,
                      isSmall: isSmallScreen,
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
    bool isSmall = false,
  }) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: isSmall ? 7 : 10,
        vertical: isSmall ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(isSmall ? 7 : 10),
        border: Border.all(color: color.withOpacity(0.6), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: color.withOpacity(0.3),
            blurRadius: 6,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: isSmall ? 14 : 18),
          SizedBox(width: isSmall ? 5 : 7),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.75),
                  fontSize: isSmall ? 7 : 9,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmall ? 12 : 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFuelBar({bool isSmall = false}) {
    return Container(
      width: isSmall ? 110 : 140,
      padding: EdgeInsets.all(isSmall ? 5 : 7),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.65),
        borderRadius: BorderRadius.circular(isSmall ? 7 : 10),
        border: Border.all(
          color: controller.fuel > 30
              ? Colors.green.withOpacity(0.6)
              : Colors.red.withOpacity(0.6),
          width: 1.5,
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
                size: isSmall ? 13 : 16,
              ),
              SizedBox(width: isSmall ? 4 : 5),
              Text(
                'FUEL: ${controller.fuel.toInt()}%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmall ? 9 : 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmall ? 3 : 5),
          ClipRRect(
            borderRadius: BorderRadius.circular(5),
            child: LinearProgressIndicator(
              value: controller.fuel / 100,
              minHeight: isSmall ? 5 : 7,
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
    return LayoutBuilder(
      builder: (context, constraints) {
        final isSmallScreen = constraints.maxWidth < 700;
        final buttonSize = isSmallScreen ? 60.0 : 75.0;
        final jumpSize = isSmallScreen ? 55.0 : 65.0;
        final bottomPadding = isSmallScreen ? 18.0 : 25.0;
        final sidePadding = isSmallScreen ? 12.0 : 20.0;

        return Stack(
          children: [
            // Left side - Jump
            Positioned(
              left: sidePadding,
              bottom: bottomPadding,
              child: GestureDetector(
                onTap: () => controller.jump(),
                child: _buildControlButton(
                  icon: Icons.arrow_upward,
                  label: 'JUMP',
                  color: Colors.blue,
                  size: jumpSize,
                ),
              ),
            ),

            // Right side - Reverse and Gas together
            Positioned(
              right: sidePadding,
              bottom: bottomPadding,
              child: Row(
                children: [
                  // Reverse
                  GestureDetector(
                    onTapDown: (_) => setState(() => controller.isReversing = true),
                    onTapUp: (_) => setState(() => controller.isReversing = false),
                    onTapCancel: () => setState(() => controller.isReversing = false),
                    child: _buildControlButton(
                      icon: Icons.arrow_back,
                      label: 'REV',
                      color: Colors.orange,
                      size: buttonSize,
                      isPressed: controller.isReversing,
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Gas
                  GestureDetector(
                    onTapDown: (_) => setState(() => controller.isAccelerating = true),
                    onTapUp: (_) => setState(() => controller.isAccelerating = false),
                    onTapCancel: () => setState(() => controller.isAccelerating = false),
                    child: _buildControlButton(
                      icon: Icons.arrow_forward,
                      label: 'GAS',
                      color: Colors.green,
                      size: buttonSize,
                      isPressed: controller.isAccelerating,
                    ),
                  ),
                ],
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
    bool isPressed = false,
  }) {
    return AnimatedScale(
      scale: isPressed ? 0.88 : 1.0,
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
              color.withOpacity(0.85),
            ]
                : [
              color.withOpacity(0.95),
              color.withOpacity(0.75),
              color.withOpacity(0.55),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isPressed ? 0.7 : 0.6),
              blurRadius: isPressed ? 18 : 16,
              spreadRadius: isPressed ? 2 : 1,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
          border: Border.all(
            color: Colors.white.withOpacity(0.45),
            width: 2.5,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: size * 0.42,
            ),
            SizedBox(height: size * 0.04),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontSize: size * 0.13,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.5,
                shadows: [
                  Shadow(
                    color: Colors.black.withOpacity(0.7),
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
}