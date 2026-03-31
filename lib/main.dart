import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.landscapeLeft,
    DeviceOrientation.landscapeRight,
  ]);

  runApp(const BuzzerApp());
}

class BuzzerApp extends StatelessWidget {
  const BuzzerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "The Buzzer",
      debugShowCheckedModeBanner: false,
      home: const ChronoPage(),
    );
  }
}

class ChronoPage extends StatefulWidget {
  const ChronoPage({super.key});

  @override
  State<ChronoPage> createState() => _ChronoPageState();
}

class _ChronoPageState extends State<ChronoPage> {
  bool running = false;
  late Timer timer;
  double elapsed = 0;

  final thresholds = [5, 10, 15, 20, 25];
  final points = [5, 4, 3, 2, 1];

  String formatTime(double seconds) {
    int h = seconds ~/ 3600;
    int m = (seconds % 3600 ~/ 60);
    int s = (seconds % 60).toInt();
    int ms = ((seconds - seconds.toInt()) * 10).toInt();
    return "${h.toString().padLeft(2, '0')}:"
           "${m.toString().padLeft(2, '0')}:"
           "${s.toString().padLeft(2, '0')}."
           "$ms";
  }

  int calculateScore(double seconds) {
    for (int i = 0; i < thresholds.length; i++) {
      if (seconds < thresholds[i]) return points[i];
    }
    return 0;
  }

  void start() {
    running = true;
    timer = Timer.periodic(const Duration(milliseconds: 50), (_) {
      setState(() {
        elapsed += 0.05;
      });
    });
  }

  void stop() {
    running = false;
    timer.cancel();
  }

  void reset() {
    running = false;
    timer.cancel();
    setState(() {
      elapsed = 0;
    });
  }

  @override
  void dispose() {
    if (running) timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final score = calculateScore(elapsed);

    return RawKeyboardListener(
      focusNode: FocusNode(),
      autofocus: true,
      onKey: (event) {
        if (event is RawKeyDownEvent) {
          if (event.logicalKey == LogicalKeyboardKey.space) {
            if (running) {
              stop();
            } else {
              start();
            }
          }
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFF0A0F2C),
        body: Center(
          child: LayoutBuilder(
            builder: (context, constraints) {
              double scale = constraints.maxWidth / 600;

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    formatTime(elapsed),
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 60 * scale,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    "Score : $score pts",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30 * scale,
                    ),
                  ),
                  const SizedBox(height: 40),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _roundButton(
                        running ? "Stop" : "Start",
                        running ? stop : start,
                        scale,
                      ),
                      SizedBox(width: 30 * scale),
                      _roundButton("Reset", reset, scale),
                    ],
                  )
                ],
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _roundButton(String text, VoidCallback action, double scale) {
    return GestureDetector(
      onTap: action,
      child: Container(
        padding: EdgeInsets.symmetric(
          horizontal: 40 * scale,
          vertical: 20 * scale,
        ),
        decoration: BoxDecoration(
          color: const Color(0xFF1E88E5),
          borderRadius: BorderRadius.circular(30 * scale),
        ),
        child: Text(
          text,
          style: TextStyle(
            color: Colors.white,
            fontSize: 22 * scale,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}
