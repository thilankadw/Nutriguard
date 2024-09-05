import 'package:flutter/material.dart';
import 'package:nutriguard/screens/profile_screen.dart';
import 'package:nutriguard/screens/scan_screen.dart';
import 'package:nutriguard/const/styles.dart';
import 'package:nutriguard/const/colors.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: colorWhite,
        title: Row(
          children: [
            Image.asset(
              'assets/images/logoicon.png',
              height: 40,
            ),
          ],
        ),
      ),
      backgroundColor: colorWhite,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Image.asset(
                    'assets/gifs/user.gif',
                    width: 30.0,
                    height: 30.0,
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const ProfileScreen()),
                      );
                    },
                    style: textButtonStyle,
                    child: Text('Profile',
                        style: mainText.copyWith(
                            fontSize: 24.0, color: colorLightBlue)),
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              Center(
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'NUTRI GUARD',
                          style: mainText.copyWith(fontSize: 44.0),
                        ),
                        const SizedBox(height: 4.0),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              'Your Health Partner',
                              textAlign: TextAlign.right,
                              style: mainText.copyWith(
                                  fontWeight: FontWeight.w400),
                            ),
                            const SizedBox(width: 12.0)
                          ],
                        ),
                      ],
                    ),
                    const SizedBox(height: 60.0),
                    Image.asset(
                      'assets/gifs/healthy.gif',
                      width: 300.0,
                      height: 300.0,
                    ),
                    const SizedBox(height: 60.0),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => const ScanScreen()),
                        );
                      },
                      style: primaryButtonStyle,
                      child: Text('Scan Products',
                          style: mainText.copyWith(
                              fontSize: 20, color: colorWhite)),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
