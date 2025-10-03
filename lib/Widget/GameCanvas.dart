import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:ui' as ui;
import '../Game/Game_Controller.dart';
import '../Models/Obstacle.dart';

class GameCanvas extends StatelessWidget {
  final GameController controller;

  const GameCanvas({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: GamePainter(controller),
      child: Container(),
    );
  }
}

class GamePainter extends CustomPainter {
  final GameController controller;

  // Cache paint objects to reduce memory allocation
  static final Paint _skyPaint = Paint();
  static final Paint _terrainPaint = Paint();
  static final Paint _vehiclePaint = Paint();
  static final Paint _coinPaint = Paint();
  static final Paint _fuelCanPaint = Paint();

  GamePainter(this.controller);

  @override
  void paint(Canvas canvas, Size size) {
    final vehicle = controller.vehicle;
    final terrain = controller.terrain;

    double cameraX = vehicle.x - size.width * 0.3;

    bool isNight = terrain.isNightTheme();
    bool isSnow = terrain.isSnowTheme();

    // Draw layers (optimized order)
    if (isNight) {
      _drawNightSky(canvas, size);
      _drawMoon(canvas, size);
      _drawStars(canvas, size, cameraX);
    } else if (isSnow) {
      _drawSnowySky(canvas, size);
      _drawSun(canvas, size);
    } else {
      _drawSky(canvas, size);
      _drawSun(canvas, size);
      _drawClouds(canvas, size, cameraX);
    }

    _drawMountains(canvas, size, cameraX, isNight, isSnow);
    _drawTerrain(canvas, size, terrain, cameraX, isNight, isSnow);
    _drawObstacles(canvas, terrain, cameraX, size.width, isNight, isSnow);
    // Only draw visible collectibles
    _drawVisibleFuelCans(canvas, terrain, cameraX, size.width);
    _drawVisibleCoins(canvas, terrain, cameraX, size.width);

    _drawVehicle(canvas, vehicle, cameraX);

    // Conditional effects (only when needed)
    if (vehicle.velocityX > 2) {
      _drawWheelParticles(canvas, vehicle, cameraX, isSnow);
    }

    if (vehicle.velocityX > 5) {
      _drawSpeedLines(canvas, size, vehicle, cameraX);
    }
  }

  void _drawSky(Canvas canvas, Size size) {
    final skyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF1e3a8a),
        const Color(0xFF3b82f6),
        const Color(0xFF60a5fa),
        const Color(0xFFbfdbfe),
      ],
    );

    _skyPaint.shader = skyGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _skyPaint);
  }

  void _drawNightSky(Canvas canvas, Size size) {
    final nightGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFF0c0a20),
        const Color(0xFF1a1530),
        const Color(0xFF2d2550),
      ],
    );

    _skyPaint.shader = nightGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _skyPaint);
  }

  void _drawSnowySky(Canvas canvas, Size size) {
    final snowyGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        const Color(0xFFb4c5d8),
        const Color(0xFFd1dce6),
        const Color(0xFFe8eff5),
      ],
    );

    _skyPaint.shader = snowyGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), _skyPaint);
  }

  void _drawMoon(Canvas canvas, Size size) {
    final moonPosition = Offset(size.width - 120, 80);
    final glowPaint = Paint()
      ..color = Colors.white.withOpacity(0.15)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 30);

    canvas.drawCircle(moonPosition, 50, glowPaint);
    canvas.drawCircle(moonPosition, 35, Paint()..color = const Color(0xFFf0f0f0));
    canvas.drawCircle(moonPosition.translate(-8, 5), 8, Paint()..color = const Color(0xFFd0d0d0));
    canvas.drawCircle(moonPosition.translate(10, -5), 6, Paint()..color = const Color(0xFFd0d0d0));
  }

  void _drawStars(Canvas canvas, Size size, double cameraX) {
    final random = Random(42);
    final starPaint = Paint();

    for (int i = 0; i < 60; i++) { // Reduced from 100 to 60
      double starX = ((random.nextDouble() * size.width * 3) - cameraX * 0.05) % size.width;
      double starY = random.nextDouble() * size.height * 0.6;
      double starSize = random.nextDouble() * 2 + 1;
      double twinkle = sin(DateTime.now().millisecondsSinceEpoch / 500 + i) * 0.3 + 0.7;
      starPaint.color = Colors.white.withOpacity(twinkle);
      canvas.drawCircle(Offset(starX, starY), starSize, starPaint);
    }
  }

  void _drawSun(Canvas canvas, Size size) {
    final sunPosition = Offset(size.width - 120, 80);
    final outerGlow = Paint()
      ..color = Colors.orange.withOpacity(0.15)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 40);
    final innerGlow = Paint()
      ..color = Colors.yellow.withOpacity(0.4)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 25);

    canvas.drawCircle(sunPosition, 80, outerGlow);
    canvas.drawCircle(sunPosition, 50, innerGlow);

    final sunGradient = RadialGradient(
        colors: [const Color(0xFFfde047), const Color(0xFFfbbf24), const Color(0xFFf59e0b)]
    );
    canvas.drawCircle(
        sunPosition,
        35,
        Paint()..shader = sunGradient.createShader(Rect.fromCircle(center: sunPosition, radius: 35))
    );
    canvas.drawCircle(
        sunPosition.translate(-8, -8),
        12,
        Paint()..color = Colors.white.withOpacity(0.6)
    );
  }

  void _drawMountains(Canvas canvas, Size size, double cameraX, bool isNight, bool isSnow) {
    Color far, mid, near;
    if (isNight) {
      far = const Color(0xFF1a1530).withOpacity(0.6);
      mid = const Color(0xFF2d2550).withOpacity(0.7);
      near = const Color(0xFF3d3560).withOpacity(0.8);
    } else if (isSnow) {
      far = const Color(0xFFcfdce8).withOpacity(0.5);
      mid = const Color(0xFFb8c9d9).withOpacity(0.6);
      near = const Color(0xFF9fb4c7).withOpacity(0.7);
    } else {
      far = const Color(0xFF6366f1).withOpacity(0.3);
      mid = const Color(0xFF8b5cf6).withOpacity(0.4);
      near = const Color(0xFF6d28d9).withOpacity(0.5);
    }
    _drawMountainLayer(canvas, size, cameraX * 0.1, far, 0.6, 3);
    _drawMountainLayer(canvas, size, cameraX * 0.2, mid, 0.7, 4);
    _drawMountainLayer(canvas, size, cameraX * 0.35, near, 0.8, 5);
  }

  void _drawMountainLayer(Canvas canvas, Size size, double offset, Color color, double heightFactor, int peaks) {
    Path mountainPath = Path();
    mountainPath.moveTo(-offset, size.height * heightFactor);
    for (int i = 0; i <= peaks; i++) {
      double x = (i * size.width / peaks) - offset;
      double peakHeight = size.height * (heightFactor - 0.3) + sin(i * pi / peaks) * size.height * 0.15;
      mountainPath.lineTo(x, peakHeight);
    }
    mountainPath.lineTo(size.width - offset, size.height * heightFactor);
    mountainPath.lineTo(-offset, size.height * heightFactor);
    mountainPath.close();
    canvas.drawPath(mountainPath, Paint()..color = color);
  }

  void _drawClouds(Canvas canvas, Size size, double cameraX) {
    final cloudPaint = Paint()
      ..color = Colors.white.withOpacity(0.8)
      ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 12);

    for (int layer = 0; layer < 2; layer++) {
      double parallaxFactor = 0.2 + layer * 0.15;
      double yOffset = 60 + layer * 40;
      for (int i = 0; i < 4; i++) { // Reduced from 6 to 4
        double cloudX = ((i * 500 + cameraX * parallaxFactor) % (size.width + 200)) - 100;
        double cloudY = yOffset + sin(i * 0.5) * 20;
        canvas.drawCircle(Offset(cloudX, cloudY), 25, cloudPaint);
        canvas.drawCircle(Offset(cloudX + 20, cloudY - 5), 30, cloudPaint);
        canvas.drawCircle(Offset(cloudX + 45, cloudY), 28, cloudPaint);
        canvas.drawCircle(Offset(cloudX + 60, cloudY + 5), 22, cloudPaint);
      }
    }
  }

  void _drawTerrain(Canvas canvas, Size size, terrain, double cameraX, bool isNight, bool isSnow) {
    Path terrainPath = Path();
    terrainPath.moveTo(-cameraX, size.height);

    // Only draw visible terrain points
    for (var point in terrain.points) {
      if (point.dx - cameraX > -100 && point.dx - cameraX < size.width + 100) {
        terrainPath.lineTo(point.dx - cameraX, point.dy);
      }
    }

    terrainPath.lineTo(terrain.points.last.dx - cameraX, size.height);
    terrainPath.close();

    List<Color> terrainColors;
    Color grassColor, darkGrassColor;

    if (isNight) {
      terrainColors = [const Color(0xFF2d1810), const Color(0xFF1a0f08), const Color(0xFF0d0704)];
      grassColor = const Color(0xFF1a4d2e);
      darkGrassColor = const Color(0xFF0f2818);
    } else if (isSnow) {
      terrainColors = [const Color(0xFFe8f0f8), const Color(0xFFd0dfe8), const Color(0xFFb8ccd8)];
      grassColor = const Color(0xFFf0f6fa);
      darkGrassColor = const Color(0xFFd8e6f0);
    } else {
      terrainColors = [const Color(0xFF92400e), const Color(0xFF78350f), const Color(0xFF451a03)];
      grassColor = const Color(0xFF15803d);
      darkGrassColor = const Color(0xFF14532d);
    }

    final undergroundGradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: terrainColors
    );
    _terrainPaint.shader = undergroundGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawPath(terrainPath, _terrainPaint);

    // Draw grass line
    Path grassPath = Path();
    bool pathStarted = false;
    for (var i = 0; i < terrain.points.length - 1; i++) {
      final point = terrain.points[i];
      final screenX = point.dx - cameraX;
      if (screenX >= -50 && screenX <= size.width + 50) {
        if (!pathStarted) {
          grassPath.moveTo(screenX, point.dy);
          pathStarted = true;
        } else {
          grassPath.lineTo(screenX, point.dy);
        }
      }
    }

    final grassStrokePaint = Paint()
      ..color = grassColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 12
      ..strokeCap = StrokeCap.round;
    canvas.drawPath(grassPath, grassStrokePaint);

    // Reduced grass blade rendering for performance
    if (!isSnow) {
      final random = Random(42);
      final grassBladePaint = Paint()
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round;

      for (var i = 0; i < terrain.points.length - 1; i += 3) { // Reduced frequency
        final point = terrain.points[i];
        final screenX = point.dx - cameraX;
        if (screenX < -50 || screenX > size.width + 50) continue;

        for (int j = 0; j < 2; j++) { // Reduced from 4 to 2
          random.nextDouble();
          final grassX = screenX + j * 12 + random.nextDouble() * 5;
          final grassHeight = 10 + random.nextDouble() * 8;
          final bend = random.nextDouble() * 3 - 1.5;
          grassBladePaint.color = Color.lerp(grassColor, grassColor.withOpacity(0.7), random.nextDouble())!;
          canvas.drawLine(
              Offset(grassX, point.dy),
              Offset(grassX + bend, point.dy - grassHeight),
              grassBladePaint
          );
        }
      }
    }

    final darkGrassPaint = Paint()
      ..color = darkGrassColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawPath(grassPath, darkGrassPaint);
  }

  void _drawVisibleFuelCans(Canvas canvas, terrain, double cameraX, double screenWidth) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000;

    for (var fuelCan in terrain.fuelCans) {
      final screenX = fuelCan.dx - cameraX;
      if (screenX < -100 || screenX > screenWidth + 100) continue;

      final screenPos = Offset(screenX, fuelCan.dy);
      final bounce = sin(time * 2.5 + fuelCan.dx * 0.5) * 2;
      final animatedPos = screenPos.translate(0, bounce);

      canvas.drawOval(
          Rect.fromCenter(center: Offset(animatedPos.dx, animatedPos.dy + 18), width: 20, height: 8),
          Paint()..color = Colors.black.withOpacity(0.3)
      );

      final canRect = RRect.fromRectAndRadius(
          Rect.fromCenter(center: animatedPos, width: 16, height: 24),
          const Radius.circular(3)
      );
      final canGradient = LinearGradient(
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
          colors: [const Color(0xFFdc2626), const Color(0xFFef4444), const Color(0xFFdc2626)]
      );
      _fuelCanPaint.shader = canGradient.createShader(canRect.outerRect);
      canvas.drawRRect(canRect, _fuelCanPaint);

      canvas.drawRRect(
          RRect.fromRectAndRadius(Rect.fromCenter(center: animatedPos, width: 12, height: 8), const Radius.circular(1)),
          Paint()..color = Colors.white
      );

      Path dropPath = Path();
      dropPath.moveTo(animatedPos.dx, animatedPos.dy - 2);
      dropPath.quadraticBezierTo(animatedPos.dx - 3, animatedPos.dy, animatedPos.dx, animatedPos.dy + 3);
      dropPath.quadraticBezierTo(animatedPos.dx + 3, animatedPos.dy, animatedPos.dx, animatedPos.dy - 2);
      canvas.drawPath(dropPath, Paint()..color = const Color(0xFFdc2626));

      canvas.drawRRect(
          canRect,
          Paint()
            ..color = const Color(0xFF991b1b)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
      );

      canvas.drawLine(
          Offset(animatedPos.dx - 6, animatedPos.dy - 10),
          Offset(animatedPos.dx - 6, animatedPos.dy + 10),
          Paint()
            ..color = Colors.white.withOpacity(0.4)
            ..strokeWidth = 2
      );
    }
  }

  void _drawVisibleCoins(Canvas canvas, terrain, double cameraX, double screenWidth) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000;

    for (var coin in terrain.coins) {
      final screenX = coin.dx - cameraX;
      if (screenX < -100 || screenX > screenWidth + 100) continue;

      final screenPos = Offset(screenX, coin.dy);
      final bounce = sin(time * 3 + coin.dx) * 4;
      final rotation = (time * 2 + coin.dx) % (2 * pi);
      final scale = (cos(rotation) * 0.5 + 0.5).abs();
      final animatedPos = screenPos.translate(0, bounce);

      canvas.drawOval(
          Rect.fromCenter(center: Offset(animatedPos.dx, animatedPos.dy + 15), width: 20 * scale, height: 8),
          Paint()..color = Colors.black.withOpacity(0.3)
      );

      canvas.drawCircle(
          animatedPos,
          18,
          Paint()
            ..color = Colors.yellow.withOpacity(0.4)
            ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 10)
      );

      canvas.save();
      canvas.translate(animatedPos.dx, animatedPos.dy);
      canvas.scale(scale, 1.0);

      final coinGradient = RadialGradient(
          center: const Alignment(-0.3, -0.3),
          colors: [const Color(0xFFfde047), const Color(0xFFfbbf24), const Color(0xFFf59e0b)]
      );
      _coinPaint.shader = coinGradient.createShader(Rect.fromCircle(center: Offset.zero, radius: 14));
      canvas.drawCircle(Offset.zero, 14, _coinPaint);

      canvas.drawCircle(
          Offset.zero,
          14,
          Paint()
            ..color = const Color(0xFFd97706)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2
      );

      canvas.drawCircle(
          Offset.zero,
          10,
          Paint()
            ..color = const Color(0xFFf59e0b)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 1.5
      );

      canvas.drawCircle(Offset.zero, 3, Paint()..color = const Color(0xFFd97706));
      canvas.restore();

      // Sparkles
      final sparklePaint = Paint()..color = Colors.white.withOpacity(0.8);
      for (int i = 0; i < 4; i++) {
        final sparkleAngle = time * 3 + coin.dx + (i * pi / 2);
        final sparkleDistance = 20 + sin(time * 4) * 3;
        canvas.drawCircle(
            animatedPos.translate(cos(sparkleAngle) * sparkleDistance, sin(sparkleAngle) * sparkleDistance),
            2,
            sparklePaint
        );
      }
    }
  }

  void _drawVehicle(Canvas canvas, vehicle, double cameraX) {
    canvas.save();
    canvas.translate(vehicle.x - cameraX, vehicle.y);
    canvas.rotate(vehicle.rotation);

    // Shadow
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-35, 15, 70, 20), const Radius.circular(10)),
        Paint()
          ..color = Colors.black.withOpacity(0.4)
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 4)
    );

    if (vehicle.velocityX > 3) _drawExhaust(canvas, vehicle);

    // Vehicle body
    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-32, -5, 64, 18), const Radius.circular(6)),
        Paint()..color = const Color(0xFF7f1d1d)
    );

    final bodyGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFFef4444), const Color(0xFFdc2626), const Color(0xFF991b1b)]
    );
    final bodyRect = RRect.fromRectAndRadius(const Rect.fromLTWH(-32, -22, 64, 25), const Radius.circular(8));
    _vehiclePaint.shader = bodyGradient.createShader(bodyRect.outerRect);
    canvas.drawRRect(bodyRect, _vehiclePaint);

    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-30, -21, 40, 8), const Radius.circular(4)),
        Paint()..color = Colors.white.withOpacity(0.3)
    );

    canvas.drawRRect(
        bodyRect,
        Paint()
          ..color = const Color(0xFF450a0a)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2.5
    );

    final roofRect = RRect.fromRectAndRadius(const Rect.fromLTWH(-18, -38, 36, 18), const Radius.circular(9));
    canvas.drawRRect(roofRect, Paint()..color = const Color(0xFF991b1b));
    canvas.drawRRect(
        roofRect,
        Paint()
          ..color = const Color(0xFF450a0a)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 2
    );

    _drawWindow(canvas, const Rect.fromLTWH(-15, -35, 13, 12));
    _drawWindow(canvas, const Rect.fromLTWH(3, -35, 13, 12));

    canvas.drawCircle(const Offset(28, -8), 4, Paint()..color = const Color(0xFFfef08a));

    if (vehicle.velocityX > 4) {
      canvas.drawCircle(
          const Offset(28, -8),
          6,
          Paint()
            ..color = Colors.yellow.withOpacity(0.5)
            ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 5)
      );
    }

    canvas.drawCircle(const Offset(-28, -8), 3, Paint()..color = const Color(0xFFfca5a5));
    canvas.drawLine(
        const Offset(-5, -22),
        const Offset(-5, 3),
        Paint()
          ..color = const Color(0xFF7f1d1d)
          ..strokeWidth = 2
    );

    canvas.drawRRect(
        RRect.fromRectAndRadius(const Rect.fromLTWH(-35, -40, 8, 4), const Radius.circular(2)),
        Paint()..color = const Color(0xFF450a0a)
    );

    _drawWheel(canvas, const Offset(22, 12), vehicle);
    _drawWheel(canvas, const Offset(-22, 12), vehicle);

    canvas.restore();
  }

  void _drawWindow(Canvas canvas, Rect rect) {
    final windowGradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [const Color(0xFF93c5fd), const Color(0xFF3b82f6), const Color(0xFF1e40af)]
    );
    final windowRect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
    canvas.drawRRect(windowRect, Paint()..shader = windowGradient.createShader(rect));
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTWH(rect.left + 2, rect.top + 2, rect.width * 0.4, rect.height * 0.4),
            const Radius.circular(2)
        ),
        Paint()..color = Colors.white.withOpacity(0.5)
    );
    canvas.drawRRect(
        windowRect,
        Paint()
          ..color = const Color(0xFF1e3a8a)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5
    );
  }

  void _drawWheel(Canvas canvas, Offset position, vehicle) {
    canvas.drawCircle(
        position.translate(3, 3),
        vehicle.wheelRadius + 1,
        Paint()
          ..color = Colors.black.withOpacity(0.4)
          ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3)
    );

    canvas.drawCircle(position, vehicle.wheelRadius, Paint()..color = const Color(0xFF1c1917));

    final spokePaint = Paint()
      ..color = const Color(0xFF292524)
      ..strokeWidth = 2;
    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4) + vehicle.x * 0.15;
      canvas.drawLine(
          position.translate(cos(angle) * (vehicle.wheelRadius - 2), sin(angle) * (vehicle.wheelRadius - 2)),
          position.translate(cos(angle) * vehicle.wheelRadius, sin(angle) * vehicle.wheelRadius),
          spokePaint
      );
    }

    final rimGradient = RadialGradient(
        colors: [const Color(0xFFd4d4d8), const Color(0xFF71717a), const Color(0xFF3f3f46)]
    );
    canvas.drawCircle(
        position,
        vehicle.wheelRadius - 4,
        Paint()..shader = rimGradient.createShader(Rect.fromCircle(center: position, radius: vehicle.wheelRadius - 4))
    );

    canvas.drawCircle(position, vehicle.wheelRadius - 9, Paint()..color = const Color(0xFF18181b));
    canvas.drawCircle(position, vehicle.wheelRadius - 11, Paint()..color = const Color(0xFF52525b));

    final hubSpokePaint = Paint()
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * pi / 5) + vehicle.x * 0.15;
      canvas.drawLine(
          position,
          position.translate(cos(angle) * (vehicle.wheelRadius - 5) + 0.5, sin(angle) * (vehicle.wheelRadius - 5) + 0.5),
          Paint()
            ..color = Colors.black.withOpacity(0.3)
            ..strokeWidth = 3
      );
      hubSpokePaint.color = const Color(0xFFa1a1aa);
      canvas.drawLine(
          position,
          position.translate(cos(angle) * (vehicle.wheelRadius - 5), sin(angle) * (vehicle.wheelRadius - 5)),
          hubSpokePaint
      );
    }

    canvas.drawCircle(position.translate(-2, -2), 3, Paint()..color = Colors.white.withOpacity(0.6));
  }

  void _drawExhaust(Canvas canvas, vehicle) {
    final random = Random(vehicle.x.toInt());
    for (int i = 0; i < 3; i++) {
      final smokeX = -30.0 - i * 8;
      final smokeY = 0.0 + random.nextDouble() * 6 - 3;
      final smokeSize = 4.0 + i * 2;
      canvas.drawCircle(
          Offset(smokeX, smokeY),
          smokeSize,
          Paint()
            ..color = Colors.grey.withOpacity(0.3 - i * 0.1)
            ..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 3)
      );
    }
  }

  void _drawWheelParticles(Canvas canvas, vehicle, double cameraX, bool isSnow) {
    final random = Random(vehicle.x.toInt());
    final particlePaint = Paint()..maskFilter = const ui.MaskFilter.blur(ui.BlurStyle.normal, 2);

    for (int i = 0; i < 6; i++) { // Reduced from 8 to 6
      final particleX = vehicle.x - cameraX - 25 - i * 6 - random.nextDouble() * 5;
      final particleY = vehicle.y + 12 + random.nextDouble() * 8 - 4;
      final size = 4.0 - i * 0.4;
      final opacity = 0.7 - i * 0.08;
      Color particleColor = isSnow ? const Color(0xFFffffff) : const Color(0xFF78350f);
      particlePaint.color = particleColor.withOpacity(opacity);
      canvas.drawCircle(Offset(particleX, particleY), size, particlePaint);
    }
  }
// Add this method to the GamePainter class in GameCanvas.dart

  void _drawObstacles(Canvas canvas, terrain, double cameraX, double screenWidth, bool isNight, bool isSnow) {
    for (var obstacle in terrain.obstacles) {
      final screenX = obstacle.position.dx - cameraX;
      if (screenX < -100 || screenX > screenWidth + 100) continue;

      final screenPos = Offset(screenX, obstacle.position.dy);

      switch (obstacle.type) {
        case ObstacleType.rock:
          _drawRock(canvas, screenPos, obstacle.width, obstacle.height, isNight);
          break;
        case ObstacleType.tree:
          _drawTree(canvas, screenPos, obstacle.width, obstacle.height, isSnow);
          break;
        case ObstacleType.spike:
          _drawSpike(canvas, screenPos, obstacle.width, obstacle.height);
          break;
        case ObstacleType.barrel:
          _drawBarrel(canvas, screenPos, obstacle.width, obstacle.height);
          break;
      }
    }
  }

  void _drawRock(Canvas canvas, Offset position, double width, double height, bool isNight) {
    // Shadow
    canvas.drawOval(
        Rect.fromCenter(center: Offset(position.dx, position.dy + height + 5), width: width * 0.9, height: 8),
        Paint()..color = Colors.black.withOpacity(0.3)
    );

    // Rock body
    final rockPath = Path();
    rockPath.moveTo(position.dx - width / 2, position.dy + height);
    rockPath.lineTo(position.dx - width / 3, position.dy + height * 0.3);
    rockPath.lineTo(position.dx, position.dy);
    rockPath.lineTo(position.dx + width / 3, position.dy + height * 0.4);
    rockPath.lineTo(position.dx + width / 2, position.dy + height);
    rockPath.close();

    final rockGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isNight
          ? [const Color(0xFF4a4a4a), const Color(0xFF2a2a2a), const Color(0xFF1a1a1a)]
          : [const Color(0xFF78716c), const Color(0xFF57534e), const Color(0xFF44403c)],
    );

    canvas.drawPath(
        rockPath,
        Paint()..shader = rockGradient.createShader(Rect.fromCenter(center: position, width: width, height: height))
    );

    // Rock cracks/details
    final crackPaint = Paint()
      ..color = Colors.black.withOpacity(0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    canvas.drawLine(
        Offset(position.dx - width / 4, position.dy + height * 0.5),
        Offset(position.dx + width / 6, position.dy + height * 0.7),
        crackPaint
    );
  }

  void _drawTree(Canvas canvas, Offset position, double width, double height, bool isSnow) {
    // Shadow
    canvas.drawOval(
        Rect.fromCenter(center: Offset(position.dx, position.dy + height + 5), width: width * 1.2, height: 10),
        Paint()..color = Colors.black.withOpacity(0.3)
    );

    // Trunk
    final trunkRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(position.dx, position.dy + height * 0.7), width: width * 0.3, height: height * 0.6),
        const Radius.circular(3)
    );

    canvas.drawRRect(trunkRect, Paint()..color = const Color(0xFF78350f));
    canvas.drawRRect(
        trunkRect,
        Paint()..color = const Color(0xFF451a03)..style = PaintingStyle.stroke..strokeWidth = 2
    );

    // Foliage (3 circles forming tree crown)
    final foliageColor = isSnow ? const Color(0xFF86efac) : const Color(0xFF16a34a);
    final foliageDark = isSnow ? const Color(0xFF4ade80) : const Color(0xFF15803d);

    for (int i = 0; i < 3; i++) {
      final yOffset = i * (height * 0.15);
      final size = (width * 0.8) - (i * 5);

      canvas.drawCircle(
          Offset(position.dx, position.dy + height * 0.3 + yOffset),
          size / 2,
          Paint()..color = foliageColor
      );

      canvas.drawCircle(
          Offset(position.dx - size * 0.2, position.dy + height * 0.3 + yOffset - size * 0.1),
          size * 0.2,
          Paint()..color = foliageDark
      );
    }

    // Snow on top if snow theme
    if (isSnow) {
      for (int i = 0; i < 3; i++) {
        final yOffset = i * (height * 0.15);
        final size = (width * 0.8) - (i * 5);

        canvas.drawCircle(
            Offset(position.dx, position.dy + height * 0.25 + yOffset),
            size * 0.3,
            Paint()..color = Colors.white
        );
      }
    }
  }

  void _drawSpike(Canvas canvas, Offset position, double width, double height) {
    // Shadow
    canvas.drawOval(
        Rect.fromCenter(center: Offset(position.dx, position.dy + height + 5), width: width, height: 8),
        Paint()..color = Colors.black.withOpacity(0.4)
    );

    // Spike triangles
    final spikePaint = Paint();
    final spikeGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [const Color(0xFF6b7280), const Color(0xFF4b5563), const Color(0xFF374151)],
    );

    for (int i = 0; i < 3; i++) {
      final xOffset = (i - 1) * (width / 3);
      final spikePath = Path();
      spikePath.moveTo(position.dx + xOffset - width / 6, position.dy + height);
      spikePath.lineTo(position.dx + xOffset, position.dy);
      spikePath.lineTo(position.dx + xOffset + width / 6, position.dy + height);
      spikePath.close();

      spikePaint.shader = spikeGradient.createShader(Rect.fromLTWH(
          position.dx + xOffset - width / 6, position.dy, width / 3, height
      ));
      canvas.drawPath(spikePath, spikePaint);

      // Highlight
      canvas.drawLine(
          Offset(position.dx + xOffset - 2, position.dy + height * 0.3),
          Offset(position.dx + xOffset, position.dy + 2),
          Paint()..color = Colors.white.withOpacity(0.4)..strokeWidth = 2
      );
    }

    // Base
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromCenter(center: Offset(position.dx, position.dy + height + 3), width: width, height: 6),
            const Radius.circular(2)
        ),
        Paint()..color = const Color(0xFF1f2937)
    );
  }

  void _drawBarrel(Canvas canvas, Offset position, double width, double height) {
    // Shadow
    canvas.drawOval(
        Rect.fromCenter(center: Offset(position.dx, position.dy + height + 5), width: width, height: 8),
        Paint()..color = Colors.black.withOpacity(0.3)
    );

    // Barrel body
    final barrelRect = RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset(position.dx, position.dy + height / 2), width: width, height: height),
        Radius.circular(width * 0.1)
    );

    final barrelGradient = LinearGradient(
      begin: Alignment.centerLeft,
      end: Alignment.centerRight,
      colors: [const Color(0xFFfbbf24), const Color(0xFFf59e0b), const Color(0xFFd97706)],
    );

    canvas.drawRRect(
        barrelRect,
        Paint()..shader = barrelGradient.createShader(barrelRect.outerRect)
    );

    // Barrel bands
    final bandPaint = Paint()..color = const Color(0xFF92400e)..strokeWidth = 3;

    canvas.drawLine(
        Offset(position.dx - width / 2, position.dy + height * 0.25),
        Offset(position.dx + width / 2, position.dy + height * 0.25),
        bandPaint
    );

    canvas.drawLine(
        Offset(position.dx - width / 2, position.dy + height * 0.75),
        Offset(position.dx + width / 2, position.dy + height * 0.75),
        bandPaint
    );

    // Warning symbol
    final warningPath = Path();
    warningPath.moveTo(position.dx, position.dy + height * 0.4);
    warningPath.lineTo(position.dx - width * 0.2, position.dy + height * 0.65);
    warningPath.lineTo(position.dx + width * 0.2, position.dy + height * 0.65);
    warningPath.close();

    canvas.drawPath(warningPath, Paint()..color = Colors.black);
    canvas.drawCircle(
        Offset(position.dx, position.dy + height * 0.57),
        2,
        Paint()..color = const Color(0xFFfbbf24)
    );
  }
  void _drawSpeedLines(Canvas canvas, Size size, vehicle, double cameraX) {
    final random = Random(42);
    final linePaint = Paint()
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    for (int i = 0; i < 8; i++) { // Reduced from 10 to 8
      random.nextDouble();
      final lineX = vehicle.x - cameraX - 50 - i * 30;
      final lineY = vehicle.y + random.nextDouble() * 40 - 20;
      final lineLength = 15.0 + vehicle.velocityX * 2;
      linePaint.color = Colors.white.withOpacity(0.3 - i * 0.025);
      canvas.drawLine(Offset(lineX, lineY), Offset(lineX - lineLength, lineY), linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}