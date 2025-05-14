import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:my_stats/User/statviewstats.dart';
import 'package:my_stats/pages/statsInputcell.dart';

class MyStats extends StatefulWidget {
  final List<String> selectedPlayers;

  const MyStats({super.key, required this.selectedPlayers});

  @override
  MyStatsState createState() => MyStatsState();
}

class MyStatsState extends State<MyStats> {
  int totalPoints = 0;
  int opponentScore = 0;
  int currentQuarter = 1;
  String homeTeam = '';
  String opponentTeam = '';
  String location = '';
  String dateTime = '';
  String gameId = '';
  int? quarterId;

  late List<int> playerPoints;
  late List<Map<String, int>> playerStats;
  late List<Map<String, int>> playerQuarterStats;

  List<String> get selectedPlayers => widget.selectedPlayers;

  @override
  void initState() {
    super.initState();
    playerPoints = List.filled(selectedPlayers.length, 0);
    playerStats = List.generate(selectedPlayers.length, (_) {
      return {
        'ft_made': 0,
        'ft_missed': 0,
        'two_pt_made': 0,
        'two_pt_missed': 0,
        'three_pt_made': 0,
        'three_pt_missed': 0,
        'off_reb': 0,
        'def_reb': 0,
        'steals': 0,
        'turnovers': 0,
        'assists': 0,
        'blocks': 0,
        'fouls': 0,
      };
    });
    playerQuarterStats = List.generate(selectedPlayers.length, (_) {
      return {
        'ft_made': 0,
        'ft_missed': 0,
        'two_pt_made': 0,
        'two_pt_missed': 0,
        'three_pt_made': 0,
        'three_pt_missed': 0,
        'off_reb': 0,
        'def_reb': 0,
        'steals': 0,
        'turnovers': 0,
        'assists': 0,
        'blocks': 0,
        'fouls': 0,
      };
    });

    fetchGameDetails();
  }

  Future<void> fetchGameDetails() async {
    final response = await http.get(
      Uri.parse('http://localhost/falconstats/gamefetch.php'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      if (data['status'] == 'success') {
        setState(() {
          gameId = data['data']['game_id'].toString();
          homeTeam = data['data']['home_team'];
          opponentTeam = data['data']['opponent_team'];
          location = data['data']['Location'];
          dateTime = data['data']['date_time'];
        });
      }
    } else {
      setState(() {
        homeTeam = 'Failed to load game details';
        opponentTeam = '';
        location = '';
        dateTime = '';
        gameId = '';
      });
    }
  }

  void updateTotalPoints(int playerIndex, int points) {
    setState(() {
      playerPoints[playerIndex] += points;
      totalPoints += points;
    });
  }

  void incrementOpponentScore() {
    setState(() {
      opponentScore++;
    });
  }

  void decrementOpponentScore() {
    setState(() {
      if (opponentScore > 0) opponentScore--;
    });
  }

  int calculateQuarterPoints(int index) {
    return (playerQuarterStats[index]['ft_made'] ?? 0) * 1 +
        (playerQuarterStats[index]['two_pt_made'] ?? 0) * 2 +
        (playerQuarterStats[index]['three_pt_made'] ?? 0) * 3;
  }

  void setQuarter(int quarter) {
    if (quarter == currentQuarter) return;

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text("Switch Quarter?"),
            content: const Text(
              "Are you sure you want to switch quarters? Unsaved data will be lost.",
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text("Cancel"),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    currentQuarter = quarter;
                    playerQuarterStats = List.generate(
                      selectedPlayers.length,
                      (_) => {
                        'ft_made': 0,
                        'ft_missed': 0,
                        'two_pt_made': 0,
                        'two_pt_missed': 0,
                        'three_pt_made': 0,
                        'three_pt_missed': 0,
                        'off_reb': 0,
                        'def_reb': 0,
                        'steals': 0,
                        'turnovers': 0,
                        'assists': 0,
                        'blocks': 0,
                        'fouls': 0,
                      },
                    );
                  });
                  Navigator.pop(context);
                },
                child: const Text("Confirm"),
              ),
            ],
          ),
    );
  }

  void updateStat(int playerIndex, String statKey, int value) {
    setState(() {
      int previousValue = playerStats[playerIndex][statKey]!;
      int diff = value - previousValue;
      playerStats[playerIndex][statKey] = value;
      playerQuarterStats[playerIndex][statKey] =
          (playerQuarterStats[playerIndex][statKey] ?? 0) + diff;
    });
  }

  Future<void> saveStats(BuildContext context) async {
    if (gameId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Game ID is missing. Cannot save stats.')),
      );
      return;
    }

    // Step 1: Save quarter
    final quarterResponse = await http.post(
      Uri.parse('http://localhost/falconstats/savestats.php'),
      body: {
        'mode': 'save_quarter',
        'quarter_number': currentQuarter.toString(),
        'opponent_score': opponentScore.toString(),
        'totalPoints': totalPoints.toString(),
      },
    );

    if (quarterResponse.statusCode == 200) {
      final quarterData = jsonDecode(quarterResponse.body);
      if (quarterData['status'] == 'success') {
        quarterId = quarterData['data']['quarter_id'];
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save quarter: ${quarterData['message']}'),
          ),
        );
        return;
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error while saving quarter')));
      return;
    }

    // Step 2: Save stats for all players
    List<Map<String, dynamic>> statsToSave = [];
    for (int i = 0; i < selectedPlayers.length; i++) {
      statsToSave.add({
        'player_name': selectedPlayers[i],
        'ft_made': playerQuarterStats[i]['ft_made'].toString(),
        'ft_missed': playerQuarterStats[i]['ft_missed'].toString(),
        'two_pt_made': playerQuarterStats[i]['two_pt_made'].toString(),
        'two_pt_missed': playerQuarterStats[i]['two_pt_missed'].toString(),
        'three_pt_made': playerQuarterStats[i]['three_pt_made'].toString(),
        'three_pt_missed': playerQuarterStats[i]['three_pt_missed'].toString(),
        'off_reb': playerQuarterStats[i]['off_reb'].toString(),
        'def_reb': playerQuarterStats[i]['def_reb'].toString(),
        'steals': playerQuarterStats[i]['steals'].toString(),
        'turnovers': playerQuarterStats[i]['turnovers'].toString(),
        'assists': playerQuarterStats[i]['assists'].toString(),
        'blocks': playerQuarterStats[i]['blocks'].toString(),
        'fouls': playerQuarterStats[i]['fouls'].toString(),
        'points': calculateQuarterPoints(i).toString(),
      });
    }

    final statsResponse = await http.post(
      Uri.parse('http://localhost/falconstats/savestats.php'),
      body: {
        'mode': 'save_stats_batch',
        'quarter_id': quarterId.toString(),
        'stats': jsonEncode(statsToSave),
      },
    );

    if (statsResponse.statusCode == 200) {
      final responseData = jsonDecode(statsResponse.body);
      if (responseData['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Stats saved for Quarter $currentQuarter!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to save stats: ${responseData['message']}'),
          ),
        );
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error saving stats')));
    }
  }

  void saveScores(BuildContext context) {
    saveStats(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Scores saved for Quarter $currentQuarter!')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          gameDetailsHeader(),
          Expanded(child: statsTable()),
          footerControls(context),
        ],
      ),
    );
  }

  Widget gameDetailsHeader() {
    return Container(
      height: kToolbarHeight,
      color: Colors.blue,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        child: Row(
          children: [
            gameInfoBox('Game: $gameId'),
            gameInfoBox('Location: $location'),
            gameInfoBox('Home Team: $homeTeam'),
            gameInfoBox('Team B: $opponentTeam'),
            gameInfoBox('Date_Time: $dateTime'),
            Spacer(),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => StatViewStats()),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: Colors.blue,
                padding: EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
              ),
              child: Text('View Stats'),
            ),
          ],
        ),
      ),
    );
  }

  Widget gameInfoBox(String text) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          text,
          style: const TextStyle(
            color: Colors.blue,
            fontSize: 9,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget statsTable() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: SingleChildScrollView(
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.all(2.0),
          child: Table(
            border: TableBorder.all(),
            defaultColumnWidth: const IntrinsicColumnWidth(),
            children: [
              TableRow(
                decoration: const BoxDecoration(
                  color: Color.fromARGB(212, 18, 186, 228),
                ),
                children: [
                  for (var header in [
                    'Player',
                    'FT Md',
                    'FT Msd',
                    '2PT Md',
                    '2PT Msd',
                    '3PT Md',
                    '3PT Msd',
                    'Off Reb',
                    'Def Reb',
                    'Steals',
                    'Turnovers',
                    'Assists',
                    'Blocks',
                    'Fouls',
                    'Points',
                  ])
                    headerCell(header),
                ],
              ),
              for (int i = 0; i < selectedPlayers.length; i++)
                TableRow(children: buildPlayerCells(i)),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> buildPlayerCells(int i) {
    return [
      tableCell(selectedPlayers[i]),
      StatInputCell(
        label: 'FT Md',
        points: 1,
        playerIndex: i,
        onScored: updateTotalPoints,
        onStatChanged: updateStat,
        statKey: 'ft_made',
      ),
      StatInputCell(
        label: 'FT Msd',
        playerIndex: i,
        onStatChanged: updateStat,
        statKey: 'ft_missed',
      ),
      StatInputCell(
        label: '2PT Md',
        points: 2,
        playerIndex: i,
        onScored: updateTotalPoints,
        onStatChanged: updateStat,
        statKey: 'two_pt_made',
      ),
      StatInputCell(
        label: '2PT Msd',
        playerIndex: i,
        onStatChanged: updateStat,
        statKey: 'two_pt_missed',
      ),
      StatInputCell(
        label: '3PT Md',
        points: 3,
        playerIndex: i,
        onScored: updateTotalPoints,
        onStatChanged: updateStat,
        statKey: 'three_pt_made',
      ),
      StatInputCell(
        label: '3PT Msd',
        playerIndex: i,
        onStatChanged: updateStat,
        statKey: 'three_pt_missed',
      ),
      StatInputCell(
        label: 'Off Reb',
        playerIndex: i,
        onStatChanged: updateStat,
        statKey: 'off_reb',
      ),
      StatInputCell(
        label: 'Def Reb',
        playerIndex: i,
        onStatChanged: updateStat,
        statKey: 'def_reb',
      ),
      StatInputCell(
        label: 'Steals',
        playerIndex: i,
        onStatChanged: updateStat,
        statKey: 'steals',
      ),
      StatInputCell(
        label: 'Turnovers',
        playerIndex: i,
        onStatChanged: updateStat,
        statKey: 'turnovers',
      ),
      StatInputCell(
        label: 'Assists',
        playerIndex: i,
        onStatChanged: updateStat,
        statKey: 'assists',
      ),
      StatInputCell(
        label: 'Blocks',
        playerIndex: i,
        onStatChanged: updateStat,
        statKey: 'blocks',
      ),
      StatInputCell(
        label: 'Fouls',
        playerIndex: i,
        isFoul: true,
        onStatChanged: updateStat,
        statKey: 'fouls',
      ),
      tableCell(playerPoints[i].toString()),
    ];
  }

  Widget headerCell(String label) {
    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Center(
        child: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 9),
        ),
      ),
    );
  }

  Widget tableCell(String content) {
    return Padding(
      padding: const EdgeInsets.all(6.0),
      child: Center(child: Text(content, style: const TextStyle(fontSize: 9))),
    );
  }

  Widget footerControls(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Home Score: $totalPoints",
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            children: List.generate(4, (index) {
              int quarter = index + 1;
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                child: ElevatedButton(
                  onPressed: () => setQuarter(quarter),
                  style: ElevatedButton.styleFrom(
                    foregroundColor:
                        currentQuarter == quarter ? Colors.white : Colors.blue,
                    backgroundColor:
                        currentQuarter == quarter
                            ? Colors.blue
                            : Colors.grey[300],
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    textStyle: const TextStyle(fontSize: 12),
                  ),
                  child: Text("Q$quarter"),
                ),
              );
            }),
          ),
          Row(
            children: [
              ElevatedButton(
                onPressed: decrementOpponentScore,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                ),
                child: const Icon(Icons.remove),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: Text(
                  "Opponent Score: $opponentScore",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              ElevatedButton(
                onPressed: incrementOpponentScore,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 5,
                  ),
                ),
                child: const Icon(Icons.add),
              ),
            ],
          ),
          ElevatedButton(
            onPressed: () => saveScores(context),
            child: const Text("Save"),
          ),
        ],
      ),
    );
  }
}
