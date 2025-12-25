import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_auth_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil'),
        actions: [
          IconButton(
            tooltip: 'Odhlásit',
            icon: const Icon(Icons.logout),
            onPressed: () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (ctx) => AlertDialog(
                  title: const Text('Potvrzení'),
                  content: const Text('Opravdu se chcete odhlásit?'),
                  actions: [
                    TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Zrušit')),
                    TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Odhlásit')),
                  ],
                ),
              );
              if (confirm != true) return;
              final auth = Provider.of<FirebaseAuthService>(context, listen: false);
              try {
                await auth.signOut();
                Navigator.pushNamedAndRemoveUntil(context, '/', (route) => false);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Odhlášení selhalo: $e')));
              }
            },
          )
        ],
      ),
      body: const Center(child: Text('Profile screen (avatar, XP, coins, achievements)')),
    );
  }
}
