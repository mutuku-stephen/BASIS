import 'package:flutter/material.dart';
import 'package:my_stats/Admin/admin_log_sign.dart';
import 'package:my_stats/Admin/coach_page.dart';
import 'package:my_stats/Admin/statistician.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const HomeScreen(),
        '/adminPage': (context) => const AdminPage(),
        '/coachPage': (context) => const CoachPage(),
        '/statisticianPage': (context) => const StatisticianPage(),
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('BASIS'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Column(
        children: [
          // Small image under AppBar
          Container(
            height: 60,
            width: double.infinity,
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: AssetImage('lib/images/blue.png'),
                fit: BoxFit.contain,
              ),
            ),
          ),

          const SizedBox(height: 20),

          // Text below the image
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0),
            child: Text(
              'Welcome to BASIS 📊\nTrack, analyze, and record your basketball team’s performance with ease. '
              'Stay on top of every shot, rebound, assist, and play\nbecause every stat tells a story.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Colors.blue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/adminPage');
        },
        backgroundColor: Colors.blue,
        child: const Text("Start"),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
