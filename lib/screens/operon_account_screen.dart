import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../enterprise/operon_cloud.dart';

/// Authentication is optional and distinct from the existing local demo.
/// Being signed in does NOT grant a role or access to any operating unit.
class OperonAccountScreen extends StatefulWidget {
  const OperonAccountScreen({super.key});

  @override
  State<OperonAccountScreen> createState() => _OperonAccountScreenState();
}

class _OperonAccountScreenState extends State<OperonAccountScreen> {
  final email = TextEditingController();
  final password = TextEditingController();
  bool busy = false;
  bool register = false;
  String? message;

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }

  Future<void> authenticate() async {
    final address = email.text.trim();
    if (address.isEmpty || password.text.isEmpty || busy) return;
    setState(() {
      busy = true;
      message = null;
    });
    try {
      if (register) {
        final result = await OperonCloud.client.auth.signUp(
          email: address,
          password: password.text,
        );
        if (!mounted) return;
        setState(() => message = result.session == null
            ? 'Registration submitted. Confirm your email before signing in.'
            : 'Account created. No unit permissions have been assigned.');
      } else {
        await OperonCloud.client.auth.signInWithPassword(
          email: address,
          password: password.text,
        );
        if (!mounted) return;
        setState(() => message = 'Signed in. Unit access requires administrator approval.');
      }
    } on AuthException catch (error) {
      if (mounted) setState(() => message = error.message);
    } catch (_) {
      if (mounted) {
        setState(() => message = 'Unable to connect. Please try again.');
      }
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  Future<void> signOut() async {
    if (busy) return;
    setState(() {
      busy = true;
      message = null;
    });
    try {
      await OperonCloud.client.auth.signOut();
    } on AuthException catch (error) {
      if (mounted) setState(() => message = error.message);
    } catch (_) {
      if (mounted) setState(() => message = 'Sign out failed. Please retry.');
    } finally {
      if (mounted) setState(() => busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = OperonCloud.configured;
    return Scaffold(
      appBar: AppBar(title: const Text('OPERON Account / Λογαριασμός')),
      body: !enabled
          ? const Center(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Text(
                  'Offline mode / Τοπική λειτουργία.\n'
                  'Cloud sign-in is not configured in this build.\n'
                  'Your saved demo tasks remain on this device.',
                  textAlign: TextAlign.center,
                ),
              ),
            )
          : StreamBuilder<AuthState>(
              stream: OperonCloud.client.auth.onAuthStateChange,
              builder: (context, snapshot) {
                final current = OperonCloud.client.auth.currentUser;
                return ListView(
                  padding: const EdgeInsets.all(20),
                  children: [
                    const Text(
                      'Development account only. Signing in does not authorize workflow approvals.',
                    ),
                    const SizedBox(height: 18),
                    if (current != null) ...[
                      const Icon(Icons.verified_user_outlined, size: 48),
                      const SizedBox(height: 10),
                      Text('Signed in as: ${current.email ?? current.id}'),
                      const SizedBox(height: 14),
                      FilledButton(
                        onPressed: busy ? null : signOut,
                        child: const Text('Sign out / Αποσύνδεση'),
                      ),
                    ] else ...[
                      TextField(
                        controller: email,
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        decoration: const InputDecoration(labelText: 'Email'),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: password,
                        obscureText: true,
                        autocorrect: false,
                        decoration: const InputDecoration(labelText: 'Password'),
                      ),
                      const SizedBox(height: 16),
                      FilledButton(
                        onPressed: busy ? null : authenticate,
                        child: Text(register
                            ? 'Create account / Εγγραφή'
                            : 'Sign in / Σύνδεση'),
                      ),
                      TextButton(
                        onPressed: busy
                            ? null
                            : () => setState(() {
                                  register = !register;
                                  message = null;
                                }),
                        child: Text(register
                            ? 'Already registered? Sign in'
                            : 'New test user? Register'),
                      ),
                    ],
                    if (busy) const LinearProgressIndicator(),
                    if (message != null) ...[
                      const SizedBox(height: 16),
                      Text(message!),
                    ],
                  ],
                );
              },
            ),
    );
  }
}
