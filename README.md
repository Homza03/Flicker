Mini Challenge Hub

[![Flutter CI](https://github.com/Homza03/Flicker/actions/workflows/flutter_ci.yml/badge.svg)](https://github.com/Homza03/Flicker/actions/workflows/flutter_ci.yml)

This repository contains a scaffold of a Flutter app for the "Mini Challenge Hub" concept.

Quick start (developer):

1) Install Flutter SDK (latest stable) and set up platform toolchain.
2) Configure a Firebase project and add Android / iOS config files (google-services.json / GoogleService-Info.plist).
3) Run:

```bash
flutter pub get
flutter run
```

Notes:
- This scaffold includes placeholders and service stubs for Firebase. Replace stubs with real initialization.
- Seeds are in `assets/seed/seed_data.dart` for local testing.
- Games are placeholders using Flame dependency; implement full game logic in `lib/games`.

Firebase integration:
- Add `firebase_core` initialization in `main.dart` and configure platforms.
- Implement `firebase_auth_service.dart`, `firestore_service.dart` and `notifications.dart` for real back-end.

Design:
- Primary color: #1E88E5
- Accent: #FFA726
- Font: Poppins (via google_fonts)
