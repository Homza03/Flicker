import 'package:flutter/material.dart';

class RewardPopup {
  static void show(BuildContext context, String title, String subtitle) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(title: Text(title), content: Text(subtitle), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]),
    );
  }
}
