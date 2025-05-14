import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class Finalgame extends StatefulWidget {
  const Finalgame({super.key});

  @override
  State<Finalgame> createState() => _FinalgameState();
}

class _FinalgameState extends State<Finalgame> {
  List<dynamic> finalGames = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchFinalGames();
  }

  Future<void> fetchFinalGames() async {
    const String url = 'http://localhost/falconstats/fetch_final_game_data.php';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            finalGames = data['data'];
            isLoading = false;
          });
        } else {
          debugPrint('Server error: ${data['message']}');
          setState(() => isLoading = false);
        }
      } else {
        debugPrint('Request failed: ${response.statusCode}');
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint('Exception: $e');
      setState(() => isLoading = false);
    }
  }

  Widget buildGameCard(Map<String, dynamic> game) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "🏀 Game ID: ${game['game_id']}",
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text("Home Team: ${game['Home_team']} - ${game['Home_scores']}"),
            Text(
              "Opponent Team: ${game['Opponent_team']} - ${game['opponent_score']}",
            ),
            const SizedBox(height: 8),
            Text("Location: ${game['Location']}"),
            Text("Date/Time: ${game['date_time']}"),

            const SizedBox(height: 8),

            Text(
              "Result: ${game['result']}",
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            Text("Winner: ${game['winner']}"),
            const SizedBox(height: 8),

            // Displaying the Location and Date/Time
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Final Game Results"),
        backgroundColor: Colors.blueAccent,
      ),
      body:
          isLoading
              ? const Center(child: CircularProgressIndicator())
              : finalGames.isEmpty
              ? const Center(child: Text("No final games available"))
              : ListView.builder(
                itemCount: finalGames.length,
                itemBuilder: (context, index) {
                  return buildGameCard(finalGames[index]);
                },
              ),
    );
  }
}
