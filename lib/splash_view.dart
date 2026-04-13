import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'intro_view.dart';
import 'main_view.dart';
import 'theme_app.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'core/api_service.dart';
import 'waiting_approval_view.dart';

class SplashView extends StatefulWidget {
  const SplashView({super.key});

  @override
  State<SplashView> createState() => _SplashViewState();
}

class _SplashViewState extends State<SplashView> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _scaleAnim;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );

    _scaleAnim = CurvedAnimation(
      parent: _ctrl,
      curve: Curves.elasticOut,
    );

    _fadeAnim = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.5, 1.0, curve: Curves.easeIn),
    );

    _ctrl.forward();
    
    // ⏱️ Logic de redirection
    Timer(const Duration(milliseconds: 2800), _checkSession);
  }

  Future<void> _checkSession() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMatricule = prefs.getString('userMatricule');

    if (!mounted) return;

    if (savedMatricule != null && savedMatricule.isNotEmpty) {
      try {
        final user = await ApiService.getUser(savedMatricule);
        if (user != null) {
          final bool isApproved = user['isApproved'] ?? false;
          final String phone = user['phone'] ?? '';

          if (!isApproved) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => const WaitingApprovalView()),
            );
          } else {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => MainView(
                  userMatricule: savedMatricule,
                  userPhone: phone,
                ),
              ),
            );
          }
          return;
        }
      } catch (e) {
        // En cas d'erreur API, on continue vers l'intro
      }
    }

    // Redirection par défaut si pas de session ou utilisateur non trouvé
    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, anim, __) => const IntroView(),
        transitionsBuilder: (_, anim, __, child) => FadeTransition(
          opacity: anim,
          child: child,
        ),
        transitionDuration: const Duration(milliseconds: 800),
      ),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.getIntroGradient(),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 🚗 Logo animé
              ScaleTransition(
                scale: _scaleAnim,
                child: Container(
                  width: 150,
                  height: 150,
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha(30),
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(40),
                        blurRadius: 40,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.directions_car_filled_rounded,
                    color: Colors.white,
                    size: 80,
                  ),
                ),
              ),
              const SizedBox(height: 32),
              
              // 📝 Texte animé
              FadeTransition(
                opacity: _fadeAnim,
                child: Column(
                  children: [
                    Text(
                      AppLocalizations.of(context)!.appTitle,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      AppLocalizations.of(context)!.urbanRoadGuard,
                      style: TextStyle(
                        color: Colors.white.withAlpha(180),
                        fontSize: 16,
                        letterSpacing: 4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
