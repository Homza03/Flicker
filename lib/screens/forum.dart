import 'package:flutter/material.dart';

class ForumScreen extends StatelessWidget {
  const ForumScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Fórum')),
      body: const Center(child: Text('Forum and global chat using Realtime DB (stub)')),
    );
  }
}
