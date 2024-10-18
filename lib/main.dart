import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

Future<void> main() async {
  runApp(const MyApp());
}

Future<Map<String, dynamic>> getPredictedGender(String name) async {
  try {
    var response =
        await http.get(Uri.https("api.genderize.io", "", {"name": name}));
    if (response.statusCode == 200) {
      var jsonData = jsonDecode(response.body);
      return jsonData;
    } else {
      throw Exception('Failed to load data: ${response.statusCode}');
    }
  } catch (error) {
    throw Exception('Error: $error');
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: HomePage(),
    );
  }
}

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  String? predictedGender;
  bool isLoading = false;
  String errorMessage = '';
  final TextEditingController _nameController = TextEditingController();

  Future<void> _fetchPredictedGender(String name) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      var result = await getPredictedGender(name);
      setState(() {
        predictedGender =
            result['gender'] != null ? result['gender'] : 'Гендер не найден';
        isLoading = false;
      });
    } catch (error) {
      setState(() {
        errorMessage = error.toString();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Предсказание гендера по имени'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: 'Введите имя',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                if (_nameController.text.isNotEmpty) {
                  _fetchPredictedGender(_nameController.text);
                }
              },
              child: const Text('Узнать гендер'),
            ),
            const SizedBox(height: 20),
            if (isLoading) const CircularProgressIndicator(),
            if (errorMessage.isNotEmpty) Text('Ошибка: $errorMessage'),
            if (predictedGender != null) ...[
              const Text('Предполагаемый гендер:'),
              const SizedBox(height: 10),
              Text(
                predictedGender!,
                style:
                    const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
