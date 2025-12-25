import 'package:flutter/material.dart';

class GameCard extends StatelessWidget {
  final String title;
  final String description;
  final String route;
  const GameCard({super.key, required this.title, required this.description, required this.route});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: ListTile(
        title: Text(title),
        subtitle: Text(description),
        trailing: ElevatedButton(onPressed: () => Navigator.pushNamed(context, route), child: const Text('Play')),
      ),
    );
  }
}
