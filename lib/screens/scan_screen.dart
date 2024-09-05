import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:camera/camera.dart';
import 'package:path_provider/path_provider.dart';
import 'package:nutriguard/screens/prediction_screen.dart';
import 'package:nutriguard/const/styles.dart';
import 'package:nutriguard/const/colors.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  _ScanScreenState createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  late CameraController _cameraController;
  late Future<void> _initializeControllerFuture;
  bool _isProcessing = false;
  String _text = 'No data';

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    _cameraController = CameraController(
      cameras.first,
      ResolutionPreset.high,
    );
    _initializeControllerFuture = _cameraController.initialize();
    setState(() {});
  }

  Future<void> _takePicture() async {
    if (_cameraController.value.isTakingPicture || _isProcessing) return;

    setState(() {
      _isProcessing = true;
    });

    try {
      await _initializeControllerFuture;
      final XFile picture = await _cameraController.takePicture();
      final imagePath = picture.path;

      final recognizedText = await _extractTextFromImage(imagePath);

      final nutritionData = _extractNutritionalData(recognizedText);

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                PredictionScreen(nutritionData: nutritionData),
          ),
        );
      }
    } finally {
      setState(() {
        _isProcessing = false;
      });
    }
  }

  Future<String> _extractTextFromImage(String path) async {
    final inputImage = InputImage.fromFilePath(path);
    final textRecognizer = GoogleMlKit.vision.textRecognizer();
    final RecognizedText recognizedText =
        await textRecognizer.processImage(inputImage);

    String text = '';
    for (TextBlock block in recognizedText.blocks) {
      for (TextLine line in block.lines) {
        text += '${line.text}\n';
      }
    }

    textRecognizer.close();

    return text;
  }

  Map<String, String> _extractNutritionalData(String recognizedText) {
    final Map<String, String> nutritionData = {};

    final caloriesRegex = RegExp(r'Calories\s+(\d+)');
    final fatRegex = RegExp(r'Fat\s+(\d+g)');
    final sodiumRegex = RegExp(r'Sodium\s+(\d+mg)');

    final caloriesMatch = caloriesRegex.firstMatch(recognizedText);
    final fatMatch = fatRegex.firstMatch(recognizedText);
    final sodiumMatch = sodiumRegex.firstMatch(recognizedText);

    if (caloriesMatch != null) {
      nutritionData['Calories'] = caloriesMatch.group(1)!;
    }
    if (fatMatch != null) {
      nutritionData['Total Fat'] = fatMatch.group(1)!;
    }
    if (sodiumMatch != null) {
      nutritionData['Sodium'] = sodiumMatch.group(1)!;
    }

    return nutritionData;
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
              'Scan',
              style: mainText.copyWith(
                fontWeight: FontWeight.bold,
                color: colorLightBlue,
              ),
            )
          ],
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FutureBuilder<void>(
                  future: _initializeControllerFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.done) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.all(Radius.circular(10.0)),
                          child: Container(
                            width: double.infinity,
                            height: 550,
                            child: CameraPreview(_cameraController),
                          ),
                        ),
                      );
                    } else {
                      return const Center(child: CircularProgressIndicator());
                    }
                  },
                ),
                const SizedBox(height: 40),
                OutlinedButton(
                  onPressed: _takePicture,
                  style: OutlinedButton.styleFrom(
                    shape: CircleBorder(),
                    side: BorderSide.none,
                    padding: EdgeInsets.zero,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: colorLightBlue, // Your border color
                        width: 8.0, // Your border width
                      ),
                    ),
                    child: ClipOval(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Image.asset(
                          'assets/gifs/scan2.gif',
                          width: 70.0, // The size of the image
                          height: 70.0, // The size of the image
                          fit: BoxFit
                              .cover, // Ensures the image covers the space provided
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }
}
