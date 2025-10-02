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
          if (!controller.isGameOver) _buildHUD(),

          // Controls
          if (!controller.isGameOver) _buildControls(),
        ],
      ),
    );
  }

  Widget _buildHUD() {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 700;
          final statPadding = isSmallScreen ? 8.0 : 16.0;

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
                    SizedBox(height: isSmallScreen ? 6 : 8),
                    _buildStatCard(
                      icon: Icons.monetization_on,
                      label: 'Coins',
                      value: '${controller.coins}',
                      color: Colors.amber,
                      isSmall: isSmallScreen,
                    ),
                  ],
                ),

                // Right side stats
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    _buildFuelBar(isSmall: isSmallScreen),
                    SizedBox(height: isSmallScreen ? 6 : 8),
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
        horizontal: isSmall ? 8 : 12,
        vertical: isSmall ? 6 : 8,
      ),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(isSmall ? 8 : 12),
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
          Icon(icon, color: color, size: isSmall ? 16 : 20),
          SizedBox(width: isSmall ? 6 : 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: isSmall ? 8 : 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                value,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmall ? 13 : 16,
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
      width: isSmall ? 120 : 150,
      padding: EdgeInsets.all(isSmall ? 6 : 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.6),
        borderRadius: BorderRadius.circular(isSmall ? 8 : 12),
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
                size: isSmall ? 14 : 18,
              ),
              SizedBox(width: isSmall ? 4 : 6),
              Text(
                'FUEL: ${controller.fuel.toInt()}%',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: isSmall ? 10 : 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          SizedBox(height: isSmall ? 4 : 6),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: controller.fuel / 100,
              minHeight: isSmall ? 6 : 8,
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
        final buttonSize = isSmallScreen ? 70.0 : 85.0;
        final jumpSize = isSmallScreen ? 60.0 : 70.0;
        final bottomPadding = isSmallScreen ? 25.0 : 35.0;
        final sidePadding = isSmallScreen ? 20.0 : 30.0;

        return Stack(
          children: [
            // Left side - Brake and Gas together
            Positioned(
              left: sidePadding,
              bottom: bottomPadding,
              child: Row(
                children: [
                  // Brake
                  GestureDetector(
                    onTapDown: (_) => setState(() => controller.isBraking = true),
                    onTapUp: (_) => setState(() => controller.isBraking = false),
                    onTapCancel: () => setState(() => controller.isBraking = false),
                    child: _buildControlButton(
                      icon: Icons.arrow_back,
                      label: 'BRAKE',
                      color: Colors.red,
                      size: buttonSize,
                      isPressed: controller.isBraking,
                    ),
                  ),
                  const SizedBox(width: 12),
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

            // Right side - Jump
            Positioned(
              right: sidePadding,
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
              color.withOpacity(0.9),
              color.withOpacity(0.7),
              color.withOpacity(0.5),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(isPressed ? 0.7 : 0.6),
              blurRadius: isPressed ? 20 : 18,
              spreadRadius: isPressed ? 3 : 2,
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 8,
              offset: const Offset(0, 4),
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
                    blurRadius: 5,
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
      color: Colors.black.withOpacity(0.9),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isSmallScreen = constraints.maxWidth < 700;
          final titleSize = isSmallScreen ? 32.0 : 42.0;
          final iconSize = isSmallScreen ? 60.0 : 80.0;
          final statFontSize = isSmallScreen ? 16.0 : 18.0;
          final valueFontSize = isSmallScreen ? 20.0 : 24.0;
          final containerWidth = isSmallScreen
              ? constraints.maxWidth * 0.85
              : constraints.maxWidth * 0.5;

          return Center(
            child: SingleChildScrollView(
              child: Container(
                width: containerWidth,
                padding: EdgeInsets.all(isSmallScreen ? 20 : 32),
                margin: EdgeInsets.symmetric(
                  horizontal: isSmallScreen ? 20 : 40,
                  vertical: 20,
                ),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      const Color(0xFF1a1a1a),
                      const Color(0xFF0d0d0d),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.red.withOpacity(0.6), width: 3),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 30,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Animated Icon
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 600),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              gradient: RadialGradient(
                                colors: [
                                  Colors.red.withOpacity(0.3),
                                  Colors.transparent,
                                ],
                              ),
                            ),
                            child: Icon(
                              Icons.warning_rounded,
                              color: Colors.red,
                              size: iconSize,
                            ),
                          ),
                        );
                      },
                    ),

                    SizedBox(height: isSmallScreen ? 12 : 16),

                    // Title
                    Text(
                      'GAME OVER',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 3,
                        shadows: [
                          Shadow(
                            color: Colors.red.withOpacity(0.8),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? 8 : 12),

                    Text(
                      'Better luck next time!',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: isSmallScreen ? 14 : 16,
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? 20 : 24),

                    // Stats
                    _buildGameOverStat(
                      'Distance',
                      '${controller.distance.toInt()}m',
                      Icons.straighten,
                      Colors.blue,
                      statFontSize,
                      valueFontSize,
                    ),
                    SizedBox(height: isSmallScreen ? 10 : 12),
                    _buildGameOverStat(
                      'Coins',
                      '${controller.coins}',
                      Icons.monetization_on,
                      Colors.amber,
                      statFontSize,
                      valueFontSize,
                    ),

                    SizedBox(height: isSmallScreen ? 24 : 32),

                    // Restart Button
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          controller.restart();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: EdgeInsets.symmetric(
                          horizontal: isSmallScreen ? 32 : 48,
                          vertical: isSmallScreen ? 12 : 16,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 8,
                        shadowColor: Colors.green.withOpacity(0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.refresh, size: isSmallScreen ? 22 : 28),
                          SizedBox(width: isSmallScreen ? 8 : 12),
                          Text(
                            'RESTART',
                            style: TextStyle(
                              fontSize: isSmallScreen ? 18 : 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
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
        },
      ),
    );
  }

  Widget _buildGameOverStat(
      String label,
      String value,
      IconData icon,
      Color color,
      double labelSize,
      double valueSize,
      ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1.5,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(icon, color: color, size: 20),
              ),
              const SizedBox(width: 12),
              Text(
                label,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: labelSize,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: TextStyle(
              color: Colors.white,
              fontSize: valueSize,
              fontWeight: FontWeight.bold,
              shadows: [
                Shadow(
                  color: color.withOpacity(0.5),
                  blurRadius: 8,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}