import 'package:flutter/material.dart';
import 'package:my_stats/User/finalgame.dart';
import 'package:my_stats/User/myplayer.dart';
import 'package:my_stats/User/player_avg.dart';
import 'package:my_stats/User/playerstats.dart';
import 'package:my_stats/User/quarterstats.dart';
import 'coach_logic.dart';

class CoachPage extends StatefulWidget {
  const CoachPage({super.key});

  @override
  State<CoachPage> createState() => _CoachPageState();
}

class _CoachPageState extends State<CoachPage> {
  final CoachPageLogic logic = CoachPageLogic();

  Widget _blueTextField(
    String hint,
    TextEditingController controller,
    VoidCallback onChanged,
  ) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: TextField(
      controller: controller,
      decoration: InputDecoration(
        labelText: hint,
        labelStyle: const TextStyle(color: Colors.blue),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.blue),
        ),
      ),
      onChanged: (_) => onChanged(),
    ),
  );

  void _showDrawerForm(Widget form) {
    Navigator.pop(context);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder:
          (_) => Padding(
            padding: MediaQuery.of(
              context,
            ).viewInsets.add(const EdgeInsets.all(16)),
            child: SingleChildScrollView(child: form),
          ),
    );
  }

  bool _allControllersFilled(List<TextEditingController> controllers) {
    return controllers.every((controller) => controller.text.trim().isNotEmpty);
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.green),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            const Spacer(),
            const SizedBox(width: 10),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: Colors.white),
              onSelected: (value) {
                if (value == 'logout') Navigator.pop(context);
              },
              itemBuilder:
                  (_) => [
                    const PopupMenuItem(value: 'logout', child: Text('Logout')),
                  ],
            ),
          ],
        ),
        backgroundColor: Colors.blue,
      ),
      drawer: Drawer(
        child: Column(
          children: [
            SizedBox(
              height: 120,
              child: DrawerHeader(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('lib/images/blue.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: const Align(alignment: Alignment.bottomLeft),
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.blue,
                child: Column(
                  children: [
                    ListTile(
                      title: const Text('Register Team'),
                      onTap:
                          () => _showDrawerForm(
                            StatefulBuilder(
                              builder:
                                  (context, setStateModal) => Column(
                                    children: [
                                      _blueTextField(
                                        'Team Name',
                                        logic.teamNameController,
                                        () => setStateModal(() {}),
                                      ),
                                      _blueTextField(
                                        'Team Coach',
                                        logic.teamCoachController,
                                        () => setStateModal(() {}),
                                      ),
                                      _blueTextField(
                                        'Assistant Coach',
                                        logic.teamAssistantCoachController,
                                        () => setStateModal(() {}),
                                      ),
                                      _blueTextField(
                                        'Manager',
                                        logic.teamManagerController,
                                        () => setStateModal(() {}),
                                      ),
                                      _blueTextField(
                                        'Doctor',
                                        logic.teamDoctorController,
                                        () => setStateModal(() {}),
                                      ),
                                      _blueTextField(
                                        'Statistician',
                                        logic.teamStatisticianController,
                                        () => setStateModal(() {}),
                                      ),
                                      ElevatedButton(
                                        onPressed:
                                            _allControllersFilled([
                                                  logic.teamNameController,
                                                  logic.teamCoachController,
                                                  logic
                                                      .teamAssistantCoachController,
                                                  logic.teamManagerController,
                                                  logic.teamDoctorController,
                                                  logic
                                                      .teamStatisticianController,
                                                ])
                                                ? () {
                                                  logic.registerTeam(context);
                                                  Navigator.pop(context);
                                                  _showSnackBar(
                                                    'Team registered successfully!',
                                                  );
                                                }
                                                : null,
                                        child: const Text('Register Team'),
                                      ),
                                    ],
                                  ),
                            ),
                          ),
                    ),
                    ListTile(
                      title: const Text('Register Player'),
                      onTap:
                          () => _showDrawerForm(
                            StatefulBuilder(
                              builder:
                                  (context, setStateModal) => Column(
                                    children: [
                                      _blueTextField(
                                        'League Number',
                                        logic.leagueNumberController,
                                        () => setStateModal(() {}),
                                      ),
                                      _blueTextField(
                                        'First Name',
                                        logic.firstNameController,
                                        () => setStateModal(() {}),
                                      ),
                                      _blueTextField(
                                        'Last Name',
                                        logic.lastNameController,
                                        () => setStateModal(() {}),
                                      ),
                                      _blueTextField(
                                        'Nationality',
                                        logic.nationalityController,
                                        () => setStateModal(() {}),
                                      ),
                                      _blueTextField(
                                        'Age',
                                        logic.ageController,
                                        () => setStateModal(() {}),
                                      ),
                                      _blueTextField(
                                        'Height',
                                        logic.heightController,
                                        () => setStateModal(() {}),
                                      ),
                                      _blueTextField(
                                        'Weight',
                                        logic.weightController,
                                        () => setStateModal(() {}),
                                      ),
                                      _blueTextField(
                                        'Player Team',
                                        logic.playerTeamController,
                                        () => setStateModal(() {}),
                                      ),
                                      _blueTextField(
                                        'Position',
                                        logic.positionController,
                                        () => setStateModal(() {}),
                                      ),
                                      _blueTextField(
                                        'Gender',
                                        logic.genderController,
                                        () => setStateModal(() {}),
                                      ),
                                      ElevatedButton(
                                        onPressed:
                                            _allControllersFilled([
                                                  logic.leagueNumberController,
                                                  logic.firstNameController,
                                                  logic.lastNameController,
                                                  logic.nationalityController,
                                                  logic.ageController,
                                                  logic.heightController,
                                                  logic.weightController,
                                                  logic.playerTeamController,
                                                  logic.positionController,
                                                  logic.genderController,
                                                ])
                                                ? () {
                                                  logic.registerPlayer(context);
                                                  Navigator.pop(context);
                                                  _showSnackBar(
                                                    'Player registered successfully!',
                                                  );
                                                }
                                                : null,
                                        child: const Text('Register Player'),
                                      ),
                                    ],
                                  ),
                            ),
                          ),
                    ),
                    ListTile(
                      title: const Text('Add Fixtures'),
                      onTap:
                          () => _showDrawerForm(
                            StatefulBuilder(
                              builder:
                                  (context, setStateModal) => Column(
                                    children: [
                                      _blueTextField(
                                        'Team A',
                                        logic.teamAController,
                                        () => setStateModal(() {}),
                                      ),
                                      _blueTextField(
                                        'Team B',
                                        logic.teamBController,
                                        () => setStateModal(() {}),
                                      ),
                                      _blueTextField(
                                        'Location',
                                        logic.locationController,
                                        () => setStateModal(() {}),
                                      ),
                                      TextField(
                                        controller: logic.timeController,
                                        readOnly: true,
                                        onTap: () async {
                                          await logic.pickDateTime(context);
                                          setState(() {});
                                          setStateModal(() {});
                                        },
                                        decoration: const InputDecoration(
                                          labelText: 'Time',
                                          labelStyle: TextStyle(
                                            color: Colors.blue,
                                          ),
                                          border: OutlineInputBorder(),
                                        ),
                                      ),
                                      const SizedBox(height: 10),
                                      ElevatedButton(
                                        onPressed:
                                            _allControllersFilled([
                                                  logic.teamAController,
                                                  logic.teamBController,
                                                  logic.locationController,
                                                  logic.timeController,
                                                ])
                                                ? () {
                                                  logic.addFixture(context);
                                                  Navigator.pop(context);
                                                  _showSnackBar(
                                                    'Fixture added successfully!',
                                                  );
                                                }
                                                : null,
                                        child: const Text('Add Fixture'),
                                      ),
                                    ],
                                  ),
                            ),
                          ),
                    ),
                    ListTile(
                      title: const Text('View My Players'),
                      onTap: () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => MyPlayer()),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
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
