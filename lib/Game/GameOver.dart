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

        // Ultra responsive sizing
        final iconSize = (screenHeight * 0.10).clamp(35.0, 70.0);
        final titleSize = (screenHeight * 0.08).clamp(22.0, 40.0);
        final subtitleSize = (screenHeight * 0.035).clamp(10.0, 16.0);
        final statLabelSize = (screenHeight * 0.03).clamp(9.0, 13.0);
        final statValueSize = (screenHeight * 0.045).clamp(12.0, 18.0);
        final buttonTextSize = (screenHeight * 0.045).clamp(14.0, 20.0);
        final spacing = screenHeight * 0.015;

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.92),
                Colors.black.withOpacity(0.96),
              ],
            ),
          ),
          child: Center(
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: screenWidth * 0.05,
                vertical: screenHeight * 0.05,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animated icon
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: EdgeInsets.all(iconSize * 0.2),
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
                            size: iconSize,
                            color: Colors.red,
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: spacing * 2),

                  // Game Over Title
                  Text(
                    'GAME OVER',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                      shadows: [
                        Shadow(
                          color: Colors.red.withOpacity(0.8),
                          blurRadius: 15,
                        ),
                        const Shadow(
                          color: Colors.black,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: spacing),

                  Text(
                    'Better luck next time!',
                    style: TextStyle(
                      fontSize: subtitleSize,
                      color: Colors.grey[400],
                      fontWeight: FontWeight.w400,
                    ),
                  ),

                  SizedBox(height: spacing * 3),

                  // Stats container
                  Container(
                    width: (screenWidth * 0.7).clamp(250.0, 400.0),
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.025,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.1),
                        width: 1.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.3),
                          blurRadius: 15,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // Distance stat
                        _buildStatRow(
                          icon: Icons.straighten,
                          iconColor: Colors.blue,
                          label: 'DISTANCE',
                          value: '${distance.toStringAsFixed(0)}m',
                          statValueSize: statValueSize,
                          statLabelSize: statLabelSize,
                          iconSize: iconSize * 0.4,
                        ),

                        SizedBox(height: spacing * 2),

                        // Coins stat
                        _buildStatRow(
                          icon: Icons.monetization_on,
                          iconColor: Colors.amber,
                          label: 'COINS',
                          value: '$coins',
                          statValueSize: statValueSize,
                          statLabelSize: statLabelSize,
                          iconSize: iconSize * 0.4,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: spacing * 3),

                  // Restart button
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 800),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Opacity(
                        opacity: value,
                        child: Transform.translate(
                          offset: Offset(0, 15 * (1 - value)),
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
                          horizontal: screenWidth * 0.08,
                          vertical: screenHeight * 0.025,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(25),
                        ),
                        elevation: 8,
                        shadowColor: Colors.green.withOpacity(0.5),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.refresh,
                            size: buttonTextSize * 1.2,
                          ),
                          SizedBox(width: spacing),
                          Text(
                            'RESTART',
                            style: TextStyle(
                              fontSize: buttonTextSize,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
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
    required double statValueSize,
    required double statLabelSize,
    required double iconSize,
  }) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Container(
              padding: EdgeInsets.all(iconSize * 0.35),
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: iconColor,
                size: iconSize,
              ),
            ),
            SizedBox(width: iconSize * 0.4),
            Text(
              label,
              style: TextStyle(
                fontSize: statLabelSize,
                color: Colors.grey[400],
                fontWeight: FontWeight.w600,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: statValueSize,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                color: iconColor.withOpacity(0.5),
                blurRadius: 8,
              ),
            ],
          ),
        ),
      ],
    );
  }
}