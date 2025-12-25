import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/rewards_engine.dart';

// Simplified Tetris-like game: blocks fall as single-width tiles stacked in columns.
// EN: Abstracted Tetris where completing full rows grants points.
// CZ: Zjednodušený Tetris; plná řada = skóre + XP.
class TetrisGameScreen extends StatefulWidget {
  const TetrisGameScreen({super.key});

  @override
  State<TetrisGameScreen> createState() => _TetrisGameScreenState();
}

class _TetrisGameScreenState extends State<TetrisGameScreen> {
  static const int rows = 20;
  static const int cols = 10;
  final List<List<bool>> grid = List.generate(rows, (_) => List.generate(cols, (_) => false));
  Timer? timer;
  int currentCol = 4;
  int score = 0;
  final rnd = Random();

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(milliseconds: 600), (_) => fallTick());
  }

  void fallTick() {
    // drop a block into currentCol from top until it reaches filled cell
    for (int r = rows - 1; r >= 0; r--) {
      if (!grid[r][currentCol]) {
        // place here
        setState(() => grid[r][currentCol] = true);
        break;
      }
    }
    // pick new random column
    currentCol = rnd.nextInt(cols);
    checkFullRows();
  }

  void checkFullRows() {
    int cleared = 0;
    for (int r = rows - 1; r >= 0; r--) {
      if (grid[r].every((c) => c)) {
        cleared++;
        // remove row and shift above down
        for (int rr = r; rr > 0; rr--) {
          grid[rr] = List.from(grid[rr - 1]);
        }
        grid[0] = List.generate(cols, (_) => false);
        r++; // recheck same row index after shift
      }
    }
    if (cleared > 0) {
      setState(() => score += cleared * 100);
    }
  }

  Future<void> endGame() async {
    timer?.cancel();
    final rewards = Provider.of<RewardsEngine>(context, listen: false);
    final firestore = Provider.of<FirestoreService>(context, listen: false);
    final xpGain = (score / 5).round().clamp(10, 1000);
    final coinsGain = (score / 10).round();
    rewards.addXp(xpGain);
    rewards.addCoins(coinsGain);
    await firestore.saveScore('anon_user', 'tetris_game', score);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Score: $score\nRows cleared XP +$xpGain, Coins +$coinsGain'),
        actions: [
          TextButton(onPressed: () { Navigator.pop(context); reset(); }, child: const Text('Retry')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void reset() {
    for (int r = 0; r < rows; r++) grid[r] = List.generate(cols, (_) => false);
    setState(() { score = 0; currentCol = 4; });
    timer = Timer.periodic(const Duration(milliseconds: 600), (_) => fallTick());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tetris (simplified)')),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(8), child: Text('Score: $score')),
        Expanded(child: LayoutBuilder(builder: (context, constraints) {
          final cellW = constraints.maxWidth / cols;
          final cellH = constraints.maxHeight / rows;
          return GestureDetector(
            onTap: () {},
            child: Stack(children: [
              for (int r = 0; r < rows; r++)
                for (int c = 0; c < cols; c++)
                  Positioned(left: c * cellW, top: r * cellH, width: cellW, height: cellH, child: Container(margin: const EdgeInsets.all(1), color: grid[r][c] ? Colors.blue : Colors.black26)),
              Positioned(right: 10, bottom: 10, child: Column(children: [
                ElevatedButton(onPressed: () => setState(() => currentCol = (currentCol - 1 + cols) % cols), child: const Icon(Icons.arrow_left)),
                ElevatedButton(onPressed: () => setState(() => currentCol = (currentCol + 1) % cols), child: const Icon(Icons.arrow_right)),
                ElevatedButton(onPressed: () => endGame(), child: const Text('End')),
              ]))
            ]),
          );
        })),
      ]),
    );
  }
}
