import 'package:flutter/material.dart';
import 'dart:math';
import '../Game/Game_Controller.dart';

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

  GamePainter(this.controller);

  @override
  void paint(Canvas canvas, Size size) {
    final vehicle = controller.vehicle;
    final terrain = controller.terrain;

    double cameraX = vehicle.x - size.width * 0.3;

    bool isNight = terrain.isNightTheme();
    bool isSnow = terrain.isSnowTheme();

    if (isNight) {
      _drawNightSky(canvas, size);
      _drawMoon(canvas, size);
      _drawStars(canvas, size, cameraX);
    } else if (isSnow) {
      _drawSnowySky(canvas, size);
      _drawSun(canvas, size);
      _drawSnowfall(canvas, size, cameraX);
    } else {
      _drawSky(canvas, size);
      _drawSun(canvas, size);
      _drawClouds(canvas, size, cameraX);
    }

    _drawMountains(canvas, size, cameraX, isNight, isSnow);
    _drawTerrain(canvas, size, terrain, cameraX, isNight, isSnow);
    _drawFuelCans(canvas, terrain, cameraX);
    _drawCoins(canvas, terrain, cameraX);
    _drawVehicle(canvas, vehicle, cameraX);

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

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = skyGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
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

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = nightGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
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

    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Paint()..shader = snowyGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height)),
    );
  }

  void _drawMoon(Canvas canvas, Size size) {
    final moonPosition = Offset(size.width - 120, 80);

    canvas.drawCircle(moonPosition, 50, Paint()..color = Colors.white.withOpacity(0.15)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 30));
    canvas.drawCircle(moonPosition, 35, Paint()..color = const Color(0xFFf0f0f0));
    canvas.drawCircle(moonPosition.translate(-8, 5), 8, Paint()..color = const Color(0xFFd0d0d0));
    canvas.drawCircle(moonPosition.translate(10, -5), 6, Paint()..color = const Color(0xFFd0d0d0));
  }

  void _drawStars(Canvas canvas, Size size, double cameraX) {
    final random = Random(42);
    for (int i = 0; i < 100; i++) {
      double starX = ((random.nextDouble() * size.width * 3) - cameraX * 0.05) % size.width;
      double starY = random.nextDouble() * size.height * 0.6;
      double starSize = random.nextDouble() * 2 + 1;
      double twinkle = sin(DateTime.now().millisecondsSinceEpoch / 500 + i) * 0.3 + 0.7;
      canvas.drawCircle(Offset(starX, starY), starSize, Paint()..color = Colors.white.withOpacity(twinkle));
    }
  }

  void _drawSnowfall(Canvas canvas, Size size, double cameraX) {
    final random = Random(42);
    final time = DateTime.now().millisecondsSinceEpoch / 1000;
    for (int i = 0; i < 80; i++) {
      double snowX = ((random.nextDouble() * size.width * 2) - cameraX * 0.1 + sin(time + i) * 20) % size.width;
      double snowY = ((time * 30 + i * 50) % (size.height + 100)) - 50;
      double snowSize = random.nextDouble() * 3 + 2;
      canvas.drawCircle(Offset(snowX, snowY), snowSize, Paint()..color = Colors.white.withOpacity(0.8));
    }
  }

  void _drawSun(Canvas canvas, Size size) {
    final sunPosition = Offset(size.width - 120, 80);
    canvas.drawCircle(sunPosition, 80, Paint()..color = Colors.orange.withOpacity(0.15)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 40));
    canvas.drawCircle(sunPosition, 50, Paint()..color = Colors.yellow.withOpacity(0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 25));
    final sunGradient = RadialGradient(colors: [const Color(0xFFfde047), const Color(0xFFfbbf24), const Color(0xFFf59e0b)]);
    canvas.drawCircle(sunPosition, 35, Paint()..shader = sunGradient.createShader(Rect.fromCircle(center: sunPosition, radius: 35)));
    canvas.drawCircle(sunPosition.translate(-8, -8), 12, Paint()..color = Colors.white.withOpacity(0.6));
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
    final cloudPaint = Paint()..color = Colors.white.withOpacity(0.8)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    for (int layer = 0; layer < 2; layer++) {
      double parallaxFactor = 0.2 + layer * 0.15;
      double yOffset = 60 + layer * 40;
      for (int i = 0; i < 6; i++) {
        double cloudX = ((i * 400 + cameraX * parallaxFactor) % (size.width + 200)) - 100;
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
    for (var point in terrain.points) {
      terrainPath.lineTo(point.dx - cameraX, point.dy);
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

    final undergroundGradient = LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: terrainColors);
    canvas.drawPath(terrainPath, Paint()..shader = undergroundGradient.createShader(Rect.fromLTWH(0, 0, size.width, size.height)));

    Path grassPath = Path();
    for (var i = 0; i < terrain.points.length - 1; i++) {
      final point = terrain.points[i];
      final screenX = point.dx - cameraX;
      if (i == 0) grassPath.moveTo(screenX, point.dy);
      grassPath.lineTo(screenX, point.dy);
    }

    canvas.drawPath(grassPath, Paint()..color = grassColor..style = PaintingStyle.stroke..strokeWidth = 12..strokeCap = StrokeCap.round);

    if (!isSnow) {
      final random = Random(42);
      for (var i = 0; i < terrain.points.length - 1; i += 2) {
        final point = terrain.points[i];
        final screenX = point.dx - cameraX;
        if (screenX < -50 || screenX > size.width + 50) continue;
        for (int j = 0; j < 4; j++) {
          random.nextDouble();
          final grassX = screenX + j * 8 + random.nextDouble() * 5;
          final grassHeight = 10 + random.nextDouble() * 8;
          final bend = random.nextDouble() * 3 - 1.5;
          canvas.drawLine(Offset(grassX, point.dy), Offset(grassX + bend, point.dy - grassHeight),
              Paint()..color = Color.lerp(grassColor, grassColor.withOpacity(0.7), random.nextDouble())!..strokeWidth = 2..strokeCap = StrokeCap.round);
        }
      }
    }

    canvas.drawPath(grassPath, Paint()..color = darkGrassColor..style = PaintingStyle.stroke..strokeWidth = 3);
  }

  void _drawFuelCans(Canvas canvas, terrain, double cameraX) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000;
    for (var fuelCan in terrain.fuelCans) {
      final screenPos = Offset(fuelCan.dx - cameraX, fuelCan.dy);
      final bounce = sin(time * 2.5 + fuelCan.dx * 0.5) * 2;
      final animatedPos = screenPos.translate(0, bounce);
      canvas.drawOval(Rect.fromCenter(center: Offset(animatedPos.dx, animatedPos.dy + 18), width: 20, height: 8), Paint()..color = Colors.black.withOpacity(0.3));
      final canRect = RRect.fromRectAndRadius(Rect.fromCenter(center: animatedPos, width: 16, height: 24), const Radius.circular(3));
      final canGradient = LinearGradient(begin: Alignment.centerLeft, end: Alignment.centerRight, colors: [const Color(0xFFdc2626), const Color(0xFFef4444), const Color(0xFFdc2626)]);
      canvas.drawRRect(canRect, Paint()..shader = canGradient.createShader(canRect.outerRect));
      canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromCenter(center: animatedPos, width: 12, height: 8), const Radius.circular(1)), Paint()..color = Colors.white);
      Path dropPath = Path();
      dropPath.moveTo(animatedPos.dx, animatedPos.dy - 2);
      dropPath.quadraticBezierTo(animatedPos.dx - 3, animatedPos.dy, animatedPos.dx, animatedPos.dy + 3);
      dropPath.quadraticBezierTo(animatedPos.dx + 3, animatedPos.dy, animatedPos.dx, animatedPos.dy - 2);
      canvas.drawPath(dropPath, Paint()..color = const Color(0xFFdc2626));
      canvas.drawRRect(canRect, Paint()..color = const Color(0xFF991b1b)..style = PaintingStyle.stroke..strokeWidth = 2);
      canvas.drawLine(Offset(animatedPos.dx - 6, animatedPos.dy - 10), Offset(animatedPos.dx - 6, animatedPos.dy + 10), Paint()..color = Colors.white.withOpacity(0.4)..strokeWidth = 2);
    }
  }

  void _drawCoins(Canvas canvas, terrain, double cameraX) {
    final time = DateTime.now().millisecondsSinceEpoch / 1000;
    for (var coin in terrain.coins) {
      final screenPos = Offset(coin.dx - cameraX, coin.dy);
      final bounce = sin(time * 3 + coin.dx) * 4;
      final rotation = (time * 2 + coin.dx) % (2 * pi);
      final scale = (cos(rotation) * 0.5 + 0.5).abs();
      final animatedPos = screenPos.translate(0, bounce);
      canvas.drawOval(Rect.fromCenter(center: Offset(animatedPos.dx, animatedPos.dy + 15), width: 20 * scale, height: 8), Paint()..color = Colors.black.withOpacity(0.3));
      canvas.drawCircle(animatedPos, 18, Paint()..color = Colors.yellow.withOpacity(0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 10));
      canvas.save();
      canvas.translate(animatedPos.dx, animatedPos.dy);
      canvas.scale(scale, 1.0);
      final coinGradient = RadialGradient(center: const Alignment(-0.3, -0.3), colors: [const Color(0xFFfde047), const Color(0xFFfbbf24), const Color(0xFFf59e0b)]);
      canvas.drawCircle(Offset.zero, 14, Paint()..shader = coinGradient.createShader(Rect.fromCircle(center: Offset.zero, radius: 14)));
      canvas.drawCircle(Offset.zero, 14, Paint()..color = const Color(0xFFd97706)..style = PaintingStyle.stroke..strokeWidth = 2);
      canvas.drawCircle(Offset.zero, 10, Paint()..color = const Color(0xFFf59e0b)..style = PaintingStyle.stroke..strokeWidth = 1.5);
      canvas.drawCircle(Offset.zero, 3, Paint()..color = const Color(0xFFd97706));
      canvas.restore();
      for (int i = 0; i < 4; i++) {
        final sparkleAngle = time * 3 + coin.dx + (i * pi / 2);
        final sparkleDistance = 20 + sin(time * 4) * 3;
        canvas.drawCircle(animatedPos.translate(cos(sparkleAngle) * sparkleDistance, sin(sparkleAngle) * sparkleDistance), 2, Paint()..color = Colors.white.withOpacity(0.8));
      }
    }
  }

  void _drawVehicle(Canvas canvas, vehicle, double cameraX) {
    canvas.save();
    canvas.translate(vehicle.x - cameraX, vehicle.y);
    canvas.rotate(vehicle.rotation);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-35, 15, 70, 20), const Radius.circular(10)), Paint()..color = Colors.black.withOpacity(0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4));
    if (vehicle.velocityX > 3) _drawExhaust(canvas, vehicle);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-32, -5, 64, 18), const Radius.circular(6)), Paint()..color = const Color(0xFF7f1d1d));
    final bodyGradient = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [const Color(0xFFef4444), const Color(0xFFdc2626), const Color(0xFF991b1b)]);
    final bodyRect = RRect.fromRectAndRadius(const Rect.fromLTWH(-32, -22, 64, 25), const Radius.circular(8));
    canvas.drawRRect(bodyRect, Paint()..shader = bodyGradient.createShader(bodyRect.outerRect));
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-30, -21, 40, 8), const Radius.circular(4)), Paint()..color = Colors.white.withOpacity(0.3));
    canvas.drawRRect(bodyRect, Paint()..color = const Color(0xFF450a0a)..style = PaintingStyle.stroke..strokeWidth = 2.5);
    final roofRect = RRect.fromRectAndRadius(const Rect.fromLTWH(-18, -38, 36, 18), const Radius.circular(9));
    canvas.drawRRect(roofRect, Paint()..color = const Color(0xFF991b1b));
    canvas.drawRRect(roofRect, Paint()..color = const Color(0xFF450a0a)..style = PaintingStyle.stroke..strokeWidth = 2);
    _drawWindow(canvas, const Rect.fromLTWH(-15, -35, 13, 12));
    _drawWindow(canvas, const Rect.fromLTWH(3, -35, 13, 12));
    canvas.drawCircle(const Offset(28, -8), 4, Paint()..color = const Color(0xFFfef08a));
    if (vehicle.velocityX > 4) canvas.drawCircle(const Offset(28, -8), 6, Paint()..color = Colors.yellow.withOpacity(0.5)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 5));
    canvas.drawCircle(const Offset(-28, -8), 3, Paint()..color = const Color(0xFFfca5a5));
    canvas.drawLine(const Offset(-5, -22), const Offset(-5, 3), Paint()..color = const Color(0xFF7f1d1d)..strokeWidth = 2);
    canvas.drawRRect(RRect.fromRectAndRadius(const Rect.fromLTWH(-35, -40, 8, 4), const Radius.circular(2)), Paint()..color = const Color(0xFF450a0a));
    _drawWheel(canvas, const Offset(22, 12), vehicle);
    _drawWheel(canvas, const Offset(-22, 12), vehicle);
    canvas.restore();
  }

  void _drawWindow(Canvas canvas, Rect rect) {
    final windowGradient = LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [const Color(0xFF93c5fd), const Color(0xFF3b82f6), const Color(0xFF1e40af)]);
    final windowRect = RRect.fromRectAndRadius(rect, const Radius.circular(4));
    canvas.drawRRect(windowRect, Paint()..shader = windowGradient.createShader(rect));
    canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(rect.left + 2, rect.top + 2, rect.width * 0.4, rect.height * 0.4), const Radius.circular(2)), Paint()..color = Colors.white.withOpacity(0.5));
    canvas.drawRRect(windowRect, Paint()..color = const Color(0xFF1e3a8a)..style = PaintingStyle.stroke..strokeWidth = 1.5);
  }

  void _drawWheel(Canvas canvas, Offset position, vehicle) {
    canvas.drawCircle(position.translate(3, 3), vehicle.wheelRadius + 1, Paint()..color = Colors.black.withOpacity(0.4)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    canvas.drawCircle(position, vehicle.wheelRadius, Paint()..color = const Color(0xFF1c1917));
    for (int i = 0; i < 8; i++) {
      final angle = (i * pi / 4) + vehicle.x * 0.15;
      canvas.drawLine(position.translate(cos(angle) * (vehicle.wheelRadius - 2), sin(angle) * (vehicle.wheelRadius - 2)), position.translate(cos(angle) * vehicle.wheelRadius, sin(angle) * vehicle.wheelRadius), Paint()..color = const Color(0xFF292524)..strokeWidth = 2);
    }
    final rimGradient = RadialGradient(colors: [const Color(0xFFd4d4d8), const Color(0xFF71717a), const Color(0xFF3f3f46)]);
    canvas.drawCircle(position, vehicle.wheelRadius - 4, Paint()..shader = rimGradient.createShader(Rect.fromCircle(center: position, radius: vehicle.wheelRadius - 4)));
    canvas.drawCircle(position, vehicle.wheelRadius - 9, Paint()..color = const Color(0xFF18181b));
    canvas.drawCircle(position, vehicle.wheelRadius - 11, Paint()..color = const Color(0xFF52525b));
    for (int i = 0; i < 5; i++) {
      final angle = (i * 2 * pi / 5) + vehicle.x * 0.15;
      canvas.drawLine(position, position.translate(cos(angle) * (vehicle.wheelRadius - 5) + 0.5, sin(angle) * (vehicle.wheelRadius - 5) + 0.5), Paint()..color = Colors.black.withOpacity(0.3)..strokeWidth = 3);
      canvas.drawLine(position, position.translate(cos(angle) * (vehicle.wheelRadius - 5), sin(angle) * (vehicle.wheelRadius - 5)), Paint()..color = const Color(0xFFa1a1aa)..strokeWidth = 2.5..strokeCap = StrokeCap.round);
    }
    canvas.drawCircle(position.translate(-2, -2), 3, Paint()..color = Colors.white.withOpacity(0.6));
  }

  void _drawExhaust(Canvas canvas, vehicle) {
    final random = Random(vehicle.x.toInt());
    for (int i = 0; i < 3; i++) {
      final smokeX = -30.0 - i * 8;
      final smokeY = 0.0 + random.nextDouble() * 6 - 3;
      final smokeSize = 4.0 + i * 2;
      canvas.drawCircle(Offset(smokeX, smokeY), smokeSize, Paint()..color = Colors.grey.withOpacity(0.3 - i * 0.1)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3));
    }
  }

  void _drawWheelParticles(Canvas canvas, vehicle, double cameraX, bool isSnow) {
    final random = Random(vehicle.x.toInt());
    for (int i = 0; i < 8; i++) {
      final particleX = vehicle.x - cameraX - 25 - i * 6 - random.nextDouble() * 5;
      final particleY = vehicle.y + 12 + random.nextDouble() * 8 - 4;
      final size = 4.0 - i * 0.4;
      final opacity = 0.7 - i * 0.08;
      Color particleColor = isSnow ? const Color(0xFFffffff) : const Color(0xFF78350f);
      canvas.drawCircle(Offset(particleX, particleY), size, Paint()..color = particleColor.withOpacity(opacity)..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2));
    }
  }

  void _drawSpeedLines(Canvas canvas, Size size, vehicle, double cameraX) {
    final random = Random(42);
    for (int i = 0; i < 10; i++) {
      random.nextDouble();
      final lineX = vehicle.x - cameraX - 50 - i * 30;
      final lineY = vehicle.y + random.nextDouble() * 40 - 20;
      final lineLength = 15.0 + vehicle.velocityX * 2;
      canvas.drawLine(Offset(lineX, lineY), Offset(lineX - lineLength, lineY), Paint()..color = Colors.white.withOpacity(0.3 - i * 0.025)..strokeWidth = 2..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}