import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/rewards_engine.dart';

// Solitaire placeholder: simulates a round. Full Klondike is out of scope for scaffold.
// EN: Simple round simulator that awards XP/coins on win.
// CZ: Zjednodušený Klondike stub – simulace kola s náhodným výsledkem.
class SolitaireGameScreen extends StatefulWidget {
  const SolitaireGameScreen({super.key});

  @override
  State<SolitaireGameScreen> createState() => _SolitaireGameScreenState();
}

class _SolitaireGameScreenState extends State<SolitaireGameScreen> {
  bool playing = false;
  int score = 0;
  final rnd = Random();

  void startRound() {
    setState(() { playing = true; score = 0; });
    Timer(const Duration(seconds: 3), () async {
      final won = rnd.nextBool();
      setState(() { playing = false; score = won ? 1000 + rnd.nextInt(2000) : (rnd.nextInt(200)); });
      await onRoundEnd(won);
    });
  }

  Future<void> onRoundEnd(bool won) async {
    final rewards = Provider.of<RewardsEngine>(context, listen: false);
    final firestore = Provider.of<FirestoreService>(context, listen: false);
    final xp = won ? 200 : 20;
    final coins = won ? 100 : 5;
    rewards.addXp(xp);
    rewards.addCoins(coins);
    await firestore.saveScore('anon_user', 'solitaire_game', score);
    if (!mounted) return;
    showDialog(context: context, builder: (_) => AlertDialog(title: Text(won ? 'You won!' : 'Round over'), content: Text('Score: $score\nXP +$xp, Coins +$coins'), actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))]));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Solitaire (Klondike)')), body: Center(child: playing ? const CircularProgressIndicator() : ElevatedButton(onPressed: startRound, child: const Text('Start Round'))));
  }
}
