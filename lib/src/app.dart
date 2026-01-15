import 'package:flutter/material.dart';
import '../core/features/presentation/pages/home_page.dart';
import 'package:tugas_dari_ppt/src/auth/login_screen.dart';
import 'package:tugas_dari_ppt/src/auth/register_screen.dart';

class InsightMindApp extends StatelessWidget {
  const InsightMindApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InsightMind',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.indigo,
          foregroundColor: Colors.white,
        ),
        textTheme: const TextTheme(
          titleLarge: TextStyle(fontWeight: FontWeight.bold),
          bodyLarge: TextStyle(fontSize: 16),
        ),
      ),

      initialRoute: '/login',

      routes: {
        '/login': (context) => const LoginScreen(),
        '/register': (context) => const RegisterScreen(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
