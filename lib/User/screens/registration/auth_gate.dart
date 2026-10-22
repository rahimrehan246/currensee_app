import 'package:curreny/User/screens/converter/converter_screen.dart';
import 'package:curreny/user/screens/registration/register_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {

        // loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // logged in
        if (snapshot.hasData) {
          return const ConverterScreen();
        }

        // not logged in
        return const AuthApp();
      },
    );
  }
}