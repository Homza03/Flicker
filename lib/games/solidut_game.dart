import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/rewards_engine.dart';

// Solidut: minimalist Zen puzzle with colored balls. Tap to remove clusters.
// EN: Match clusters of same color to remove them. Clear all to win.
// CZ: Jednoduchá zen puzzle mechanika – odstranění skupin.
class SolidutGameScreen extends StatefulWidget {
  const SolidutGameScreen({super.key});

  @override
  State<SolidutGameScreen> createState() => _SolidutGameScreenState();
}

class _SolidutGameScreenState extends State<SolidutGameScreen> {
  static const int rows = 8;
  static const int cols = 8;
  final rnd = Random();
  late List<List<int>> board; // color index
  int score = 0;

  @override
  void initState() {
    super.initState();
    reset();
  }

  void reset() {
    board = List.generate(rows, (_) => List.generate(cols, (_) => rnd.nextInt(4)));
    score = 0;
    setState(() {});
  }

  void tapCell(int r, int c) {
    final color = board[r][c];
    final visited = <Point<int>>{};
    final toRemove = <Point<int>>[];
    void dfs(int rr, int cc) {
      final p = Point(rr, cc);
      if (rr < 0 || rr >= rows || cc < 0 || cc >= cols) return;
      if (visited.contains(p)) return;
      if (board[rr][cc] != color) return;
      visited.add(p);
      toRemove.add(p);
      dfs(rr + 1, cc);
      dfs(rr - 1, cc);
      dfs(rr, cc + 1);
      dfs(rr, cc - 1);
    }
    dfs(r, c);
    if (toRemove.length < 2) return;
    for (var p in toRemove) board[p.x][p.y] = -1;
    // gravity
    for (int col = 0; col < cols; col++) {
      final colVals = <int>[];
      for (int row = rows - 1; row >= 0; row--) {
        if (board[row][col] >= 0) colVals.add(board[row][col]);
      }
      for (int row = rows - 1, i = 0; row >= 0; row--, i++) {
        board[row][col] = i < colVals.length ? colVals[i] : rnd.nextInt(4);
      }
    }
    score += toRemove.length * 10;
    setState(() {});
    checkWin();
  }

  Future<void> checkWin() async {
    // rudimentary win: score > threshold
    if (score >= 200) {
      final rewards = Provider.of<RewardsEngine>(context, listen: false);
      final firestore = Provider.of<FirestoreService>(context, listen: false);
      final xp = 90;
      final coins = 45;
      rewards.addXp(xp);
      rewards.addCoins(coins);
      await firestore.saveScore('anon_user', 'solidut_game', score);
      if (!mounted) return;
      showDialog(context: context, builder: (_) => AlertDialog(title: const Text('Completed'), content: Text('Score: $score\nXP +$xp, Coins +$coins'), actions: [TextButton(onPressed: () { Navigator.pop(context); reset(); }, child: const Text('OK'))]));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(appBar: AppBar(title: const Text('Solidut (Zen Puzzle)')), body: Column(children: [
      Padding(padding: const EdgeInsets.all(8), child: Text('Score: $score')),
      Expanded(child: GridView.builder(gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: cols), itemCount: rows * cols, itemBuilder: (ctx, idx) {
        final r = idx ~/ cols;
        final c = idx % cols;
        final val = board[r][c];
        final colors = [Colors.red, Colors.blue, Colors.green, Colors.orange];
        return GestureDetector(onTap: () => tapCell(r, c), child: Container(margin: const EdgeInsets.all(2), color: colors[val % colors.length]));
      }))
    ]));
  }
}
