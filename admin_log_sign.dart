import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;

class AdminPage extends StatefulWidget {
  const AdminPage({super.key});

  @override
  _AdminPageState createState() => _AdminPageState();
}

class _AdminPageState extends State<AdminPage> {
  final String apiUrl = 'http://localhost/falconstats/logsig.php';

  final TextEditingController _loginIdController = TextEditingController();
  final TextEditingController _loginPasswordController =
      TextEditingController();
  bool _obscureLoginPassword = true;

  final TextEditingController _signupIdController = TextEditingController();
  final TextEditingController _signupPasswordController =
      TextEditingController();
  final TextEditingController _signupConfirmPasswordController =
      TextEditingController();
  bool _obscureSignupPassword = true;
  bool _obscureSignupConfirmPassword = true;

  final TextEditingController _resetIdController = TextEditingController();
  final TextEditingController _resetPasswordController =
      TextEditingController();
  final TextEditingController _resetConfirmPasswordController =
      TextEditingController();
  bool _obscureResetPassword = true;
  bool _obscureResetConfirmPassword = true;

  void _showSignupDrawer(BuildContext context, String userType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: MediaQuery.of(
                context,
              ).viewInsets.add(const EdgeInsets.all(16.0)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _signupIdController,
                    decoration: _buildInputDecoration("Enter ID (5 digits)"),
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _signupPasswordController,
                    obscureText: _obscureSignupPassword,
                    decoration: _buildPasswordInput(
                      "Password",
                      _obscureSignupPassword,
                      () => setModalState(
                        () => _obscureSignupPassword = !_obscureSignupPassword,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _signupConfirmPasswordController,
                    obscureText: _obscureSignupConfirmPassword,
                    decoration: _buildPasswordInput(
                      "Confirm Password",
                      _obscureSignupConfirmPassword,
                      () => setModalState(
                        () =>
                            _obscureSignupConfirmPassword =
                                !_obscureSignupConfirmPassword,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      if (_validateSignup()) {
                        _signupUser(context, userType);
                      }
                    },
                    style: _buttonStyle(),
                    child: const Text(
                      'Sign Up',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  void _showForgotPasswordDrawer() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: MediaQuery.of(
                context,
              ).viewInsets.add(const EdgeInsets.all(16.0)),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _resetIdController,
                    decoration: _buildInputDecoration("Enter ID (5 digits)"),
                    keyboardType: TextInputType.number,
                    maxLength: 5,
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _resetPasswordController,
                    obscureText: _obscureResetPassword,
                    decoration: _buildPasswordInput(
                      "New Password",
                      _obscureResetPassword,
                      () => setModalState(
                        () => _obscureResetPassword = !_obscureResetPassword,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _resetConfirmPasswordController,
                    obscureText: _obscureResetConfirmPassword,
                    decoration: _buildPasswordInput(
                      "Confirm New Password",
                      _obscureResetConfirmPassword,
                      () => setModalState(
                        () =>
                            _obscureResetConfirmPassword =
                                !_obscureResetConfirmPassword,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _validateResetPassword,
                    style: _buttonStyle(),
                    child: const Text(
                      'Reset Password',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  bool _validateSignup() {
    if (_signupIdController.text.length != 5 ||
        int.tryParse(_signupIdController.text) == null) {
      _showErrorDialog('ID must be exactly 5 digits.');
      return false;
    }

    String password = _signupPasswordController.text;
    if (!_isValidPassword(password)) {
      _showErrorDialog(
        'Password must be at least 8 characters, with numbers, letters, and special characters.',
      );
      return false;
    }

    if (_signupPasswordController.text !=
        _signupConfirmPasswordController.text) {
      _showErrorDialog('Passwords do not match.');
      return false;
    }

    return true;
  }

  bool _isValidPassword(String password) {
    return password.length >= 8 &&
        RegExp(
          r'^(?=.*[a-zA-Z])(?=.*\d)(?=.*[!@#\$%^&*(),.?":{}|<>])',
        ).hasMatch(password);
  }

  void _validateResetPassword() async {
    if (_resetIdController.text.length != 5 ||
        int.tryParse(_resetIdController.text) == null) {
      _showErrorDialog('ID must be exactly 5 digits.');
      return;
    }

    String password = _resetPasswordController.text;
    if (!_isValidPassword(password)) {
      _showErrorDialog(
        'Password must be at least 8 characters, with numbers, letters, and special characters.',
      );
      return;
    }

    if (_resetPasswordController.text != _resetConfirmPasswordController.text) {
      _showErrorDialog('Passwords do not match.');
      return;
    }

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'action': 'reset_password',
          'user_id': _resetIdController.text.trim(),
          'new_password': _resetPasswordController.text,
        },
      );

      var responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        Navigator.pop(context);
        _resetIdController.clear();
        _resetPasswordController.clear();
        _resetConfirmPasswordController.clear();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Password reset successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showErrorDialog(responseData['message']);
      }
    } catch (e) {
      _showErrorDialog("Error connecting to server.");
      print("Reset error: $e");
    }
  }

  void _signupUser(BuildContext modalContext, String userType) async {
    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        body: {
          'action': 'signup',
          'user_id': _signupIdController.text.trim(),
          'password': _signupPasswordController.text,
          'user_type': userType,
        },
      );

      var responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        Navigator.pop(modalContext);
        _clearSignupFields();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('User signed up successfully!'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        _showErrorDialog(responseData['message']);
      }
    } catch (e) {
      _showErrorDialog("Error connecting to server.");
      print("Signup error: $e");
    }
  }

  void _loginUser() async {
    final userId = _loginIdController.text.trim();
    final password = _loginPasswordController.text;

    if (userId.isEmpty || password.isEmpty) {
      _showErrorDialog("Please enter both ID and password.");
      return;
    }

    try {
      var response = await http.post(
        Uri.parse(apiUrl),
        body: {'action': 'login', 'user_id': userId, 'password': password},
      );

      var responseData = jsonDecode(response.body);
      print("Login response: $responseData");

      if (responseData['status'] == 'success') {
        _clearLoginFields();
        String userType = responseData['user_type'];
        if (userType == 'Coach') {
          Navigator.pushReplacementNamed(context, '/coachPage');
        } else if (userType == 'Statistician') {
          Navigator.pushReplacementNamed(context, '/statisticianPage');
        } else {
          _showErrorDialog("Unknown user type.");
        }
      } else {
        _showErrorDialog(responseData['message']);
      }
    } catch (e) {
      _showErrorDialog("Error connecting to server.");
      print("Login error: $e");
    }
  }

  void _showErrorDialog(String message) => _showMessageDialog('Error', message);

  void _showMessageDialog(String title, String message) {
    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(title),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  InputDecoration _buildInputDecoration(String label) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.blue),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Colors.blue),
    ),
  );

  InputDecoration _buildPasswordInput(
    String label,
    bool obscure,
    VoidCallback toggle,
  ) => InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(color: Colors.blue),
    suffixIcon: IconButton(
      icon: Icon(obscure ? Icons.visibility : Icons.visibility_off),
      onPressed: toggle,
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: const BorderSide(color: Colors.blue),
    ),
  );

  ButtonStyle _buttonStyle() => ElevatedButton.styleFrom(
    backgroundColor: Colors.blue,
    padding: const EdgeInsets.symmetric(horizontal: 100, vertical: 12),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
  );

  void _clearSignupFields() {
    _signupIdController.clear();
    _signupPasswordController.clear();
    _signupConfirmPasswordController.clear();
  }

  void _clearLoginFields() {
    _loginIdController.clear();
    _loginPasswordController.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daystar Falcons'),
        centerTitle: true,
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: _loginIdController,
                decoration: _buildInputDecoration("Enter ID"),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(5),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _loginPasswordController,
                obscureText: _obscureLoginPassword,
                decoration: _buildPasswordInput(
                  "Password",
                  _obscureLoginPassword,
                  () => setState(
                    () => _obscureLoginPassword = !_obscureLoginPassword,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loginUser,
                style: _buttonStyle(),
                child: const Text(
                  'Login',
                  style: TextStyle(color: Colors.white),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                "Don't have an account?",
                style: TextStyle(color: Colors.blue, fontSize: 16),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                hint: const Text(
                  "Signup as",
                  style: TextStyle(color: Colors.blue),
                ),
                items: const [
                  DropdownMenuItem<String>(
                    value: 'Coach',
                    child: Text("Coach"),
                  ),
                  DropdownMenuItem<String>(
                    value: 'Statistician',
                    child: Text("Statistician"),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) {
                    _showSignupDrawer(context, value);
                  }
                },
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: _showForgotPasswordDrawer,
                  child: const Text(
                    "Forgot Password?",
                    style: TextStyle(
                      color: Colors.redAccent,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
