import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:intl/intl.dart';
import 'dart:math';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Wrist Wise Simulator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: const SimulatorScreen(),
    );
  }
}

class SimulatorScreen extends StatefulWidget {
  const SimulatorScreen({super.key});

  @override
  _SimulatorScreenState createState() => _SimulatorScreenState();
}

class _SimulatorScreenState extends State<SimulatorScreen> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final Random _random = Random();
  String deviceName = "WristWise001";
  double batteryPercentage = 100;
  String wifiSSID = "Home WiFi";
  bool isPoweredOn = true;
  String version = "1.0.0";
  bool isWiFiConnected = true;
  // Alert levels

  // Create controllers
  final TextEditingController deviceNameController = TextEditingController();
  final TextEditingController wifiSSIDController = TextEditingController();
  final TextEditingController versionController = TextEditingController();

  final Map<String, Color> alertColors = {
    'Normal': Colors.green,
    'Yellow Alert': Colors.yellow,
    'Orange Alert': Colors.orange,
    'Red Alert': Colors.red,
  };

  // Current sensor status
  String heartRateStatus = 'Normal';
  String spo2Status = 'Normal';
  String temperatureStatus = 'Normal';
  bool fallDetected = false;

  // Define thresholds for each vital sign
  final Map<String, Map<String, List<double>>> thresholds = {
    'heartRate': {
      'Normal': [60, 100],
      'Yellow Alert': [50, 110],
      'Orange Alert': [40, 130],
      'Red Alert': [0, 220],
    },
    'spo2': {
      'Normal': [95, 100],
      'Yellow Alert': [90, 94],
      'Red Alert': [0, 89],
    },
    'temperature': {
      'Normal': [36.1, 37.2],
      'Yellow Alert': [35.0, 38.0],
      'Orange Alert': [34.0, 39.0],
      'Red Alert': [0.0, 42.0],
    },
  };

  // Generate raw values based on alert level
  int generateHeartRate(String status) {
    if (status == 'Normal') {
      return 60 + _random.nextInt(41); // 60-100 BPM
    } else if (status == 'Yellow Alert') {
      return _random.nextBool()
          ? 50 + _random.nextInt(10) // 50-59 BPM (low)
          : 101 + _random.nextInt(10); // 101-110 BPM (high)
    } else if (status == 'Orange Alert') {
      return _random.nextBool()
          ? 40 + _random.nextInt(10) // 40-49 BPM (low)
          : 111 + _random.nextInt(20); // 111-130 BPM (high)
    } else {
      // Red Alert
      return _random.nextBool()
          ? 20 + _random.nextInt(20) // 20-39 BPM (very low)
          : 131 + _random.nextInt(70); // 131-200 BPM (very high)
    }
  }

  int generateSpo2(String status) {
    if (status == 'Normal') {
      return 95 + _random.nextInt(6); // 95-100%
    } else if (status == 'Yellow Alert') {
      return 90 + _random.nextInt(5); // 90-94%
    } else {
      // Red Alert
      return 70 + _random.nextInt(20); // 70-89%
    }
  }

  double generateTemperature(String status) {
    if (status == 'Normal') {
      return 36.1 + _random.nextDouble() * 1.1; // 36.1-37.2°C
    } else if (status == 'Yellow Alert') {
      return _random.nextBool()
          ? 35.0 + _random.nextDouble() * 1.0 // 35.0-36.0°C (low)
          : 37.3 + _random.nextDouble() * 0.7; // 37.3-38.0°C (high)
    } else if (status == 'Orange Alert') {
      return _random.nextBool()
          ? 34.0 + _random.nextDouble() * 0.9 // 34.0-34.9°C (low)
          : 38.1 + _random.nextDouble() * 0.9; // 38.1-39.0°C (high)
    } else {
      // Red Alert
      return _random.nextBool()
          ? 30.0 + _random.nextDouble() * 4.0 // 30.0-33.9°C (very low)
          : 39.1 + _random.nextDouble() * 2.9; // 39.1-42.0°C (very high)
    }
  }

  // Get alert status based on raw value
  String getHeartRateStatus(int bpm) {
    if (bpm >= 60 && bpm <= 100) return 'Normal';
    if ((bpm >= 50 && bpm < 60) || (bpm > 100 && bpm <= 110))
      return 'Yellow Alert';
    if ((bpm >= 40 && bpm < 50) || (bpm > 110 && bpm <= 130))
      return 'Orange Alert';
    return 'Red Alert';
  }

  String getSpo2Status(int spo2) {
    if (spo2 >= 95) return 'Normal';
    if (spo2 >= 90) return 'Yellow Alert';
    return 'Red Alert';
  }

  String getTemperatureStatus(double temp) {
    if (temp >= 36.1 && temp <= 37.2) return 'Normal';
    if ((temp >= 35.0 && temp < 36.1) || (temp > 37.2 && temp <= 38.0))
      return 'Yellow Alert';
    if ((temp >= 34.0 && temp < 35.0) || (temp > 38.0 && temp <= 39.0))
      return 'Orange Alert';
    return 'Red Alert';
  }

  // Get severity level (1=Yellow, 2=Orange, 3=Red)
  int getSeverityLevel(String status) {
    switch (status) {
      case 'Yellow Alert':
        return 1;
      case 'Orange Alert':
        return 2;
      case 'Red Alert':
        return 3;
      default:
        return 0;
    }
  }

  Map<String, dynamic> getActiveAlerts() {
    Map<String, dynamic> alerts = {};

    // Add timestamp
    alerts['timestamp'] = DateFormat(
      'yyyy-MM-dd HH:mm:ss',
    ).format(DateTime.now());

    // Generate raw values based on selected alert levels
    int heartRate = generateHeartRate(heartRateStatus);
    int spo2 = generateSpo2(spo2Status);
    double temperature = generateTemperature(temperatureStatus);

    // Add all raw data directly (ungrouped)
    alerts['heartRate'] = heartRate;
    alerts['spo2'] = spo2;
    alerts['temperature'] = temperature.toStringAsFixed(1);
    alerts['fall'] = fallDetected;

    return alerts;
  }

  // Send data to Firebase
  Future<void> sendAlerts() async {
    Map<String, dynamic> metrics = getActiveAlerts();

    Map<String, dynamic> data = {
      'batteryPercentage': batteryPercentage,
      'WiFiSSID': wifiSSID,
      'isPoweredOn': isPoweredOn,
      'version': version,
      'isWiFiConnected': isWiFiConnected,
      'Metrics': metrics,
    };

    try {
      await _database.child('devices').child(deviceName).set(data);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Data sent successfully')));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to send data: $e')));
    }
  }

  @override
  void initState() {
    super.initState();
    deviceNameController.text = deviceName;
    wifiSSIDController.text = wifiSSID;
    versionController.text = version;
  }

  @override
  void dispose() {
    deviceNameController.dispose();
    wifiSSIDController.dispose();
    versionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Wrist Wise Simulator')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Simulate Health Data',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              // Use Expanded with SingleChildScrollView to allow scrolling
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Device Info',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),

                              TextField(
                                decoration: const InputDecoration(
                                  labelText: 'Device Name',
                                ),
                                controller: deviceNameController,
                                onChanged: (value) {
                                  setState(() {
                                    deviceName = value;
                                  });
                                },
                              ),

                              const SizedBox(height: 8),
                              Text('Battery Percentage: ${batteryPercentage.round()}%'),
                              Slider(
                                value: batteryPercentage,
                                min: 0,
                                max: 100,
                                divisions: 100,
                                label: batteryPercentage.round().toString(),
                                onChanged: (value) {
                                  setState(() {
                                    batteryPercentage = value;
                                  });
                                },
                              ),

                              const SizedBox(height: 8),
                              TextField(
                                decoration: const InputDecoration(labelText: 'WiFi SSID'),
                                controller: wifiSSIDController,
                                onChanged: (value) {
                                  setState(() {
                                    wifiSSID = value;
                                  });
                                },
                              ),

                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Is Powered On?'),
                                  Switch(
                                    value: isPoweredOn,
                                    onChanged: (value) {
                                      setState(() {
                                        isPoweredOn = value;
                                      });
                                    },
                                  ),
                                ],
                              ),

                              const SizedBox(height: 8),
                              TextField(
                                decoration: const InputDecoration(labelText: 'Version'),
                                controller: versionController,
                                onChanged: (value) {
                                  setState(() {
                                    version = value;
                                  });
                                },
                              ),

                              const SizedBox(height: 8),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  const Text('Is WiFi Connected?'),
                                  Switch(
                                    value: isWiFiConnected,
                                    onChanged: (value) {
                                      setState(() {
                                        isWiFiConnected = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Heart Rate
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Heart Rate',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButton<String>(
                                isExpanded: true,
                                value: heartRateStatus,
                                items: alertColors.keys.map((String value) {
                                  String rangeText = '';
                                  if (value == 'Normal') {
                                    rangeText = '(60-100 bpm)';
                                  } else if (value == 'Yellow Alert') {
                                    rangeText = '(50-59 or 101-110 bpm)';
                                  } else if (value == 'Orange Alert') {
                                    rangeText = '(40-49 or 111-130 bpm)';
                                  } else if (value == 'Red Alert') {
                                    rangeText = '(<40 or >130 bpm)';
                                  }

                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: alertColors[value],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text('$value $rangeText')),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    heartRateStatus = newValue!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // SPO2
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'SPO2',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButton<String>(
                                isExpanded: true,
                                value: spo2Status,
                                items: ['Normal', 'Yellow Alert', 'Red Alert'].map((
                                  String value,
                                ) {
                                  String rangeText = '';
                                  if (value == 'Normal') {
                                    rangeText = '(95-100%)';
                                  } else if (value == 'Yellow Alert') {
                                    rangeText = '(90-94%)';
                                  } else if (value == 'Red Alert') {
                                    rangeText = '(<90%)';
                                  }

                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: alertColors[value],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text('$value $rangeText')),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    spo2Status = newValue!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Temperature
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Temperature',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              DropdownButton<String>(
                                isExpanded: true,
                                value: temperatureStatus,
                                items: alertColors.keys.map((String value) {
                                  String rangeText = '';
                                  if (value == 'Normal') {
                                    rangeText = '(36.1-37.2°C)';
                                  } else if (value == 'Yellow Alert') {
                                    rangeText = '(35.0-36.0 or 37.3-38.0°C)';
                                  } else if (value == 'Orange Alert') {
                                    rangeText = '(34.0-34.9 or 38.1-39.0°C)';
                                  } else if (value == 'Red Alert') {
                                    rangeText = '(<34.0 or >39.0°C)';
                                  }

                                  return DropdownMenuItem<String>(
                                    value: value,
                                    child: Row(
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          decoration: BoxDecoration(
                                            color: alertColors[value],
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(child: Text('$value $rangeText')),
                                      ],
                                    ),
                                  );
                                }).toList(),
                                onChanged: (String? newValue) {
                                  setState(() {
                                    temperatureStatus = newValue!;
                                  });
                                },
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 8),

                      // Fall Detection
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Fall Detection',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Row(
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    decoration: BoxDecoration(
                                      color: fallDetected ? Colors.red : Colors.green,
                                      shape: BoxShape.circle,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(fallDetected ? 'Yes' : 'No'),
                                  const SizedBox(width: 8),
                                  Switch(
                                    value: fallDetected,
                                    activeColor: Colors.red,
                                    onChanged: (bool value) {
                                      setState(() {
                                        fallDetected = value;
                                      });
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 16),

                      // Preview Card
                      Card(
                        color: Colors.grey[200],
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Data Preview',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Heart Rate: ${generateHeartRate(heartRateStatus)} bpm (${heartRateStatus})',
                              ),
                              Text('SPO2: ${generateSpo2(spo2Status)}% (${spo2Status})'),
                              Text(
                                'Temperature: ${generateTemperature(temperatureStatus).toStringAsFixed(1)}°C (${temperatureStatus})',
                              ),
                              Text('Fall Detected: ${fallDetected ? "Yes" : "No"}'),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
              
              // Send Data Button - Keep outside the ScrollView
              ElevatedButton(
                onPressed: sendAlerts,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: const Text(
                  'Send Data',
                  style: TextStyle(fontSize: 18, color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}