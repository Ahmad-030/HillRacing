import 'package:flutter/material.dart';
import 'dart:math';
import 'GameScreen.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({Key? key}) : super(key: key);

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  late AnimationController _titleController;
  late AnimationController _buttonController;
  late AnimationController _backgroundController;

  late Animation<double> _titleScale;
  late Animation<double> _titleRotation;
  late Animation<Offset> _buttonSlide;
  late Animation<double> _buttonFade;

  @override
  void initState() {
    super.initState();

    // Title animation
    _titleController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _titleScale = Tween<double>(begin: 0.5, end: 1.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.elasticOut),
    );

    _titleRotation = Tween<double>(begin: -0.2, end: 0.0).animate(
      CurvedAnimation(parent: _titleController, curve: Curves.easeOut),
    );

    // Button animation
    _buttonController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _buttonSlide = Tween<Offset>(
      begin: const Offset(0, 2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _buttonController, curve: Curves.easeOut));

    _buttonFade = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _buttonController, curve: Curves.easeIn),
    );

    // Background animation
    _backgroundController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    )..repeat();

    // Start animations
    _titleController.forward();
    Future.delayed(const Duration(milliseconds: 400), () {
      _buttonController.forward();
    });
  }

  @override
  void dispose() {
    _titleController.dispose();
    _buttonController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: AnimatedBuilder(
        animation: _backgroundController,
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color.lerp(const Color(0xFF87CEEB), const Color(0xFF5FA8D3),
                      sin(_backgroundController.value * 2 * pi) * 0.5 + 0.5)!,
                  Color.lerp(const Color(0xFF4682B4), const Color(0xFF2E5C8A),
                      cos(_backgroundController.value * 2 * pi) * 0.5 + 0.5)!,
                ],
              ),
            ),
            child: Stack(
              children: [
                // Animated clouds
                ...List.generate(5, (index) => _buildAnimatedCloud(index)),

                // Main content
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Animated title
                      AnimatedBuilder(
                        animation: _titleController,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _titleScale.value,
                            child: Transform.rotate(
                              angle: _titleRotation.value,
                              child: Column(
                                children: [
                                  Text(
                                    'HILL CLIMB',
                                    style: TextStyle(
                                      fontSize: 52,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 15,
                                          color: Colors.orange.withOpacity(0.8),
                                          offset: const Offset(0, 0),
                                        ),
                                        const Shadow(
                                          blurRadius: 10,
                                          color: Colors.black,
                                          offset: Offset(3, 3),
                                        ),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    'RACING',
                                    style: TextStyle(
                                      fontSize: 52,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.orange,
                                      shadows: [
                                        Shadow(
                                          blurRadius: 15,
                                          color: Colors.white.withOpacity(0.6),
                                          offset: const Offset(0, 0),
                                        ),
                                        const Shadow(
                                          blurRadius: 10,
                                          color: Colors.black,
                                          offset: Offset(3, 3),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: 60),

                      // Animated button
                      SlideTransition(
                        position: _buttonSlide,
                        child: FadeTransition(
                          opacity: _buttonFade,
                          child: _buildAnimatedButton(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAnimatedCloud(int index) {
    final random = Random(index);
    final yPosition = 50.0 + random.nextDouble() * 150;
    final duration = 20 + random.nextInt(15);

    return AnimatedBuilder(
      animation: _backgroundController,
      builder: (context, child) {
        final progress = (_backgroundController.value + index * 0.2) % 1.0;
        final xPosition = -100 + (MediaQuery.of(context).size.width + 200) * progress;

        return Positioned(
          left: xPosition,
          top: yPosition,
          child: Opacity(
            opacity: 0.6,
            child: Container(
              width: 80 + random.nextDouble() * 40,
              height: 30 + random.nextDouble() * 20,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(50),
                boxShadow: [
                  BoxShadow(
                    color: Colors.white.withOpacity(0.5),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnimatedButton() {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: const Duration(seconds: 2),
      builder: (context, value, child) {
        return Transform.scale(
          scale: 1.0 + sin(value * pi * 4) * 0.05,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const GameScreen()),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.orange,
              padding: const EdgeInsets.symmetric(horizontal: 70, vertical: 22),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(35),
              ),
              elevation: 10,
              shadowColor: Colors.orange.withOpacity(0.8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.play_arrow, size: 32, color: Colors.white),
                const SizedBox(width: 10),
                Text(
                  'START GAME',
                  style: TextStyle(
                    fontSize: 26,
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                        color: Colors.black.withOpacity(0.5),
                        blurRadius: 4,
                        offset: const Offset(2, 2),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}