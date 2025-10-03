import 'package:flutter/material.dart';

class PauseDialog extends StatelessWidget {
  final VoidCallback onResume;
  final VoidCallback onRestart;
  final VoidCallback onExit;

  const PauseDialog({
    Key? key,
    required this.onResume,
    required this.onRestart,
    required this.onExit,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final screenWidth = constraints.maxWidth;
        final screenHeight = constraints.maxHeight;

        // Ultra responsive sizing
        final iconSize = (screenHeight * 0.08).clamp(30.0, 60.0);
        final titleSize = (screenHeight * 0.08).clamp(24.0, 42.0);
        final buttonTextSize = (screenHeight * 0.04).clamp(14.0, 20.0);
        final buttonIconSize = (screenHeight * 0.05).clamp(18.0, 28.0);
        final spacing = screenHeight * 0.02;
        final containerWidth = (screenWidth * 0.5).clamp(280.0, 450.0);

        return Container(
          width: double.infinity,
          height: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.black.withOpacity(0.85),
                Colors.black.withOpacity(0.92),
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
                  // Animated pause icon
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 600),
                    tween: Tween<double>(begin: 0, end: 1),
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          padding: EdgeInsets.all(iconSize * 0.25),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: RadialGradient(
                              colors: [
                                Colors.orange.withOpacity(0.3),
                                Colors.transparent,
                              ],
                            ),
                          ),
                          child: Icon(
                            Icons.pause_circle_filled,
                            size: iconSize,
                            color: Colors.orange,
                          ),
                        ),
                      );
                    },
                  ),

                  SizedBox(height: spacing * 2),

                  // Pause Title
                  Text(
                    'PAUSED',
                    style: TextStyle(
                      fontSize: titleSize,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 3,
                      shadows: [
                        Shadow(
                          color: Colors.orange.withOpacity(0.8),
                          blurRadius: 15,
                        ),
                        const Shadow(
                          color: Colors.black,
                          blurRadius: 8,
                        ),
                      ],
                    ),
                  ),

                  SizedBox(height: spacing * 3),

                  // Buttons container
                  Container(
                    width: containerWidth,
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.04,
                      vertical: screenHeight * 0.03,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.05),
                      borderRadius: BorderRadius.circular(15),
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
                        // Resume button
                        _buildButton(
                          icon: Icons.play_arrow,
                          label: 'RESUME',
                          color: Colors.green,
                          onPressed: onResume,
                          buttonTextSize: buttonTextSize,
                          buttonIconSize: buttonIconSize,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                        ),

                        SizedBox(height: spacing * 1.5),

                        // Restart button
                        _buildButton(
                          icon: Icons.refresh,
                          label: 'RESTART',
                          color: Colors.orange,
                          onPressed: onRestart,
                          buttonTextSize: buttonTextSize,
                          buttonIconSize: buttonIconSize,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
                        ),

                        SizedBox(height: spacing * 1.5),

                        // Exit button
                        _buildButton(
                          icon: Icons.exit_to_app,
                          label: 'EXIT',
                          color: Colors.red,
                          onPressed: onExit,
                          buttonTextSize: buttonTextSize,
                          buttonIconSize: buttonIconSize,
                          screenWidth: screenWidth,
                          screenHeight: screenHeight,
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
    );
  }

  Widget _buildButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
    required double buttonTextSize,
    required double buttonIconSize,
    required double screenWidth,
    required double screenHeight,
  }) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 800),
      tween: Tween<double>(begin: 0, end: 1),
      builder: (context, double value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(
            horizontal: screenWidth * 0.06,
            vertical: screenHeight * 0.022,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          elevation: 8,
          shadowColor: color.withOpacity(0.5),
          minimumSize: Size(double.infinity, screenHeight * 0.08),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: buttonIconSize,
            ),
            SizedBox(width: screenWidth * 0.02),
            Text(
              label,
              style: TextStyle(
                fontSize: buttonTextSize,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}