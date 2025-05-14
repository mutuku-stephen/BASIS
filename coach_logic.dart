import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class CoachPageLogic {
  // Team registration
  final TextEditingController teamNameController = TextEditingController();
  final TextEditingController teamCoachController = TextEditingController();
  final TextEditingController teamAssistantCoachController =
      TextEditingController();
  final TextEditingController teamManagerController = TextEditingController();
  final TextEditingController teamStatisticianController =
      TextEditingController();
  final TextEditingController teamDoctorController = TextEditingController();

  // Player registration
  final TextEditingController leagueNumberController = TextEditingController();
  final TextEditingController firstNameController = TextEditingController();
  final TextEditingController lastNameController = TextEditingController();
  final TextEditingController nationalityController = TextEditingController();
  final TextEditingController ageController = TextEditingController();
  final TextEditingController heightController = TextEditingController();
  final TextEditingController weightController = TextEditingController();
  final TextEditingController playerTeamController = TextEditingController();
  final TextEditingController positionController = TextEditingController();
  final TextEditingController genderController = TextEditingController();

  // Fixture
  final TextEditingController teamAController = TextEditingController();
  final TextEditingController teamBController = TextEditingController();
  final TextEditingController locationController = TextEditingController();
  final TextEditingController timeController = TextEditingController();

  Future<void> pickDateTime(BuildContext context) async {
    final DateTime? date = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );

    if (date != null) {
      final TimeOfDay? time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
      );

      if (time != null) {
        final DateTime dateTime = DateTime(
          date.year,
          date.month,
          date.day,
          time.hour,
          time.minute,
        );
        final formatted =
            "${dateTime.year}-${_twoDigits(dateTime.month)}-${_twoDigits(dateTime.day)} "
            "${_twoDigits(dateTime.hour)}:${_twoDigits(dateTime.minute)}";
        timeController.text = formatted;
      }
    }
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  Future<void> registerTeam(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/falconstats/coach.php'),
        body: {
          'action': 'register_team',
          'team_name': teamNameController.text,
          'team_coach': teamCoachController.text,
          'team_assistant_coach': teamAssistantCoachController.text,
          'team_manager': teamManagerController.text,
          'team_statistician': teamStatisticianController.text,
          'team_doctor': teamDoctorController.text,
        },
      );

      final data = json.decode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message']),
          backgroundColor:
              data['status'] == 'success' ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while registering the team.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> registerPlayer(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/falconstats/coach.php'),
        body: {
          'action': 'register_player',
          'league_number': leagueNumberController.text,
          'first_name': firstNameController.text,
          'last_name': lastNameController.text,
          'nationality': nationalityController.text,
          'age': ageController.text,
          'height': heightController.text,
          'weight': weightController.text,
          'players_team': playerTeamController.text,
          'position': positionController.text,
          'gender': genderController.text,
        },
      );

      final data = json.decode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message']),
          backgroundColor:
              data['status'] == 'success' ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An unexpected error occurred. Please try again.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> addFixture(BuildContext context) async {
    try {
      final response = await http.post(
        Uri.parse('http://localhost/falconstats/coach.php'),
        body: {
          'action': 'add_fixture',
          'team_a': teamAController.text,
          'team_b': teamBController.text,
          'location': locationController.text,
          'time': timeController.text,
        },
      );

      final data = json.decode(response.body);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(data['message']),
          backgroundColor:
              data['status'] == 'success' ? Colors.green : Colors.red,
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('An error occurred while adding fixture.'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }
}
