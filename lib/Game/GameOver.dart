import 'package:flutter/material.dart';

class GameOverScreen extends StatelessWidget {
  final double distance;
  final int coins;
  final VoidCallback onRestart;

  const GameOverScreen({
    Key? key,
    required this.distance,
    required this.coins,
    required this.onRestart,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Responsive sizing
        final titleSize = screenWidth < 400 ? 40.0 : 56.0;
        final subtitleSize = screenWidth < 400 ? 18.0 : 24.0;
        final statSize = screenWidth < 400 ? 28.0 : 36.0;
        final labelSize = screenWidth < 400 ? 14.0 : 16.0;
        final containerWidth = screenWidth < 400 ? screenWidth * 0.85 : 350.0;

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.85),
                Colors.black.withOpacity(0.95),
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Animated icon
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 800),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Transform.scale(
                          scale: value,
                          child: Container(
                            padding: const EdgeInsets.all(20),
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
                              size: screenWidth < 400 ? 70 : 90,
                              color: Colors.red,
                            ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 20),

                    // Game Over Title
                    Text(
                      'GAME OVER',
                      style: TextStyle(
                        fontSize: titleSize,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                        letterSpacing: 3,
                        shadows: [
                          Shadow(
                            color: Colors.red.withOpacity(0.8),
                            blurRadius: 20,
                          ),
                          const Shadow(
                            color: Colors.black,
                            blurRadius: 10,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 10),

                    Text(
                      'Better luck next time!',
                      style: TextStyle(
                        fontSize: subtitleSize,
                        color: Colors.grey[400],
                        fontWeight: FontWeight.w400,
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Stats container
                    Container(
                      width: containerWidth,
                      padding: EdgeInsets.all(screenWidth < 400 ? 20 : 30),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.05),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: Colors.white.withOpacity(0.1),
                          width: 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.3),
                            blurRadius: 20,
                            spreadRadius: 5,
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          // Distance stat
                          _buildStatRow(
                            icon: Icons.straighten,
                            iconColor: Colors.blue,
                            label: 'DISTANCE',
                            value: '${distance.toStringAsFixed(0)}m',
                            statSize: statSize,
                            labelSize: labelSize,
                          ),

                          SizedBox(height: screenWidth < 400 ? 20 : 30),

                          // Coins stat
                          _buildStatRow(
                            icon: Icons.monetization_on,
                            iconColor: Colors.amber,
                            label: 'COINS',
                            value: '$coins',
                            statSize: statSize,
                            labelSize: labelSize,
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 40),

                    // Restart button
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 1000),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double value, child) {
                        return Opacity(
                          opacity: value,
                          child: Transform.translate(
                            offset: Offset(0, 20 * (1 - value)),
                            child: child,
                          ),
                        );
                      },
                      child: ElevatedButton(
                        onPressed: onRestart,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(
                            horizontal: screenWidth < 400 ? 50 : 70,
                            vertical: screenWidth < 400 ? 18 : 22,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                          elevation: 10,
                          shadowColor: Colors.green.withOpacity(0.5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.refresh,
                              size: screenWidth < 400 ? 26 : 32,
                            ),
                            const SizedBox(width: 12),
                            Text(
                              'RESTART',
                              style: TextStyle(
                                fontSize: screenWidth < 400 ? 20 : 24,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 2,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatRow({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required double statSize,
    required double labelSize,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: 28,
              ),
            ),
            const SizedBox(width: 15),
            Text(
              label,
              style: TextStyle(
                fontSize: labelSize,
                color: Colors.grey[400],
                fontWeight: FontWeight.w600,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: statSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: iconColor.withOpacity(0.5),
                blurRadius: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// How to use in your game screen:
/*
if (controller.isGameOver && !controller.gameOverShown) {
  return Stack(
    children: [
      // Your game canvas
      GameCanvas(controller: controller),

      // Game over overlay
      GameOverScreen(
        distance: controller.distance,
        coins: controller.coins,
        onRestart: () {
          setState(() {
            controller.restart();
          });
        },
      ),
    ],
  );
}
*/