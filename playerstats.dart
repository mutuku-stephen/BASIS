import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class PlayerStats extends StatefulWidget {
  const PlayerStats({super.key});

  @override
  State<PlayerStats> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<PlayerStats> {
  bool _isSearching = false;
  final TextEditingController _searchController = TextEditingController();
  List<dynamic> playerStats = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchPlayerStats();
  }

  Future<void> fetchPlayerStats() async {
    const String url =
        'http://localhost/falconstats/fetch_cumulative_stats.php'; // Make sure this is correct

    try {
      final response = await http.post(
        Uri.parse(url),
      ); // Use POST as per API headers

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['success'] == true) {
          setState(() {
            playerStats = jsonData['data'];
            isLoading = false;
          });
        } else {
          debugPrint("Server error: ${jsonData['message']}");
          setState(() => isLoading = false);
        }
      } else {
        debugPrint("Failed to load: ${response.statusCode}");
        setState(() => isLoading = false);
      }
    } catch (e) {
      debugPrint("Exception: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<String> headers = [
      'game_id',
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
    ];

    return Scaffold(
      appBar: AppBar(
        title:
            _isSearching
                ? TextField(
                  controller: _searchController,
                  autofocus: true,
                  decoration: const InputDecoration(
                    hintText: 'Search...',
                    border: InputBorder.none,
                  ),
                )
                : const Center(child: Text('Falcon Stats')),
        backgroundColor: Colors.blue,
        actions: [
          IconButton(
            icon: Icon(_isSearching ? Icons.close : Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
                if (!_isSearching) {
                  _searchController.clear();
                }
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          SizedBox(height: 100, width: double.infinity),
          Expanded(
            child:
                isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Card(
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.all(12),
                          child: DataTable(
                            columns:
                                headers
                                    .map(
                                      (header) =>
                                          DataColumn(label: Text(header)),
                                    )
                                    .toList(),
                            rows:
                                playerStats.map<DataRow>((player) {
                                  return DataRow(
                                    cells:
                                        headers.map((key) {
                                          return DataCell(
                                            Text('${player[key]}'),
                                          );
                                        }).toList(),
                                  );
                                }).toList(),
                          ),
                        ),
                      ),
                    ),
          ),
        ],
      ),
    );
  }
}
