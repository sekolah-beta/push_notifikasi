import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

class SensorScreen extends StatefulWidget {
  const SensorScreen({super.key});

  @override
  State<SensorScreen> createState() => _SensorScreenState();
}

class _SensorScreenState extends State<SensorScreen> {
  MagnetometerEvent? magnetometer;

  @override
  void initState() {
    magnetometerEventStream(
      samplingPeriod: const Duration(
        seconds: 1,
      ),
    ).listen(
      (MagnetometerEvent event) {
        if (kDebugMode) print(event);
        if (mounted) {
          setState(() {
            magnetometer = event;
          });
        }
      },
      onError: (error) {
        // Logic to handle error
        // Needed for Android in case sensor is not available
      },
      cancelOnError: true,
    );
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Text(
        magnetometer != null
            ? '${magnetometer!.x.toString()}, ${magnetometer!.y.toString()}, ${magnetometer!.z.toString()}'
            : '',
        style: const TextStyle(fontSize: 18));
  }
}
