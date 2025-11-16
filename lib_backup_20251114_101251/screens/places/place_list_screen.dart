import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Placeholder screen for now
class PlaceListScreen extends StatelessWidget {
  const PlaceListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('성지순례'),
        actions: [
          IconButton(
            onPressed: () => context.push('/main/map'),
            icon: const Icon(Icons.map),
            tooltip: '지도 보기',
          ),
        ],
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.place, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              '장소 목록',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              '성지와 라이브 장소들을 둘러보세요',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}