import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/rewards_engine.dart';
import '../services/firebase_auth_service.dart';

// CZ: Zjednodušená simulace Klondike Solitaire pro demo účely.
// Simulace spustí rychlé kolo, přidělí XP/coins a uloží skóre do Firestore.
class SolitaireGameScreen extends StatefulWidget {
  const SolitaireGameScreen({super.key});

  @override
  State<SolitaireGameScreen> createState() => _SolitaireGameScreenState();
}

class _SolitaireGameScreenState extends State<SolitaireGameScreen> {
  bool _playing = false;
  int _score = 0;
  String? _lastResult; // cz text výsledku
  final Random _rnd = Random();

  Future<String> _ensureUserId() async {
    final auth = Provider.of<FirebaseAuthService>(context, listen: false);
    if (auth.currentUser != null) return auth.currentUser!.uid;
    final cred = await auth.signInAnonymously();
    return cred.user?.uid ?? 'unknown_user';
  }

  void _startRound() async {
    setState(() {
      _playing = true;
      _score = 0;
      _lastResult = null;
    });

    // krátká simulace průběhu kola
    await Future.delayed(const Duration(milliseconds: 300));
    for (int i = 0; i < 6; i++) {
      if (!mounted) return;
      setState(() => _score += _rnd.nextInt(200));
      await Future.delayed(const Duration(milliseconds: 250));
    }

    final bool won = _rnd.nextDouble() > 0.35; // ~65% šance vyhrát (demonstrace)
    final int finalScore = won ? (_score + 800 + _rnd.nextInt(1200)) : (_score + _rnd.nextInt(200));
    setState(() {
      _playing = false;
      _score = finalScore;
      _lastResult = won ? 'Vyhráli jste!' : 'Kolo dokončeno';
    });

    // odměny a uložení skóre
    final rewards = Provider.of<RewardsEngine>(context, listen: false);
    final firestore = Provider.of<FirestoreService>(context, listen: false);
    final uid = await _ensureUserId();
    final int xp = won ? 200 : 20;
    final int coins = won ? 100 : 5;
    rewards.addXp(xp);
    rewards.addCoins(coins);
    await firestore.saveScore(uid, 'solitaire_game', _score);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(_lastResult ?? ''),
        content: Text('Skóre: $_score\nXP +$xp, Mince +$coins'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Solitaire (Klondike)')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(children: [
                  const Text('Simulace Solitaire', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text('Toto je zjednodušená demonstrační verze. Plná hra Klondike není v tomto projektu implementována.', textAlign: TextAlign.center),
                ]),
              ),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Center(
                child: _playing
                    ? Column(mainAxisSize: MainAxisSize.min, children: [const CircularProgressIndicator(), const SizedBox(height: 12), const Text('Probíhá kolo...')])
                    : Column(mainAxisSize: MainAxisSize.min, children: [Text('Aktuální skóre: $_score', style: const TextStyle(fontSize: 20)), const SizedBox(height: 12), if (_lastResult != null) Text(_lastResult!, style: const TextStyle(fontSize: 16))]),
              ),
            ),
            ElevatedButton.icon(
              icon: const Icon(Icons.play_arrow),
              label: const Text('Spustit kolo'),
              onPressed: _playing ? null : _startRound,
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () async {
                // rychlé zobrazení posledního výsledku nebo help
                final auth = Provider.of<FirebaseAuthService>(context, listen: false);
                final uid = auth.currentUser?.uid ?? 'anon';
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Uživatel: $uid')));
              },
              child: const Text('Zobrazit uživatele'),
            ),
          ],
        ),
      ),
    );
  }
}
