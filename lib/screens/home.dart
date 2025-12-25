import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/game_card.dart';
import '../services/rewards_engine.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _index = 0;

  final tabs = [
    const PlayTab(),
    const CommunityTab(),
    const ChallengesTab(),
  ];

  @override
  Widget build(BuildContext context) {
    final rewards = Provider.of<RewardsEngine>(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Challenge Hub'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [Text('XP: ${rewards.xp}'), Text('Coins: ${rewards.coins}')],
            ),
          )
        ],
      ),
      body: tabs[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.videogame_asset), label: 'Hrát'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Komunita'),
          BottomNavigationBarItem(icon: Icon(Icons.emoji_events), label: 'Výzvy'),
        ],
      ),
    );
  }
}

class PlayTab extends StatelessWidget {
  const PlayTab({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: const [
        GameCard(title: 'Tap Reflex', description: 'Reflex mini game', route: '/reflex'),
        GameCard(title: 'Spoj 3', description: 'Puzzle match-3', route: '/puzzle'),
        GameCard(title: 'Avoid the Spikes', description: 'Arcade avoider', route: '/avoid'),
        GameCard(title: 'Score 10', description: 'Reach score 10', route: '/score10'),
        GameCard(title: 'Snake', description: 'Classic snake', route: '/snake'),
        GameCard(title: 'Tetris', description: 'Falling blocks', route: '/tetris'),
        GameCard(title: 'Solitaire', description: 'Klondike', route: '/solitaire'),
        GameCard(title: 'Solidut', description: 'Zen puzzle', route: '/solidut'),
        GameCard(title: 'Jump Run', description: 'Runner', route: '/jump_run'),
        GameCard(title: 'Pinball Madness', description: 'Pinball', route: '/pinball'),
      ],
    );
  }
}

class CommunityTab extends StatelessWidget {
  const CommunityTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Community / Chat / Forum (stub)'));
  }
}

class ChallengesTab extends StatelessWidget {
  const ChallengesTab({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(child: Text('Daily Challenges (stub)'));
  }
}
