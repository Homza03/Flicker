import 'package:flutter/material.dart';

class ShopScreen extends StatelessWidget {
  const ShopScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hub Market')),
      body: const Center(child: Text('Shop: themes, avatars, boosters (stub)')),
    );
  }
}
