import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:nutriguard/const/colors.dart';
import 'package:nutriguard/const/styles.dart';
import 'package:nutriguard/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  User? user;
  DatabaseReference? userRef;
  Map<String, dynamic>? userData;

  @override
  void initState() {
    super.initState();
    user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      userRef =
          FirebaseDatabase.instance.ref().child('user_data').child(user!.uid);
      _fetchUserData();
    }
  }

  Future<void> _fetchUserData() async {
    if (userRef != null) {
      final snapshot = await userRef!.get();
      if (snapshot.exists) {
        setState(() {
          userData = Map<String, dynamic>.from(snapshot.value as Map);
        });
      }
    }
  }

  void _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()),
      (route) => false,
    );
  }

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
              'Profile',
              style: mainText.copyWith(
                fontWeight: FontWeight.bold,
                color: colorLightBlue,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/gifs/logout.gif',
              height: 50.0,
              width: 50.0,
            ),
            onPressed: _logout,
          ),
        ],
      ),
      backgroundColor: colorWhite,
      body: userData == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: CircleAvatar(
                        radius: 50,
                        backgroundColor: colorBrightBlue,
                        child: Text(
                          '${userData!['first_name'][0]}${userData!['last_name'][0]}',
                          style: mainText.copyWith(color: colorWhite),
                        ),
                      ),
                    ),
                    const SizedBox(height: 24.0),
                    _buildProfileField(
                        'First Name', userData!['first_name'], false),
                    const SizedBox(height: 16.0),
                    _buildProfileField(
                        'Last Name', userData!['last_name'], false),
                    const SizedBox(height: 16.0),
                    _buildProfileField('Email', userData!['email'], false),
                    const SizedBox(height: 16.0),
                    _buildProfileField(
                        'Contact Number', userData!['contact_number'], false),
                    const SizedBox(height: 16.0),
                    _buildProfileField(
                        'Age', userData!['age'].toString(), true),
                    const SizedBox(height: 16.0),
                    _buildProfileField(
                        'Weight', '${userData!['weight']} kg', true),
                    const SizedBox(height: 16.0),
                    _buildProfileField(
                        'Height', '${userData!['height']} cm', true),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildProfileField(String fieldName, String value, bool isEditable) {
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          Text(
            '$fieldName: ',
            style: secondaryText.copyWith(
              fontSize: 18,
              color: colorBlack,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: secondaryText.copyWith(
                fontSize: 18,
                color: colorBrightBlue,
              ),
              softWrap: true,
            ),
          ),
          if (isEditable)
            IconButton(
              icon: Image.asset(
                'assets/gifs/edit.gif',
                height: 30.0,
                width: 30.0,
              ),
              onPressed: () => _showUpdateDialog(fieldName, value),
            ),
        ],
      ),
    );
  }

  void _showUpdateDialog(String fieldName, String currentValue) {
    TextEditingController controller =
        TextEditingController(text: currentValue);

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(
            'Update $fieldName',
            style: thirdText.copyWith(color: colorBrightBlue),
          ),
          content: TextField(
            controller: controller,
            decoration: inputFieldDecoration.copyWith(
              hintText: 'Enter new $fieldName',
            ),
            style: thirdText.copyWith(color: colorDarkBlue),
            keyboardType: fieldName == 'Age' ||
                    fieldName == 'Weight' ||
                    fieldName == 'Height'
                ? TextInputType.number
                : TextInputType.text,
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text('Cancel', style: warnText.copyWith(fontSize: 16.0)),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.of(context).pop();
                await _updateUserData(fieldName, controller.text);
              },
              style: primaryButtonStyle,
              child: Text('Update',
                  style: mainText.copyWith(fontSize: 16.0, color: colorWhite)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateUserData(String fieldName, String newValue) async {
    if (userRef != null) {
      try {
        await userRef!
            .update({fieldName.toLowerCase().replaceAll(' ', '_'): newValue});
        _fetchUserData(); // Refresh the data
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text(
            '$fieldName updated successfully!',
            style: mainText.copyWith(fontSize: 16.0, color: colorGreen),
          )),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to update $fieldName. Please try again.',
              style: warnText.copyWith(fontSize: 16.0),
            ),
          ),
        );
      }
    }
  }
}
