import 'package:cloud_firestore/cloud_firestore.dart';

// SeedDataService uploads initial challenges, quiz questions, avatars and themes.
// EN: Run this once after Firebase initialization to populate Firestore with demo data.
// CZ: Spusť jednou po inicializaci Firebase, nahraje demo data do Firestore.

class SeedDataService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> uploadSeedData() async {
    print("🌱 Uploading seed data to Firestore...");

    final challenges = [
      {"id": 1, "title": "Vyhraj 3 mini hry", "xp": 50, "coins": 20},
      {"id": 2, "title": "Získej 2000 bodů ve Snake", "xp": 80, "coins": 40},
      {"id": 3, "title": "Dokonči 2 kvízy", "xp": 40, "coins": 25},
      {"id": 4, "title": "Napiš 5 zpráv ve fóru", "xp": 30, "coins": 10},
      {"id": 5, "title": "Získej 5 badgeů", "xp": 60, "coins": 30},
      {"id": 6, "title": "Hraj 7 dní v řadě", "xp": 100, "coins": 50},
      {"id": 7, "title": "Vyhraj hru Solitaire", "xp": 70, "coins": 35},
      {"id": 8, "title": "Dokonči řadu v Tetrisu", "xp": 40, "coins": 15},
      {"id": 9, "title": "Dokonči puzzle Solidut", "xp": 90, "coins": 45},
      {"id": 10, "title": "Získej 500 XP v jednom dni", "xp": 120, "coins": 60}
    ];

    for (var c in challenges) {
      await _db.collection('challenges').doc(c['id'].toString()).set(c);
    }

    final questions = [
      {"q": "Kdo vynalezl elektrickou žárovku?", "a": ["Thomas Edison", "Nikola Tesla", "Albert Einstein", "Isaac Newton"], "c": 0},
      {"q": "Jaký je hlavní město Kanady?", "a": ["Toronto", "Vancouver", "Ottawa", "Montreal"], "c": 2},
      {"q": "Kolik planet má sluneční soustava?", "a": ["7", "8", "9", "10"], "c": 1},
      {"q": "Jaký prvek má chemickou značku O?", "a": ["Zlato", "Osmium", "Kyslík", "Stříbro"], "c": 2},
      {"q": "Kolik minut má hodina?", "a": ["50", "60", "70", "90"], "c": 1},
      {"q": "Kdo napsal román 1984?", "a": ["George Orwell", "Aldous Huxley", "Ray Bradbury", "J.K. Rowling"], "c": 0},
      {"q": "Jaký oceán je největší?", "a": ["Atlantský", "Tichý", "Indický", "Arktický"], "c": 1},
      {"q": "Kolik stran má šestiúhelník?", "a": ["5", "6", "7", "8"], "c": 1},
      {"q": "Kdo složil hymnu České republiky?", "a": ["Smetana", "Němcová", "Josef Kajetán Tyl", "Janáček"], "c": 2},
      {"q": "Jaká planeta je nejblíže Slunci?", "a": ["Merkur", "Venuše", "Země", "Mars"], "c": 0}
    ];

    for (var q in questions) {
      await _db.collection('quiz_questions').add(q);
    }

    final avatars = [
      {"id": 1, "name": "Ninja", "path": "assets/avatars/ninja.png"},
      {"id": 2, "name": "Robot", "path": "assets/avatars/robot.png"},
      {"id": 3, "name": "Astronaut", "path": "assets/avatars/astronaut.png"}
    ];
    for (var a in avatars) {
      await _db.collection('avatars').doc(a['id'].toString()).set(a);
    }

    final themes = [
      {"id": 1, "name": "Neon Blue", "color": "#1E88E5"},
      {"id": 2, "name": "Retro Orange", "color": "#FFA726"},
      {"id": 3, "name": "Pixel Purple", "color": "#9C27B0"}
    ];
    for (var t in themes) {
      await _db.collection('themes').doc(t['id'].toString()).set(t);
    }

    print("✅ Seed data uploaded!");
  }
}
