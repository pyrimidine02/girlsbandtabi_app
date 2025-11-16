import 'package:flutter/material.dart';

class PlaceMapScreen extends StatelessWidget {
  const PlaceMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('지도'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.map, size: 64, color: Colors.green),
            SizedBox(height: 16),
            Text(
              '지도 화면',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Google Maps 통합 예정',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}