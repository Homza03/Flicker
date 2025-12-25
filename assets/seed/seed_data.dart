// Seed data for testing (users, challenges, quizzes)
// EN: Simple Dart file with sample maps to import if needed.
// CZ: Jednoduchý soubor s ukázkovými daty pro testování.

const sampleUsers = [
  {"uid": "user1", "name": "Alice", "xp": 120, "coins": 50},
  {"uid": "user2", "name": "Bob", "xp": 200, "coins": 120},
];

const sampleChallenges = [
  {"id": "c1", "title": "Win 3 games", "reward": {"xp": 20, "coins": 10}},
  {"id": "c2", "title": "Answer 2 quizzes", "reward": {"xp": 15, "coins": 5}},
];

const sampleQuizzes = [
  {"id":"q1","category":"General","questions":[{"q":"Capital of France?","opts":["Paris","Berlin","Rome"],"a":"Paris"}]}
];
