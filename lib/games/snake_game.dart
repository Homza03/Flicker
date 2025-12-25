import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firestore_service.dart';
import '../services/rewards_engine.dart';

// Snake game: grid-based simple implementation.
// EN: Player moves snake with swipes (or arrows on desktop). Eating food increases score.
// CZ: Had ovládaný swipy / šipkami, jídlo dává skóre, XP a coins.
class SnakeGameScreen extends StatefulWidget {
  const SnakeGameScreen({super.key});

  @override
  State<SnakeGameScreen> createState() => _SnakeGameScreenState();
}

class _SnakeGameScreenState extends State<SnakeGameScreen> {
  static const int rows = 20;
  static const int cols = 20;
  final Random _rnd = Random();
  List<Point<int>> snake = [Point(10, 10)];
  Point<int> food = Point(5, 5);
  String direction = 'up';
  Timer? timer;
  int score = 0;

  @override
  void initState() {
    super.initState();
    spawnFood();
    start();
  }

  void start() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(milliseconds: 150), (_) => tick());
  }

  void spawnFood() {
    while (true) {
      final p = Point(_rnd.nextInt(cols), _rnd.nextInt(rows));
      if (!snake.contains(p)) {
        food = p;
        break;
      }
    }
  }

  void tick() {
    final head = snake.first;
    Point<int> next;
    switch (direction) {
      case 'up':
        next = Point(head.x, (head.y - 1 + rows) % rows);
        break;
      case 'down':
        next = Point(head.x, (head.y + 1) % rows);
        break;
      case 'left':
        next = Point((head.x - 1 + cols) % cols, head.y);
        break;
      default:
        next = Point((head.x + 1) % cols, head.y);
    }

    if (snake.contains(next)) {
      gameOver();
      return;
    }

    setState(() {
      snake.insert(0, next);
      if (next == food) {
        score += 10;
        spawnFood();
      } else {
        snake.removeLast();
      }
    });
  }

  void changeDirection(String dir) {
    // prevent reverse
    if ((direction == 'up' && dir == 'down') || (direction == 'down' && dir == 'up')) return;
    if ((direction == 'left' && dir == 'right') || (direction == 'right' && dir == 'left')) return;
    setState(() => direction = dir);
  }

  Future<void> gameOver() async {
    timer?.cancel();
    final rewards = Provider.of<RewardsEngine>(context, listen: false);
    final firestore = Provider.of<FirestoreService>(context, listen: false);
    // Award: XP + coins
    final xpGain = (score / 2).round();
    final coinsGain = (score / 5).round();
    rewards.addXp(xpGain);
    rewards.addCoins(coinsGain);
    await firestore.saveScore('anon_user', 'snake_game', score);

    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Game Over'),
        content: Text('Score: $score\nXP +$xpGain, Coins +$coinsGain'),
        actions: [
          TextButton(onPressed: () {
            Navigator.pop(context);
            reset();
            start();
          }, child: const Text('Retry')),
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Close')),
        ],
      ),
    );
  }

  void reset() {
    setState(() {
      snake = [Point(10, 10)];
      direction = 'up';
      score = 0;
      spawnFood();
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Snake')),
      body: Column(children: [
        Padding(padding: const EdgeInsets.all(8), child: Text('Score: $score')),
        Expanded(
          child: GestureDetector(
            onVerticalDragUpdate: (d) {
              if (d.delta.dy < -6) changeDirection('up');
              if (d.delta.dy > 6) changeDirection('down');
            },
            onHorizontalDragUpdate: (d) {
              if (d.delta.dx < -6) changeDirection('left');
              if (d.delta.dx > 6) changeDirection('right');
            },
            child: Container(
              padding: const EdgeInsets.all(8),
              color: Colors.black,
              child: LayoutBuilder(builder: (context, constraints) {
                final cellW = constraints.maxWidth / cols;
                final cellH = constraints.maxHeight / rows;
                return Stack(children: [
                  for (var p in snake)
                    Positioned(left: p.x * cellW, top: p.y * cellH, width: cellW, height: cellH, child: Container(color: Colors.green)),
                  Positioned(left: food.x * cellW, top: food.y * cellH, width: cellW, height: cellH, child: Container(color: Colors.red)),
                ]);
              }),
            ),
          ),
        ),
        Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
          IconButton(onPressed: () => changeDirection('left'), icon: const Icon(Icons.arrow_left)),
          Column(children: [
            IconButton(onPressed: () => changeDirection('up'), icon: const Icon(Icons.arrow_drop_up)),
            IconButton(onPressed: () => changeDirection('down'), icon: const Icon(Icons.arrow_drop_down)),
          ]),
          IconButton(onPressed: () => changeDirection('right'), icon: const Icon(Icons.arrow_right)),
        ])
      ]),
    );
  }
}
