import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:audioplayers/audioplayers.dart';
import '../services/firestore_service.dart';
import '../services/rewards_engine.dart';
import '../services/firebase_auth_service.dart';

class CityDashScreen extends StatefulWidget {
  const CityDashScreen({super.key});

  @override
  State<CityDashScreen> createState() => _CityDashScreenState();
}

class _CityDashScreenState extends State<CityDashScreen> {
  final Random _rnd = Random();
  Timer? _gameTimer;
  double _speed = 0.012; // movement per tick
  int _distance = 0; // meters
  int _coins = 0;
  bool _running = false;
  bool _magnetActive = false;
  int _magnetTicks = 0;
  static const int _magnetTotalTicks = 160;
  bool _shieldActive = false;
  int _shieldHits = 0;
  final AudioPlayer _audio = AudioPlayer();

  // player state
  int _lane = 1; // 0,1,2
  bool _jumping = false;
  int _jumpTicks = 0;
  bool _sliding = false;
  int _slideTicks = 0;

  // items moving from right(1.0) to left(0.0)
  final List<_Item> _items = [];

  @override
  void dispose() {
    _gameTimer?.cancel();
    super.dispose();
  }

  void _start() {
    _items.clear();
    _distance = 0;
    _coins = 0;
    _speed = 0.012;
    _running = true;
    _gameTimer?.cancel();
    _gameTimer = Timer.periodic(const Duration(milliseconds: 50), _tick);
  }

  void _end() async {
    _gameTimer?.cancel();
    setState(() => _running = false);
    // award rewards and save score
    final rewards = Provider.of<RewardsEngine>(context, listen: false);
    final firestore = Provider.of<FirestoreService>(context, listen: false);
    final auth = Provider.of<FirebaseAuthService>(context, listen: false);
    final uid = auth.currentUser?.uid ?? 'anon_user';
    final int xp = _distance + (_coins * 5);
    rewards.addXp(xp);
    rewards.addCoins(_coins);
    await firestore.saveScore(uid, 'city_dash', _distance);
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Konec běhu'),
        content: Text('Uběhnuto: $_distance m\nMince: $_coins\nXP +$xp'),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('OK'))],
      ),
    );
  }

  void _tick(Timer t) {
    // move items
    for (final it in List<_Item>.from(_items)) {
      it.x -= _speed;
      if (it.x < -0.1) _items.remove(it);
    }

    // spawn logic
    if (_rnd.nextDouble() < 0.06) {
      final lane = _rnd.nextInt(3);
      final typeRand = _rnd.nextDouble();
      String type = 'coin';
      if (typeRand > 0.92) type = 'power_shield';
      else if (typeRand > 0.86) type = 'power_magnet';
      else if (typeRand > 0.80) type = 'power_double';
      _items.add(_Item(x: 1.2, lane: lane, type: type));
    }

    // handle jump/slide ticks
    if (_jumping) {
      _jumpTicks++;
      if (_jumpTicks > 12) {
        _jumping = false;
        _jumpTicks = 0;
      }
    }
    if (_sliding) {
      _slideTicks++;
      if (_slideTicks > 12) {
        _sliding = false;
        _slideTicks = 0;
      }
    }

    // speed ramp
    _speed += 0.00003;

    // distance increment
    _distance += 1; // per tick ~50ms => coarse but fine for prototype

    // magnet auto-collect: collect nearby coins regardless of lane
    if (_magnetActive) {
      for (final it in List<_Item>.from(_items)) {
        if (it.type == 'coin' && it.x < 0.5) {
          _coins += 1;
          _items.remove(it);
          try {
            _audio.play(AssetSource('sounds/coin.wav'));
          } catch (_) {}
        }
      }
      _magnetTicks--;
      if (_magnetTicks <= 0) _magnetActive = false;
    }

    // collisions and normal collection
    for (final it in List<_Item>.from(_items)) {
      if ((it.x < 0.15 && it.x > -0.05) && it.lane == _lane) {
        if (it.type == 'coin') {
          _coins += 1;
          _items.remove(it);
          try {
            _audio.play(AssetSource('sounds/coin.wav'));
          } catch (_) {}
        } else if (it.type == 'power_magnet') {
          _magnetActive = true;
          _magnetTicks = 160; // ~8s
          _items.remove(it);
          try {
            _audio.play(AssetSource('sounds/powerup.wav'));
          } catch (_) {}
        } else if (it.type == 'power_shield') {
          _shieldActive = true;
          _shieldHits = 1;
          _items.remove(it);
          try {
            _audio.play(AssetSource('sounds/powerup.wav'));
          } catch (_) {}
        } else if (it.type == 'power_double') {
          // double coins: simple multiplier for next 20 coins
          // implement as temporary coin multiplier
          _items.remove(it);
          // for prototype simply give immediate bonus
          _coins += 5;
          try {
            _audio.play(AssetSource('sounds/powerup.wav'));
          } catch (_) {}
        } else if (it.type == 'obstacle') {
          // obstacle collision
          if (_shieldActive && _shieldHits > 0) {
            _shieldHits--;
            _shieldActive = _shieldHits > 0;
            _items.remove(it);
            try {
              _audio.play(AssetSource('sounds/shield_hit.wav'));
            } catch (_) {}
          } else if (!_jumping && !_sliding) {
            _end();
            return;
          } else {
            _items.remove(it);
          }
        }
      }
    }

    setState(() {});
  }

  void _onHorizontalDrag(DragUpdateDetails d) {
    if (d.delta.dx > 8) _changeLane(1);
    else if (d.delta.dx < -8) _changeLane(-1);
  }

  void _changeLane(int dir) {
    final newLane = (_lane + dir).clamp(0, 2);
    if (newLane != _lane) setState(() => _lane = newLane);
  }

  void _onVerticalDragEnd(DragEndDetails e) {
    // handled via velocity sign not reliable on web; use direction hints from onPanUpdate
  }

  void _onPanUpdate(DragUpdateDetails d) {
    if (d.delta.dy < -6) _jump();
    else if (d.delta.dy > 6) _slide();
    else if (d.delta.dx.abs() > 6) _onHorizontalDrag(DragUpdateDetails(globalPosition: d.globalPosition, delta: d.delta));
  }

  void _jump() {
    if (!_jumping && !_sliding) setState(() => _jumping = true);
  }

  void _slide() {
    if (!_sliding && !_jumping) setState(() => _sliding = true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('City Dash')),
      body: GestureDetector(
        onPanUpdate: _onPanUpdate,
        child: Column(
          children: [
            Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(children: [
                        Text('Dist: ${_distance}m'),
                        const SizedBox(width: 12),
                        Text('Coins: $_coins'),
                        const Spacer(),
                        if (_magnetActive) ...[
                          SizedBox(
                            width: 120,
                            child: Row(children: [
                              const Icon(Icons.magnet_on, color: Colors.tealAccent, size: 18),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                  SizedBox(height: 6, child: LinearProgressIndicator(value: _magnetTicks / _magnetTotalTicks, color: Colors.tealAccent, backgroundColor: Colors.tealAccent.withOpacity(0.15))),
                                  const SizedBox(height: 2),
                                  Text('${((_magnetTicks * 50) / 1000).ceil()}s', style: const TextStyle(fontSize: 11)),
                                ]),
                              ),
                              const SizedBox(width: 6),
                            ]),
                          ),
                        ],
                        if (_shieldActive) ...[
                          Row(children: [
                            const Icon(Icons.shield, color: Colors.lightBlueAccent, size: 18),
                            const SizedBox(width: 6),
                            Container(padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2), decoration: BoxDecoration(color: Colors.lightBlueAccent.withOpacity(0.12), borderRadius: BorderRadius.circular(6)), child: Text('x$_shieldHits', style: const TextStyle(fontSize: 12))),
                            const SizedBox(width: 6),
                          ]),
                        ],
                      ]),
                    ),
            Expanded(
              child: LayoutBuilder(builder: (ctx, cons) {
                final laneHeight = cons.maxHeight / 3;
                return Stack(children: [
                  // lanes background
                  for (int i = 0; i < 3; i++)
                    Positioned(
                      top: i * laneHeight,
                      left: 0,
                      right: 0,
                      height: laneHeight,
                      child: Container(decoration: BoxDecoration(border: Border(top: BorderSide(color: Colors.grey.shade800))),),
                    ),
                  // items
                  for (final it in _items)
                    Positioned(
                      top: it.lane * laneHeight + laneHeight * 0.25,
                      left: (cons.maxWidth * it.x) - 20,
                      child: _buildItemWidget(it),
                    ),
                  // player
                  Positioned(
                    left: 40,
                    top: _lane * laneHeight + laneHeight * 0.15 - (_jumping ? 40 : 0) + (_sliding ? 20 : 0),
                    child: Column(children: [
                      Icon(Icons.directions_run, size: 48, color: Colors.cyanAccent),
                      if (_jumping) const Text('JUMP'),
                      if (_sliding) const Text('SLIDE'),
                    ]),
                  ),
                ]);
              }),
            ),
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                ElevatedButton(onPressed: _running ? null : _start, child: const Text('Start')),
                ElevatedButton(onPressed: _running ? _end : null, child: const Text('End')),
                ElevatedButton(onPressed: () => setState(() => _items.add(_Item(x: 1.1, lane: _rnd.nextInt(3), type: 'coin'))), child: const Text('Spawn Coin')),
              ]),
            )
          ],
        ),
      ),
    );
  }

  Widget _buildItemWidget(_Item it) {
    switch (it.type) {
      case 'coin':
        return const Icon(Icons.circle, color: Colors.amber, size: 24);
      case 'power_magnet':
        return const Icon(Icons.magnet_on, color: Colors.tealAccent, size: 28);
      case 'power_shield':
        return const Icon(Icons.shield, color: Colors.lightBlueAccent, size: 28);
      case 'power_double':
        return const Icon(Icons.attach_money, color: Colors.greenAccent, size: 28);
      default:
        return const Icon(Icons.block, color: Colors.redAccent, size: 28);
    }
  }
}

class _Item {
  double x;
  int lane;
  String type; // coin, obstacle, power_magnet, power_shield, power_double
  _Item({required this.x, required this.lane, required this.type});
}
