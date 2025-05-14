import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class QuarterStats extends StatefulWidget {
  const QuarterStats({super.key});

  @override
  _LatestStatsPageState createState() => _LatestStatsPageState();
}

class _LatestStatsPageState extends State<QuarterStats> {
  late Future<Map<String, dynamic>> futureStats;

  @override
  void initState() {
    super.initState();
    futureStats = fetchLatestStats();
  }

  Future<Map<String, dynamic>> fetchLatestStats() async {
    final response = await http.get(
      Uri.parse('http://localhost/falconstats/get_latest_stats.php'),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load stats');
    }
  }

  Widget buildStatDetails(Map<String, dynamic> stat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FT Made: ${stat['ft_made']}, FT Missed: ${stat['ft_missed']}'),
        Text(
          '2PT Made: ${stat['two_pt_made']}, 2PT Missed: ${stat['two_pt_missed']}',
        ),
        Text(
          '3PT Made: ${stat['three_pt_made']}, 3PT Missed: ${stat['three_pt_missed']}',
        ),
        Text(
          'Off Rebounds: ${stat['off_reb']}, Def Rebounds: ${stat['def_reb']}',
        ),
        Text('Steals: ${stat['steals']}, Turnovers: ${stat['turnovers']}'),
        Text(
          'Assists: ${stat['assists']}, Blocks: ${stat['blocks']}, Fouls: ${stat['fouls']}',
        ),
        Text('Total Points: ${stat['points']}'),
      ],
    );
  }

  Widget buildPercentageStats(Map<String, dynamic> stat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('FG%: ${stat['FG%']}%'),
        Text('2PT%: ${stat['2PT%']}%'),
        Text('3PT%: ${stat['3PT%']}%'),
        Text('FT%: ${stat['FT%']}%'),
      ],
    );
  }

  Map<String, List<Map<String, dynamic>>> groupStatsByQuarter(
    List<dynamic> stats,
  ) {
    Map<String, List<Map<String, dynamic>>> grouped = {};
    for (var stat in stats) {
      String quarter = stat['quarter_number'].toString();
      if (!grouped.containsKey(quarter)) {
        grouped[quarter] = [];
      }
      grouped[quarter]!.add(stat);
    }
    return grouped;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Latest Game Stats")),
      body: FutureBuilder<Map<String, dynamic>>(
        future: futureStats,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final data = snapshot.data!;
          final stats = data['stats'] as List<dynamic>;
          final quarterlyStats = data['quarterly_stats'] as List<dynamic>;
          final gameId = data['latest_game_id'];
          final quarterNumber = data['latest_quarter_number'];

          final groupedStats = groupStatsByQuarter(stats);

          // Filter unique quarters (max 4)
          final uniqueQuarters = <String, Map<String, dynamic>>{};
          for (var qstat in quarterlyStats) {
            final qNum = qstat['quarter_number'].toString();
            if (!uniqueQuarters.containsKey(qNum)) {
              uniqueQuarters[qNum] = qstat;
            }
          }

          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '📌 Game ID: $gameId, Latest Quarter: $quarterNumber',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  SizedBox(height: 15),
                  Text(
                    '📊 Player Stats by Quarter',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  // Display player stats per quarter
                  ...groupedStats.entries.map((entry) {
                    final quarter = entry.key;
                    final quarterStats = entry.value;

                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 10),
                      color: Colors.deepPurple.shade50,
                      child: Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '🏀 Quarter $quarter',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.deepPurple,
                              ),
                            ),
                            SizedBox(height: 10),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              itemCount: quarterStats.length,
                              itemBuilder: (context, index) {
                                final stat = quarterStats[index];
                                return Card(
                                  margin: EdgeInsets.symmetric(vertical: 6),
                                  child: Padding(
                                    padding: const EdgeInsets.all(10.0),
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          stat['player_name'],
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        SizedBox(height: 5),
                                        Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Expanded(
                                              child: buildStatDetails(stat),
                                            ),
                                            SizedBox(width: 10),
                                            Expanded(
                                              child: buildPercentageStats(stat),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  Divider(thickness: 2, height: 30),
                  Text(
                    '📋 Quarterly Scores',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 10),

                  // Show only one card per unique quarter (max 4)
                  ...uniqueQuarters.entries.take(4).map((entry) {
                    final quarter = entry.key;
                    final data = entry.value;
                    return Card(
                      margin: EdgeInsets.symmetric(vertical: 5),
                      child: ListTile(
                        title: Text('Quarter $quarter'),
                        subtitle: Text(
                          'Home: ${data['Home_team']}, Opponent: ${data['Opponent_team']}',
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
