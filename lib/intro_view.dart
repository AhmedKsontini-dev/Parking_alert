import 'package:flutter/material.dart';
import 'register_view.dart';
import 'login_view.dart';
import 'theme_app.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class IntroView extends StatefulWidget {
  const IntroView({super.key});

  @override
  State<IntroView> createState() => _IntroViewState();
}

class _IntroViewState extends State<IntroView>
    with SingleTickerProviderStateMixin {

  late final AnimationController _ctrl;
  late final Animation<double>   _iconFade;
  late final Animation<double>   _iconScale;
  late final Animation<double>   _textFade;
  late final Animation<Offset>   _textSlide;
  late final Animation<double>   _btnFade;
  late final Animation<Offset>   _btnSlide;

  @override
  void initState() {
    super.initState();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );

    _iconFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl,
          curve: const Interval(0.0, 0.4, curve: Curves.easeOut)));
    _iconScale = Tween<double>(begin: 0.5, end: 1).animate(
      CurvedAnimation(parent: _ctrl,
          curve: const Interval(0.0, 0.4, curve: Curves.elasticOut)));

    _textFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl,
          curve: const Interval(0.25, 0.65, curve: Curves.easeOut)));
    _textSlide = Tween<Offset>(
            begin: const Offset(0, 0.3), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl,
            curve: const Interval(0.25, 0.65, curve: Curves.easeOut)));

    _btnFade = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl,
          curve: const Interval(0.55, 1.0, curve: Curves.easeOut)));
    _btnSlide = Tween<Offset>(
            begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(CurvedAnimation(parent: _ctrl,
            curve: const Interval(0.55, 1.0, curve: Curves.easeOut)));

    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _goToRegister() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const RegisterView()));
  }

  void _goToLogin() {
    Navigator.of(context).push(MaterialPageRoute(builder: (context) => const LoginView()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: AppTheme.getIntroGradient(),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Column(
              children: [
                const Spacer(flex: 2),

                FadeTransition(
                  opacity: _iconFade,
                  child: ScaleTransition(
                    scale: _iconScale,
                    child: Container(
                      width: 130,
                      height: 130,
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(26),
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: Colors.white.withAlpha(51), width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(51),
                            blurRadius: 40,
                            offset: const Offset(0, 16),
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.directions_car_rounded,
                        color: Colors.white,
                        size: 64,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 48),

                FadeTransition(
                  opacity: _textFade,
                  child: SlideTransition(
                    position: _textSlide,
                    child: Column(
                      children: [
                        Text(
                          AppLocalizations.of(context)!.appTitle,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 36,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                            height: 1.1,
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          AppLocalizations.of(context)!.introSubtitle,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.white.withAlpha(204),
                            fontSize: 17,
                            height: 1.55,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const Spacer(flex: 2),

                FadeTransition(
                  opacity: _btnFade,
                  child: SlideTransition(
                    position: _btnSlide,
                    child: Column(
                      children: [
                        _buildFeatureRow(),
                        const SizedBox(height: 40),

                        SizedBox(
                          width: double.infinity,
                          height: 58,
                          child: ElevatedButton(
                            onPressed: _goToRegister,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white,
                              foregroundColor: AppTheme.introBlueTop,
                              elevation: 0,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(18),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Text(
                                  AppLocalizations.of(context)!.getStarted,
                                  style: const TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w700,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                const Icon(Icons.arrow_forward_rounded, size: 20),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),
                        TextButton(
                          onPressed: _goToLogin,
                          child: const Text(
                            "Déjà inscrit ? Se connecter",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 15,
                              decoration: TextDecoration.underline,
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),
                        Text(
                          AppLocalizations.of(context)!.freeToUse,
                          style: TextStyle(
                            color: Colors.white.withAlpha(153),
                            fontSize: 12.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 36),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureRow() {
    final l10n = AppLocalizations.of(context)!;
    final features = [
      (Icons.flash_on_rounded, l10n.featureInstant),
      (Icons.shield_outlined, l10n.featureAnonymous),
      (Icons.groups_outlined, l10n.featureCommunity),
    ];
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: features.map((f) {
        final isLast = f == features.last;
        return Row(
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(26),
                borderRadius: BorderRadius.circular(30),
                border: Border.all(
                    color: Colors.white.withAlpha(51), width: 1),
              ),
              child: Row(
                children: [
                  Icon(f.$1, color: AppTheme.introAccent, size: 15),
                  const SizedBox(width: 5),
                  Text(
                    f.$2,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w500),
                  ),
                ],
              ),
            ),
            if (!isLast) const SizedBox(width: 8),
          ],
        );
      }).toList(),
    );
  }
}
