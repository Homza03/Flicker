import 'package:flutter/material.dart';

// Rewards engine: XP, Coins, Boosters, Streak logic.
// EN: Manages in-memory XP/coins and applies boosters. Persist to Firestore in real app.
// CZ: Řídí XP/coins a boostery v paměti. V reálné aplikaci ukládat do Firestore.
class RewardsEngine extends ChangeNotifier {
  int xp = 0;
  int coins = 0;
  int streak = 0;
  DateTime? xpBoosterExpiry;

  void addXp(int amount) {
    final multiplier = isXpBoostActive ? 1.5 : 1.0;
    final gained = (amount * multiplier).round();
    xp += gained;
    notifyListeners();
  }

  void addCoins(int amount) {
    coins += amount;
    notifyListeners();
  }

  bool get isXpBoostActive => xpBoosterExpiry != null && xpBoosterExpiry!.isAfter(DateTime.now());

  void activateXpBooster(Duration duration) {
    xpBoosterExpiry = DateTime.now().add(duration);
    notifyListeners();
  }

  void useCoins(int amount) {
    if (coins >= amount) {
      coins -= amount;
      notifyListeners();
    }
  }

  void incrementStreak() {
    streak += 1;
    notifyListeners();
  }

  void resetStreak() {
    streak = 0;
    notifyListeners();
  }
}
