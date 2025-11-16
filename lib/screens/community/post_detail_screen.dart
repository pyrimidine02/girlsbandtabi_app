import 'package:flutter/material.dart';

class PostDetailScreen extends StatelessWidget {
  final String postId;
  
  const PostDetailScreen({super.key, required this.postId});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('게시글'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.article, size: 64, color: Colors.blue),
            const SizedBox(height: 16),
            Text(
              '게시글 ID: $postId',
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}