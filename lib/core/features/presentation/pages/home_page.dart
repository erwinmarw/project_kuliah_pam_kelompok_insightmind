import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'package:tugas_dari_ppt/core/theme/app_theme.dart';
import 'package:tugas_dari_ppt/core/widgets/custom_widgets.dart';
import 'package:tugas_dari_ppt/src/auth/login_screen.dart';

import '../providers/score_provider.dart';
import '../providers/history_provider.dart';
import 'screening_page.dart';
import 'biometric_page.dart';
import 'history_page.dart';

class AuthSession {
  static const String boxName = 'authBox';
  static const String keyLogin = 'isLoggedIn';

  static Future<bool> isLoggedIn() async {
    final box = await Hive.openBox(boxName);
    return box.get(keyLogin, defaultValue: false);
  }

  static Future<void> login() async {
    final box = await Hive.openBox(boxName);
    await box.put(keyLogin, true);
  }

  static Future<void> logout() async {
    final box = await Hive.openBox(boxName);
    await box.put(keyLogin, false);
  }
}

class HomePage extends ConsumerStatefulWidget {
  const HomePage({super.key});

  @override
  ConsumerState<HomePage> createState() => _HomePageState();
}

class _HomePageState extends ConsumerState<HomePage> {
  bool _authChecked = false;

  @override
  void initState() {
    super.initState();
    _checkAuth();
  }

  Future<void> _checkAuth() async {
    final loggedIn = await AuthSession.isLoggedIn();
    if (!loggedIn && mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    } else {
      setState(() => _authChecked = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_authChecked) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final score = ref.watch(scoreProvider);
    final history = ref.watch(historyProvider);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            elevation: 0,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: AppTheme.primaryGradient,
                ),
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        const Text(
                          'Selamat Datang di',
                          style:
                          TextStyle(color: Colors.white70, fontSize: 16),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.psychology,
                                color: Colors.white,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 12),
                            const Text(
                              'InsightMind',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Platform Screening Kesehatan Mental',
                          style:
                          TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            actions: [
              /// RIWAYAT
              IconButton(
                tooltip: 'Riwayat',
                icon: Badge(
                  isLabelVisible: history.isNotEmpty,
                  label: Text('${history.length}'),
                  child: const Icon(Icons.history),
                ),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const HistoryPage()),
                  );
                },
              ),

              IconButton(
                tooltip: 'Logout',
                icon: const Icon(Icons.logout),
                onPressed: () async {
                  await AuthSession.logout();
                  if (!mounted) return;
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const LoginScreen()),
                        (_) => false,
                  );
                },
              ),

              const SizedBox(width: 8),
            ],
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildStatsCard(context, score, history.length),
                  const SizedBox(height: 32),
                  const Text(
                    'Mulai Screening',
                    style:
                    TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  _buildScreeningCard(context),
                  const SizedBox(height: 16),
                  _buildBiometricCard(context),
                  const SizedBox(height: 32),
                  _buildInfoSection(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsCard(
      BuildContext context, int score, int historyCount) {
    return GradientCard(
      gradient: AppTheme.successGradient,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Status Anda',
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600),
              ),
              Container(
                padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Aktif',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w600),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                    'Skor Terakhir', score.toString(), Icons.score),
              ),
              Container(
                width: 1,
                height: 50,
                color: Colors.white.withOpacity(0.3),
              ),
              Expanded(
                child: _buildStatItem('Total Screening',
                    historyCount.toString(), Icons.history),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 8),
        Text(value,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
        Text(label,
            style:
            TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
      ],
    );
  }

  Widget _buildScreeningCard(BuildContext context) {
    return GlassCard(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const ScreeningPage()));
      },
      child: const ListTile(
        leading: Icon(Icons.quiz),
        title: Text('Screening Kuisioner'),
        subtitle: Text('10–15 menit'),
        trailing: Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  Widget _buildBiometricCard(BuildContext context) {
    return GlassCard(
      onTap: () {
        Navigator.push(context,
            MaterialPageRoute(builder: (_) => const BiometricPage()));
      },
      child: const ListTile(
        leading: Icon(Icons.sensors),
        title: Text('Sensor & Biometrik AI'),
        subtitle: Text('5–10 menit'),
        trailing: Icon(Icons.arrow_forward_ios),
      ),
    );
  }

  Widget _buildInfoSection() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Text(
        'InsightMind adalah platform edukatif untuk screening kesehatan mental.\n\n'
            'Disclaimer: Ini bukan alat diagnosis medis.',
        style: TextStyle(fontSize: 14),
      ),
    );
  }
}
