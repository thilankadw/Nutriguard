import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:nutriguard/const/colors.dart';
import 'package:nutriguard/const/styles.dart';
import 'package:nutriguard/screens/createprofile_screen.dart';
import 'package:nutriguard/screens/login_screen.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

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
              'Register',
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
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: [
                const SizedBox(height: 16.0),
                _buildTextField(_emailController, 'Email',
                    'Please enter a valid email', TextInputType.emailAddress),
                const SizedBox(height: 32.0),
                _buildPasswordField(_passwordController, 'Password',
                    'Please enter your password'),
                const SizedBox(height: 32.0),
                _buildPasswordField(_confirmPasswordController,
                    'Confirm Password', 'Please confirm your password'),
                const SizedBox(height: 40.0),
                ElevatedButton(
                  onPressed: _registerUser,
                  style: primaryButtonStyle,
                  child: Text('Register',
                      style:
                          mainText.copyWith(fontSize: 20, color: colorWhite)),
                ),
                const SizedBox(height: 20.0),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Already have an account? Login',
                    style: thirdText,
                  ),
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
        if (labelText == 'Email' &&
            !RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
          return 'Please enter a valid email';
        }
        return null;
      },
    );
  }

  Widget _buildPasswordField(TextEditingController controller, String labelText,
      String validationMessage) {
    return TextFormField(
      controller: controller,
      decoration: inputFieldDecoration.copyWith(labelText: labelText),
      obscureText: true,
      style: thirdText.copyWith(color: colorDarkBlue),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return validationMessage;
        }
        if (value.length < 6) {
          return 'Password must be at least 6 characters long';
        }
        if (labelText == 'Confirm Password' &&
            value != _passwordController.text) {
          return 'Passwords do not match';
        }
        return null;
      },
    );
  }

  Future<void> _registerUser() async {
    if (_formKey.currentState?.validate() ?? false) {
      try {
        UserCredential userCredential =
            await FirebaseAuth.instance.createUserWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => CreateProfileScreen(
              user: userCredential.user!,
              email: _emailController.text.trim(),
            ),
          ),
        );
      } on FirebaseAuthException catch (e) {
        String errorMessage;
        if (e.code == 'email-already-in-use') {
          errorMessage = 'The email address is already in use.';
        } else if (e.code == 'weak-password') {
          errorMessage = 'The password provided is too weak.';
        } else {
          errorMessage = 'An error occurred. Please try again.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content:
                  Text(errorMessage, style: warnText.copyWith(fontSize: 16.0))),
        );
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }
}
