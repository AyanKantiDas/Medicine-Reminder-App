import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class MedicineInfo extends StatelessWidget {
  const MedicineInfo({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Medicine Bot',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MedicineScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class MedicineScreen extends StatefulWidget {
  @override
  _MedicineScreenState createState() => _MedicineScreenState();
}

class _MedicineScreenState extends State<MedicineScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicineController = TextEditingController();
  Map<String, dynamic>? _medicineInfo;
  bool _isLoading = false;

  Future<void> _getMedicineInfo(String medicineName) async {
    setState(() {
      _isLoading = true;
    });

    final response = await http.post(
      Uri.parse('http://10.5.121.32:5000/get_medicine_info'),
      headers: <String, String>{
        'Content-Type': 'application/x-www-form-urlencoded',
      },
      body: {'medicine_name': medicineName},
    );

    if (response.statusCode == 200) {
      setState(() {
        _medicineInfo = json.decode(response.body);
      });
    } else {
      setState(() {
        _medicineInfo = {'error': 'Failed to fetch medicine information'};
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _medicineController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Welcome to Medi Bot'),
      ),
      body: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: <Widget>[
                Text(
                  'Learn about the medicines by seeing the details.',
                  style: TextStyle(fontSize: 16.0),
                ),
                SizedBox(height: 20.0),
                Form(
                  key: _formKey,
                  child: Column(
                    children: <Widget>[
                      TextFormField(
                        controller: _medicineController,
                        decoration: InputDecoration(
                          labelText: 'Medicine Name',
                          border: OutlineInputBorder(),
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter a medicine name';
                          }
                          return null;
                        },
                      ),
                      SizedBox(height: 20.0),
                      ElevatedButton(
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            FocusScope.of(context)
                                .unfocus(); // Dismiss the keyboard
                            _getMedicineInfo(_medicineController.text);
                          }
                        },
                        child: Text('Get Information'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 20.0),
                _isLoading
                    ? CircularProgressIndicator()
                    : _medicineInfo == null
                        ? Container()
                        : _medicineInfo!.containsKey('error')
                            ? Text(
                                _medicineInfo!['error'],
                                style: TextStyle(color: Colors.red),
                              )
                            : Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: <Widget>[
                                  Text(
                                    _medicineInfo!['Medicine Name'],
                                    style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  Text(
                                      'Composition: ${_medicineInfo!['Composition']}'),
                                  Text('Uses: ${_medicineInfo!['Uses']}'),
                                  Text(
                                      'Side Effects: ${_medicineInfo!['Side Effects']}'),
                                  Text(
                                      'Manufacturer: ${_medicineInfo!['Manufacturer']}'),
                                ],
                              ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
