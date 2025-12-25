import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/rewards_engine.dart';

// Pinball: simplified score-chasing mini-game with flippers simulated by taps.
class PinballGameScreen extends StatefulWidget {
  const PinballGameScreen({super.key});

  @override
  State<PinballGameScreen> createState() => _PinballGameScreenState();
}

class _PinballGameScreenState extends State<PinballGameScreen> {
  int score = 0;
  Timer? timer;
  final rnd = Random();

  void start() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 400), (_) {
      setState(() { score += rnd.nextInt(50); });
    });
  }

  Future<void> end() async {
    timer?.cancel();
    final rewards = Provider.of<RewardsEngine>(context, listen: false);
    final firestore = Provider.of<FirestoreService>(context, listen: false);
    final xp = (score / 10).round();
    final coins = (score / 20).round();
    rewards.addXp(xp);
    rewards.addCoins(coins);
    await firestore.saveScore('anon_user', 'pinball_game', score);
    if (!mounted) return;
    showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Pinball Ended'), content: Text('Score: $score\nXP +$xp, Coins +$coins'), actions: [TextButton(onPressed: () { Navigator.pop(context); setState(() => score = 0); start(); }, child: const Text('Retry'))]));
  }

  @override
  void initState() {
    super.initState();
    start();
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Pinball Madness')), body: Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [Text('Score: $score', style: const TextStyle(fontSize: 24)), const SizedBox(height: 20), ElevatedButton(onPressed: () => end(), child: const Text('End Game'))])));
  }
}
