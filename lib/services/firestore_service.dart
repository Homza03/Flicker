import 'package:cloud_firestore/cloud_firestore.dart';

// Firestore service for profiles, scores and challenges.
// EN: Provides methods to save scores and update user rewards.
// CZ: Metody pro ukládání skóre a aktualizaci uživatelských odměn.
class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  FirestoreService();

  Future<void> saveScore(String userId, String gameId, int score) async {
    // Save score to 'gamescores' collection (one document per play)
    final doc = _db.collection('gamescores').doc();
    await doc.set({
      'userId': userId,
      'gameId': gameId,
      'score': score,
      'createdAt': FieldValue.serverTimestamp(),
    });
    // Also append to leaderboard per game
    final lbRef = _db.collection('leaderboards').doc(gameId);
    await lbRef.set({
      'topScores': FieldValue.arrayUnion([{'userId': userId, 'score': score, 'ts': FieldValue.serverTimestamp()}])
    }, SetOptions(merge: true));
  }

  Future<void> saveProfile(String userId, Map<String, dynamic> data) async {
    await _db.collection('users').doc(userId).set(data, SetOptions(merge: true));
  }
}
