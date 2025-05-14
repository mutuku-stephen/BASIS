import 'package:flutter/material.dart';
import 'package:my_stats/User/finalgame.dart';
import 'package:my_stats/User/player_avg.dart';
import 'package:my_stats/User/playerstats.dart';
import 'package:my_stats/User/quarterstats.dart';

class StatViewStats extends StatefulWidget {
  const StatViewStats({super.key});

  @override
  State<StatViewStats> createState() => _StatViewStatsState();
}

class _StatViewStatsState extends State<StatViewStats> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('View Stats'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 10,
          crossAxisSpacing: 10,
          childAspectRatio: 2.5,
          children: [
            _buildCardButton(
              title: 'Player Stats',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PlayerStats()),
                );
              },
            ),
            _buildCardButton(
              title: 'Quarter Stats',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => QuarterStats()),
                );
              },
            ),
            _buildCardButton(
              title: 'Final Game',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Finalgame()),
                );
              },
            ),
            _buildCardButton(
              title: 'Overall Player Performance',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => PlayerAvg()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCardButton({
    required String title,
    required VoidCallback onTap,
  }) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(color: Colors.blue, width: 2),
      ),
      color: Colors.blue,
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
            child: Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 12, color: Colors.white),
            ),
          ),
        ),
      ),
    );
  }
}
