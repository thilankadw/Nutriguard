import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:nutriguard/const/colors.dart';
import 'package:nutriguard/const/styles.dart';
import 'package:nutriguard/screens/home_screen.dart';

class CreateProfileScreen extends StatefulWidget {
  final User user;
  final String email;

  CreateProfileScreen({
    required this.user,
    required this.email,
  });

  @override
  _CreateProfileScreenState createState() => _CreateProfileScreenState();
}

class _CreateProfileScreenState extends State<CreateProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _contactController = TextEditingController();
  final _ageController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorWhite,
        centerTitle: true,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logoicon.png',
              height: 40,
            ),
            const SizedBox(width: 30.0),
            Text(
              'Create Profile',
              style: mainText.copyWith(
                fontWeight: FontWeight.bold,
                color: colorLightBlue,
              ),
            )
          ],
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 16.0),
                _buildTextField(_firstNameController, 'First Name',
                    'Please enter your first name'),
                const SizedBox(height: 32.0),
                _buildTextField(_lastNameController, 'Last Name',
                    'Please enter your last name'),
                const SizedBox(height: 32.0),
                _buildTextField(_contactController, 'Contact Number',
                    'Please enter a valid contact number', TextInputType.phone),
                const SizedBox(height: 32.0),
                _buildTextField(_ageController, 'Age',
                    'Please enter a valid age', TextInputType.number),
                const SizedBox(height: 32.0),
                _buildTextField(_weightController, 'Weight (kg)',
                    'Please enter a valid weight', TextInputType.number),
                const SizedBox(height: 32.0),
                _buildTextField(_heightController, 'Height (cm)',
                    'Please enter a valid height', TextInputType.number),
                const SizedBox(height: 40.0),
                ElevatedButton(
                  onPressed: _createUserProfile,
                  style: primaryButtonStyle,
                  child: Text('Create Profile',
                      style:
                          mainText.copyWith(fontSize: 20, color: colorWhite)),
                ),
                const SizedBox(height: 40.0),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String labelText,
      String validationMessage,
      [TextInputType keyboardType = TextInputType.text]) {
    return TextFormField(
      controller: controller,
      decoration: inputFieldDecoration.copyWith(labelText: labelText),
      keyboardType: keyboardType,
      style: thirdText.copyWith(color: colorDarkBlue),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        if (keyboardType == TextInputType.number &&
            !RegExp(r'^\d+$').hasMatch(value)) {
          return 'Please enter a valid number';
        }
        return null;
      },
    );
  }

  Future<void> _createUserProfile() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        DatabaseReference usersRef =
            FirebaseDatabase.instance.ref().child('user_data');
        await usersRef.child(widget.user.uid).set({
          'email': widget.email,
          'first_name': _firstNameController.text.trim(),
          'last_name': _lastNameController.text.trim(),
          'contact_number': _contactController.text.trim(),
          'age': int.parse(_ageController.text.trim()),
          'weight': double.parse(_weightController.text.trim()),
          'height': double.parse(_heightController.text.trim()),
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Profile created successfully!',
                  style: mainText.copyWith(fontSize: 16.0))),
        );

        // Navigate to a different screen after profile creation, e.g., HomeScreen
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(),
          ),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Failed to create profile. Please try again.',
                  style: warnText.copyWith(fontSize: 16.0))),
        );
      }
    }
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _contactController.dispose();
    _ageController.dispose();
    _weightController.dispose();
    _heightController.dispose();
    super.dispose();
  }
}
