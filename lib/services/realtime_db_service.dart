import 'package:firebase_database/firebase_database.dart';

// Simple Realtime Database chat service (global chat)
// EN: Send and listen to messages in a 'global_chat' node.
// CZ: Odesílání a naslouchání zpráv v uzlu 'global_chat'.
class RealtimeDbService {
  final DatabaseReference _ref = FirebaseDatabase.instance.ref();

  Stream<DatabaseEvent> subscribeGlobalChat() {
    return _ref.child('global_chat').onChildAdded;
  }

  Future<void> sendMessage(String userId, String userName, String message) async {
    final msgRef = _ref.child('global_chat').push();
    await msgRef.set({
      'userId': userId,
      'userName': userName,
      'message': message,
      'createdAt': ServerValue.timestamp,
    });
  }
}
