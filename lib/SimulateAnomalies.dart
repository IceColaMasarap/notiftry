import 'package:flutter/material.dart';

class SimulateAnomaliesPage extends StatefulWidget {
  @override
  _SimulateAnomaliesPageState createState() => _SimulateAnomaliesPageState();
}

class _SimulateAnomaliesPageState extends State<SimulateAnomaliesPage> {
  // Dropdown values
  String heartRateAlert = 'Normal';
  String spo2Alert = 'Normal';
  String temperatureAlert = 'Normal';
  bool fallDetected = false;

  void sendNotification() {
    final alerts = {
      'heart_rate': heartRateAlert,
      'spo2': spo2Alert,
      'temperature': temperatureAlert,
      'fall': fallDetected ? 'Fall Detected (RED Alert)' : 'No Fall',
      'timestamp': DateTime.now().toIso8601String(),
    };

    print(alerts);

    // TODO: After firebase integration:
    // final databaseReference = FirebaseDatabase.instance.ref('alerts');
    // databaseReference.push().set(alerts);
  }

  Widget buildDropdown(String title, String value, List<String> options, Function(String?) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        DropdownButton<String>(
          value: value,
          items: options.map((opt) {
            return DropdownMenuItem<String>(
              value: opt,
              child: Text(opt),
            );
          }).toList(),
          onChanged: onChanged,
        ),
        SizedBox(height: 20),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Simulate Anomalies')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            buildDropdown('Heart Rate', heartRateAlert, ['Normal', 'Yellow Alert', 'Orange Alert', 'Red Alert'], (val) {
              setState(() => heartRateAlert = val!);
            }),
            buildDropdown('SPO2', spo2Alert, ['Normal', 'Yellow Alert', 'Red Alert'], (val) {
              setState(() => spo2Alert = val!);
            }),
            buildDropdown('Temperature', temperatureAlert, ['Normal', 'Yellow Alert', 'Orange Alert', 'Red Alert'], (val) {
              setState(() => temperatureAlert = val!);
            }),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Fall Detected?', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                Switch(
                  value: fallDetected,
                  onChanged: (val) {
                    setState(() => fallDetected = val);
                  },
                ),
              ],
            ),
            SizedBox(height: 40),
            ElevatedButton(
              onPressed: sendNotification,
              style: ElevatedButton.styleFrom(
                padding: EdgeInsets.symmetric(vertical: 16),
                textStyle: TextStyle(fontSize: 20),
              ),
              child: Text('Send Notification'),
            ),
          ],
        ),
      ),
    );
  }
}
