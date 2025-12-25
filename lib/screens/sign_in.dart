import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/firebase_auth_service.dart';
import '../widgets/custom_button.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  bool _loading = false;

  Future<void> _signInWithGoogle() async {
    setState(() => _loading = true);
    try {
      final auth = Provider.of<FirebaseAuthService>(context, listen: false);
      final cred = await auth.signInWithGoogle();
      if (cred == null) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Přihlášení Google zrušeno')));
      } else {
        Navigator.pushReplacementNamed(context, '/');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chyba přihlášení: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signInAnonymously() async {
    setState(() => _loading = true);
    try {
      final auth = Provider.of<FirebaseAuthService>(context, listen: false);
      await auth.signInAnonymously();
      Navigator.pushReplacementNamed(context, '/');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Chyba anonymního přihlášení: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Přihlášení')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const SizedBox(height: 8),
            const Text('Vítejte v Mini Challenge Hub', textAlign: TextAlign.center, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            const Text('Přihlaste se přes Google pro synchronizaci skóre a odměn, nebo pokračujte anonymně.', textAlign: TextAlign.center),
            const SizedBox(height: 24),
            CustomButton(
              label: 'Přihlásit přes Google',
              icon: const Icon(Icons.login),
              isLoading: _loading,
              onPressed: _loading ? null : _signInWithGoogle,
              fullWidth: true,
            ),
            const SizedBox(height: 12),
            CustomButton(
              label: 'Pokračovat anonymně',
              variant: ButtonVariant.outlined,
              isLoading: _loading,
              onPressed: _loading ? null : _signInAnonymously,
              fullWidth: true,
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _loading ? null : () => Navigator.pushReplacementNamed(context, '/'),
              child: const Text('Přeskočit (pokračovat bez přihlášení)'),
            ),
          ],
        ),
      ),
    );
  }
}
