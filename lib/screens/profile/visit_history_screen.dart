import 'package:flutter/material.dart';

class VisitHistoryScreen extends StatelessWidget {
  const VisitHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('방문 기록'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.history, size: 64, color: Colors.orange),
            SizedBox(height: 16),
            Text(
              '방문 기록',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '내가 방문한 장소들의 기록입니다',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}