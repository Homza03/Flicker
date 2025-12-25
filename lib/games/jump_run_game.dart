import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/rewards_engine.dart';

// Jump Run: simple runner where player taps to jump and avoid obstacles, collects coins.
class JumpRunGameScreen extends StatefulWidget {
  const JumpRunGameScreen({super.key});

  @override
  State<JumpRunGameScreen> createState() => _JumpRunGameScreenState();
}

class _JumpRunGameScreenState extends State<JumpRunGameScreen> {
  double playerY = 0.0;
  double velocity = 0.0;
  Timer? timer;
  int score = 0;
  final rnd = Random();

  void start() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 50), (_) => update());
  }

  void update() {
    setState(() {
      velocity += 0.6; // gravity
      playerY += velocity;
      if (playerY > 1.2) playerY = 1.2;
      // random coin spawn simulated by random increments
      if (rnd.nextDouble() < 0.02) score += 1;
    });
  }

  void jump() { velocity = -8; }

  Future<void> end() async {
    timer?.cancel();
    final rewards = Provider.of<RewardsEngine>(context, listen: false);
    final firestore = Provider.of<FirestoreService>(context, listen: false);
    final xp = (score * 5) + 50;
    final coins = score * 2;
    rewards.addXp(xp);
    rewards.addCoins(coins);
    await firestore.saveScore('anon_user', 'jump_run_game', score);
    if (!mounted) return;
    showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Run Ended'), content: Text('Score: $score\nXP +$xp, Coins +$coins'), actions: [TextButton(onPressed: () { Navigator.pop(context); setState(() { score = 0; }); start(); }, child: const Text('Retry'))]));
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
    return Scaffold(appBar: AppBar(title: const Text('Jump Run')), body: GestureDetector(onTap: jump, child: Stack(children: [
      Positioned.fill(child: Container(color: Colors.lightBlueAccent)),
      Positioned(top: 200 + playerY * 100, left: 50, child: const CircleAvatar(radius: 20, backgroundColor: Colors.yellow)),
      Positioned(top: 20, right: 20, child: Text('Score: $score', style: const TextStyle(fontSize: 18, color: Colors.white))),
      Positioned(bottom: 20, right: 20, child: ElevatedButton(onPressed: () => end(), child: const Text('End Run'))),
    ])));
  }
}
