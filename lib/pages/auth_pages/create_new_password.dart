import 'package:app1/data/user.dart';
import 'package:app1/services/auth_services.dart';
import 'package:flutter/material.dart';

class CreatePassword extends StatefulWidget {
  const CreatePassword({super.key});

  @override
  State<CreatePassword> createState() => _CreatePasswordState();
}

class _CreatePasswordState extends State<CreatePassword> {
  @override
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController =
      TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  String _passwordStrength = '';
  Color _strengthColor = Colors.grey;
  String _errorMessage = '';

  @override
  void dispose() {
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPasswordStrength(String password) {
    if (password.isEmpty) {
      setState(() {
        _passwordStrength = '';
        _strengthColor = Colors.grey;
      });
      return;
    }

    bool hasUppercase = password.contains(RegExp(r'[A-Z]'));
    bool hasLowercase = password.contains(RegExp(r'[a-z]'));
    bool hasDigit = password.contains(RegExp(r'[0-9]'));
    bool hasSpecialChar = password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

    int strength = 0;
    if (password.length >= 8) strength++;
    if (password.length >= 12) strength++;
    if (hasUppercase) strength++;
    if (hasLowercase) strength++;
    if (hasDigit) strength++;
    if (hasSpecialChar) strength++;

    setState(() {
      if (strength <= 2) {
        _passwordStrength = 'Weak';
        _strengthColor = Colors.red;
      } else if (strength <= 4) {
        _passwordStrength = 'Medium';
        _strengthColor = Colors.orange;
      } else {
        _passwordStrength = 'Strong';
        _strengthColor = Colors.green;
      }
    });
  }

  bool _validatePasswords() {
    if (_passwordController.text.isEmpty) {
      setState(() {
        _errorMessage = 'Please enter a password';
      });
      return false;
    }

    if (_passwordController.text.length < 8) {
      setState(() {
        _errorMessage = 'Password must be at least 8 characters';
      });
      return false;
    }

    if (_passwordController.text != _confirmPasswordController.text) {
      setState(() {
        _errorMessage = 'Passwords do not match';
      });
      return false;
    }

    setState(() {
      _errorMessage = '';
    });
    return true;
  }

  void _submitPassword() async {
    if (_validatePasswords()) {
      AuthService authService = AuthService();
      UserL userL = UserL();
      // Here you would t
      await authService.updateUserPassword(_passwordController.text);
      await userL.updateFirstLoginState(false);
      //ypically call an API or service to save the password
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password created successfully!')),
      );
      await authService.signout(context: context);
      // In a real app, you might navigate to the next screen
      // Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => NextScreen()));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create New Password'),
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              const Text(
                'Create a new password',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              const Text(
                'Your password should be at least 8 characters and include uppercase letters, lowercase letters, numbers, and special characters.',
                style: TextStyle(color: Colors.grey),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              TextField(
                controller: _passwordController,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'New Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(_obscurePassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                ),
                onChanged: (value) {
                  _checkPasswordStrength(value);
                },
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Password strength: '),
                  Text(
                    _passwordStrength,
                    style: TextStyle(
                      color: _strengthColor,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _confirmPasswordController,
                obscureText: _obscureConfirmPassword,
                decoration: InputDecoration(
                  labelText: 'Confirm Password',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_obscureConfirmPassword
                        ? Icons.visibility
                        : Icons.visibility_off),
                    onPressed: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                ),
              ),
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    _errorMessage,
                    style: const TextStyle(color: Colors.red),
                  ),
                ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitPassword,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Create Password',
                    style: TextStyle(fontSize: 16)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
