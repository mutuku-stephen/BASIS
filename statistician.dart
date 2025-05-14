import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:my_stats/pages/stats.dart';

class StatisticianPage extends StatefulWidget {
  const StatisticianPage({super.key});

  @override
  StatisticianPageState createState() => StatisticianPageState();
}

class StatisticianPageState extends State<StatisticianPage> {
  String? selectedGender;
  TextEditingController dateTimeController = TextEditingController();
  TextEditingController homeTeamController = TextEditingController();
  TextEditingController opponentTeamController = TextEditingController();
  TextEditingController locationController = TextEditingController();

  List<String> playerNames = []; // List to hold player names
  Set<String> selectedPlayers = {}; // Set to hold selected player names

  // Function to fetch player names from the server based on gender
  Future<void> fetchPlayerNames(String gender) async {
    String apiUrl =
        'http://localhost/falconstats/fetchplayers.php?gender=$gender';

    try {
      final response = await http.get(Uri.parse(apiUrl));

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        if (jsonResponse['status'] == 'success') {
          setState(() {
            playerNames = List<String>.from(jsonResponse['data']);
          });
        } else {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(jsonResponse['message'])));
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Failed to fetch players')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network Error: $e')));
    }
  }

  // Function to save game details
  Future<void> saveGameDetails() async {
    String homeTeam = homeTeamController.text.trim();
    String opponentTeam = opponentTeamController.text.trim();
    String location = locationController.text.trim();
    String dateTime = dateTimeController.text.trim();

    String apiUrl = 'http://localhost/falconstats/gamedetail.php';

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'home_team': homeTeam,
          'opponent_team': opponentTeam,
          'location': location,
          'date_time': dateTime,
        },
      );

      if (response.statusCode == 200) {
        final jsonResponse = jsonDecode(response.body);

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(jsonResponse['message'])));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: Failed to save game details')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Network Error: $e')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Falcon Stats'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),

            // Game Details Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  showModalBottomSheet(
                    context: context,
                    builder: (BuildContext context) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextField(
                              controller: homeTeamController,
                              decoration: const InputDecoration(
                                labelText: 'Home Team',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: opponentTeamController,
                              decoration: const InputDecoration(
                                labelText: 'Opponent Team',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 10),
                            TextField(
                              controller: locationController,
                              decoration: const InputDecoration(
                                labelText: 'Location',
                                border: OutlineInputBorder(),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              readOnly: true,
                              controller: dateTimeController,
                              decoration: InputDecoration(
                                labelText: 'Date_Time',
                                border: const OutlineInputBorder(),
                                suffixIcon: IconButton(
                                  icon: const Icon(Icons.calendar_today),
                                  onPressed: () async {
                                    DateTime? pickedDate = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2000),
                                      lastDate: DateTime(2101),
                                    );

                                    if (pickedDate != null) {
                                      TimeOfDay? pickedTime =
                                          await showTimePicker(
                                            context: context,
                                            initialTime: TimeOfDay.now(),
                                          );

                                      if (pickedTime != null) {
                                        final dateTime = DateTime(
                                          pickedDate.year,
                                          pickedDate.month,
                                          pickedDate.day,
                                          pickedTime.hour,
                                          pickedTime.minute,
                                        );

                                        setState(() {
                                          dateTimeController.text =
                                              '${'${dateTime.toLocal()}'.split(' ')[0]} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
                                        });
                                      }
                                    }
                                  },
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              onPressed: () async {
                                await saveGameDetails();
                                Navigator.pop(context);
                              },
                              style: ElevatedButton.styleFrom(
                                foregroundColor: Colors.white,
                                backgroundColor: Colors.blue,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 40,
                                  vertical: 15,
                                ),
                                textStyle: const TextStyle(fontSize: 16),
                              ),
                              child: const Text('Save Details'),
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 40,
                    vertical: 15,
                  ),
                  textStyle: const TextStyle(fontSize: 18),
                ),
                child: const Text('Game Details'),
              ),
            ),

            const SizedBox(height: 20),

            // Select Gender Dropdown
            Center(
              child: SizedBox(
                width: 200,
                child: DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Select Player',
                    border: OutlineInputBorder(),
                  ),
                  value: selectedGender,
                  items: const [
                    DropdownMenuItem(value: 'male', child: Text('Male')),
                    DropdownMenuItem(value: 'female', child: Text('Female')),
                  ],
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedGender = newValue;
                      playerNames.clear(); // Clear previous player names
                      selectedPlayers.clear(); // Clear previous selections
                    });
                    if (newValue != null) {
                      fetchPlayerNames(newValue);
                    }
                  },
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Display player names with checkboxes
            if (playerNames.isNotEmpty)
              Expanded(
                child: ListView.builder(
                  itemCount: playerNames.length,
                  itemBuilder: (context, index) {
                    return CheckboxListTile(
                      title: Text(playerNames[index]),
                      value: selectedPlayers.contains(playerNames[index]),
                      onChanged: (bool? selected) {
                        setState(() {
                          if (selected == true) {
                            if (selectedPlayers.length < 12) {
                              selectedPlayers.add(playerNames[index]);
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    "You can only select up to 12 players.",
                                  ),
                                ),
                              );
                            }
                          } else {
                            selectedPlayers.remove(playerNames[index]);
                          }
                        });
                      },
                    );
                  },
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(8.0),
        child: ElevatedButton(
          onPressed: () {
            if (selectedPlayers.isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please select at least one player"),
                ),
              );
              return;
            }

            // Check if all game details are filled out
            if (homeTeamController.text.trim().isEmpty ||
                opponentTeamController.text.trim().isEmpty ||
                locationController.text.trim().isEmpty ||
                dateTimeController.text.trim().isEmpty) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Please fill in all game details"),
                ),
              );
              return;
            }

            Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (context) =>
                        MyStats(selectedPlayers: selectedPlayers.toList()),
              ),
            );
          },
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
            padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
            textStyle: const TextStyle(fontSize: 18),
          ),
          child: const Text('Go to My Stats'),
        ),
      ),
    );
  }
}
