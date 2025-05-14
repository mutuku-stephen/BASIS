import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PlayerAvg extends StatefulWidget {
  const PlayerAvg({super.key});

  @override
  State<PlayerAvg> createState() => _PlayerAvgState();
}

class _PlayerAvgState extends State<PlayerAvg> {
  late Future<Map<String, dynamic>> futureAverages;

  @override
  void initState() {
    super.initState();
    futureAverages = fetchAverages();
  }

  Future<Map<String, dynamic>> fetchAverages() async {
    final response = await http.get(
      Uri.parse('http://localhost/falconstats/playeravg.php'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load player averages');
    }
  }

  Widget buildAverageCard(String player, Map<String, dynamic> stats) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              player,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text('Appearances: ${stats['appearances']}'),
            Text('Total Points: ${stats['total_points']}'),
            Text('FG% Avg: ${stats['average_fg%']}%'),
            Text('2PT% Avg: ${stats['average_2pt%']}%'),
            Text('3PT% Avg: ${stats['average_3pt%']}%'),
            Text('FT% Avg: ${stats['average_ft%']}%'),
            Text(
              'Performance Score Avg: ${stats['average_performance_score']}',
            ), // <-- New line
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Average Player Performance")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureAverages,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          if (!data['success']) {
            return const Center(child: Text("No average data found."));
          }

          final averages = data['average_performance'] as Map<String, dynamic>;

          return ListView.builder(
            itemCount: averages.length,
            itemBuilder: (context, index) {
              final playerName = averages.keys.elementAt(index);
              final stats = averages[playerName] as Map<String, dynamic>;
              return buildAverageCard(playerName, stats);
            },
          );
        },
      ),
    );
  }
}
