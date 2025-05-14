import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class MyPlayer extends StatefulWidget {
  const MyPlayer({super.key});

  @override
  State<MyPlayer> createState() => _MyPlayerState();
}

class _MyPlayerState extends State<MyPlayer> {
  List<String> players = [];
  String? selectedPlayer;
  // Replace with your server's IP address
  final String serverIp = 'http://localhost/falconstats/myplayers.php';

  @override
  void initState() {
    super.initState();
    fetchPlayers();
  }

  Future<void> fetchPlayers() async {
    try {
      final response = await http.get(Uri.parse(serverIp));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success']) {
          setState(() {
            players = List<String>.from(data['players']);
            selectedPlayer = null;
          });
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(data['message'])));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to fetch players')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error fetching players: $error')));
    }
  }

  Future<void> deletePlayer(String playerName) async {
    try {
      final response = await http.post(
        Uri.parse(serverIp),
        headers: {"Content-Type": "application/json"},
        body: json.encode({"player_name": playerName}),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(data['message'])));
        fetchPlayers(); // Refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to delete player')),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error deleting player: $error')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Daystar Falcons Players")),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemCount: players.length,
              itemBuilder: (context, index) {
                final player = players[index];
                return CheckboxListTile(
                  title: Text(player),
                  value: selectedPlayer == player,
                  onChanged: (bool? value) {
                    setState(() {
                      selectedPlayer = value == true ? player : null;
                    });
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: ElevatedButton(
              onPressed:
                  selectedPlayer != null
                      ? () => deletePlayer(selectedPlayer!)
                      : null,
              child: const Text("Delete Selected Player"),
            ),
          ),
        ],
      ),
    );
  }
}
