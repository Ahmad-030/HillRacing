import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'Screens/MenuScreen.dart';
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations([
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);
  runApp(const HillClimbApp());
}

class HillClimbApp extends StatelessWidget {
  const HillClimbApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Hill Climb Racing',
      theme: ThemeData.dark().copyWith(
        primaryColor: Colors.orange,
        scaffoldBackgroundColor: const Color(0xFF87CEEB),
      ),
      home: const MenuScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
