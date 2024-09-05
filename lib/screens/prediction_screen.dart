import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:nutriguard/const/styles.dart';
import 'package:nutriguard/const/colors.dart';
import 'package:nutriguard/screens/home_screen.dart';

class PredictionScreen extends StatefulWidget {
  final Map<String, String> nutritionData;

  const PredictionScreen({Key? key, required this.nutritionData})
      : super(key: key);

  @override
  _PredictionScreenState createState() => _PredictionScreenState();
}

class _PredictionScreenState extends State<PredictionScreen> {
  String _predictionMessage = 'Loading...';
  String _imagePath = '';
  String _considerationMessage = '';

  @override
  void initState() {
    super.initState();
    _checkDataAndPredict();
  }

  void _checkDataAndPredict() {
    if (widget.nutritionData.isNotEmpty) {
      _getPrediction();
    } else {
      setState(() {
        _predictionMessage = 'No nutritional data found. Try Again...';
        _imagePath = 'assets/gifs/empty.gif';
        _considerationMessage = '';
      });
    }
  }

  Future<void> _getPrediction() async {
    final url =
        'https://nutriguardapi-9d0f6b733628.herokuapp.com/predict-obesity';

    final calory = int.tryParse(widget.nutritionData['Calories'] ?? '0') ?? 0;
    final fat = int.tryParse(widget.nutritionData['Total Fat'] ?? '0') ?? 0;
    final sugar = int.tryParse(widget.nutritionData['Sodium'] ?? '0') ?? 0;

    final data = {
      'features': {
        'calory': calory,
        'fat': fat,
        'sugar': sugar,
      }
    };

    try {
      final response = await http.post(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);

        setState(() {
          if (result['prediction'] == 0) {
            _predictionMessage = 'This product is safe to consume!';
            _imagePath = 'assets/gifs/good.gif';
            _considerationMessage =
                'However, please consider the following nutritional values:';
          } else {
            _predictionMessage =
                'Warning: This product may contribute to obesity!';
            _imagePath = 'assets/gifs/bad.gif';
            _considerationMessage =
                'Please be mindful of the following nutritional values:';
          }
        });
      } else {
        setState(() {
          _predictionMessage = 'Error: Could not retrieve prediction';
        });
      }
    } catch (e) {
      setState(() {
        _predictionMessage = 'Error: $e';
      });
    }
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
              'Results',
              style: mainText.copyWith(
                fontWeight: FontWeight.bold,
                color: colorLightBlue,
              ),
            )
          ],
        ),
        actions: [
          IconButton(
            icon: Image.asset(
              'assets/gifs/home.gif',
              height: 50.0,
              width: 50.0,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),
        ],
      ),
      backgroundColor: colorWhite,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Center(
              child: Column(
                children: [
                  if (_imagePath.isNotEmpty)
                    Image.asset(
                      _imagePath,
                      width: 230.0,
                      height: 230.0,
                    ),
                  const SizedBox(height: 20.0),
                  Text(
                    _predictionMessage,
                    style: _predictionMessage.contains('Warning') ||
                            _predictionMessage.contains('Error')
                        ? warnText.copyWith(fontSize: 25.0)
                        : _predictionMessage
                                .contains('No nutritional data found')
                            ? mainText.copyWith(
                                fontSize: 25.0, color: colorBrightBlue)
                            : mainText.copyWith(
                                fontSize: 25.0, color: colorGreen),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30.0),
                  if (_considerationMessage.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(30, 0, 0, 10),
                      child: Text(
                        _considerationMessage,
                        style: mainText.copyWith(
                            fontSize: 16.0, color: colorBlack),
                        textAlign: TextAlign.start,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 30.0),
            _buildNutritionDetails(),
          ],
        ),
      ),
    );
  }

  // Widget to build nutrition details
  Widget _buildNutritionDetails() {
    return widget.nutritionData.isNotEmpty
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.nutritionData.entries.map((entry) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(30, 0, 0, 10),
                child: Text(
                  '${entry.key}: ${entry.value}',
                  style: mainText.copyWith(
                    fontSize: 20.0,
                    color: colorBlack,
                  ),
                  textAlign: TextAlign.start,
                ),
              );
            }).toList(),
          )
        : SizedBox.shrink(); // If no data, return an empty widget
  }
}
