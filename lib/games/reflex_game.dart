import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import '../services/rewards_engine.dart';
import '../services/firestore_service.dart';

// Tap Reflex implemented with Flame's TapDetector in a small game loop.
class ReflexGameScreen extends StatefulWidget {
  const ReflexGameScreen({super.key});

  @override
  State<ReflexGameScreen> createState() => _ReflexGameScreenState();
}

class _ReflexGameScreenState extends State<ReflexGameScreen> {
  late TapReflexGame game;

  @override
  void initState() {
    super.initState();
    game = TapReflexGame(onGameOver: _onGameOver);
  }

  void _onGameOver(int score) async {
    final rewards = Provider.of<RewardsEngine>(context, listen: false);
    final firestore = Provider.of<FirestoreService>(context, listen: false);
    // Award XP and coins (simple formula)
    final xpGain = score * 2;
    final coinsGain = (score / 2).floor();
    rewards.addXp(xpGain);
    rewards.addCoins(coinsGain);

    // If user exists, save score to Firestore (stub: use anonymous id)
    final userId = 'anon_user';
    await firestore.saveScore(userId, 'tap_reflex', score);

    // Show result dialog
    if (!mounted) return;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Score: $score\nXP +$xpGain, Coins +$coinsGain'),
        actions: [
          TextButton(onPressed: () {
            Navigator.pop(context);
            setState(() => game = TapReflexGame(onGameOver: _onGameOver));
          }, child: const Text('Retry')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tap Reflex')),
      body: GameWidget(game: game),
    );
  }
}

class TapReflexGame extends FlameGame with TapDetector, HasTappables {
  final void Function(int) onGameOver;
  int score = 0;
  double timeLeft = 10.0; // 10 seconds round
  Timer? _timer;

  TapReflexGame({required this.onGameOver});

  @override
  Future<void> onLoad() async {
    // Start countdown
    _timer = Timer.periodic(const Duration(milliseconds: 100), (t) {
      timeLeft -= 0.1;
      if (timeLeft <= 0) {
        t.cancel();
        overlays.clear();
        onGameOver(score);
      }
    });
  }

  @override
  void onTapDown(TapDownInfo info) {
    score++;
  }

  @override
  void render(Canvas c) {
    super.render(c);
    final tp = TextPaint(style: const TextStyle(color: Colors.white, fontSize: 24));
    tp.render(c, 'Time: ${timeLeft.toStringAsFixed(1)}', Vector2(10, 10));
    tp.render(c, 'Score: $score', Vector2(10, 40));
  }

  @override
  void onRemove() {
    _timer?.cancel();
    super.onRemove();
  }
}
