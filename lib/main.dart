import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/home.dart';
import 'screens/sign_in.dart';
import 'screens/auth_gate.dart';
import 'games/snake_game.dart';
import 'games/tetris_game.dart';
import 'games/solitaire_game.dart';
import 'games/solidut_game.dart';
import 'games/jump_run_game.dart';
import 'games/pinball_game.dart';
import 'services/rewards_engine.dart';
import 'services/firebase_auth_service.dart';
import 'services/firestore_service.dart';
import 'services/notifications.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'services/setup_seed_data.dart';
import 'package:flutter/material.dart';

// Main entry point
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  // Initialize notifications (stub)
  final notifications = NotificationsService();
  await notifications.init();

  // Upload seed data once per device to Firestore
  final prefs = await SharedPreferences.getInstance();
  final seeded = prefs.getBool('seed_uploaded') ?? false;
  if (!seeded) {
    try {
      await SeedDataService().uploadSeedData();
      await prefs.setBool('seed_uploaded', true);
    } catch (e) {
      // ignore errors in seed upload for now; log to console
      print('Seed upload failed: $e');
    }
  }
  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(create: (_) => RewardsEngine()),
      Provider(create: (_) => FirebaseAuthService()),
      Provider(create: (_) => FirestoreService()),
      Provider(create: (_) => notifications),
    ],
    child: const MiniChallengeHubApp(),
  ));
}

class MiniChallengeHubApp extends StatelessWidget {
  const MiniChallengeHubApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mini Challenge Hub',
      theme: ThemeData(
        primaryColor: const Color(0xFF1E88E5),
        colorScheme: ColorScheme.fromSwatch().copyWith(secondary: const Color(0xFFFFA726)),
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      initialRoute: '/',
      routes: {
        '/': (ctx) => const AuthGate(),
        '/signin': (ctx) => const SignInScreen(),
        '/reflex': (ctx) => const ReflexGameScreen(),
        '/city_dash': (ctx) => const CityDashScreen(),
        '/puzzle': (ctx) => const PlaceholderWidget(),
        '/avoid': (ctx) => const PlaceholderWidget(),
        '/score10': (ctx) => const PlaceholderWidget(),
        '/snake': (ctx) => const SnakeGameScreen(),
        '/tetris': (ctx) => const TetrisGameScreen(),
        '/solitaire': (ctx) => const SolitaireGameScreen(),
        '/solidut': (ctx) => const SolidutGameScreen(),
        '/jump_run': (ctx) => const JumpRunGameScreen(),
        '/pinball': (ctx) => const PinballGameScreen(),
      },
    );
  }
}

// Small placeholder widget used for unimplemented routes
class PlaceholderWidget extends StatelessWidget {
  const PlaceholderWidget({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(appBar: AppBar(title: const Text('Coming soon')), body: const Center(child: Text('Coming soon')));
}
