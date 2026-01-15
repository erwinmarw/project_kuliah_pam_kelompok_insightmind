import 'package:flutter/material.dart';
import 'login_screen.dart';
import 'package:tugas_dari_ppt/core/features/presentation/pages/home_page.dart';

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isLoggedIn = false;

    return isLoggedIn ? const HomePage() : const LoginScreen();
  }
}
