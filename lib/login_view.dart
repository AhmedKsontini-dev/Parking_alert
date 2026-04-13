import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'plate_utils.dart';
import 'notification_service.dart';
import 'main_view.dart';
import 'core/api_service.dart';
import 'theme_app.dart';
import 'waiting_approval_view.dart';

class LoginView extends StatefulWidget {
  const LoginView({super.key});

  @override
  State<LoginView> createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> with SingleTickerProviderStateMixin {
  final _plateCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _formKey   = GlobalKey<FormState>();
  bool _isLoading = false;

  late final AnimationController _ctrl;
  late final Animation<double>   _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  Future<void> _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    try {
      final matricule = _plateCtrl.text.trim();
      final phone = _phoneCtrl.text.trim();

      final user = await ApiService.loginUser({
        'matricule': matricule,
        'phone': phone,
      });

      if (user == null) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Matricule ou numéro de téléphone incorrect")),
        );
        setState(() => _isLoading = false);
        return;
      }

      final bool isApproved = user['isApproved'] ?? false;
      
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userMatricule', matricule);
      await prefs.setString('userPhone', phone);

      if (!mounted) return;
      if (!isApproved) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const WaitingApprovalView()));
      } else {
        await NotificationService.updateTokenInBackend(matricule);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => MainView(userMatricule: matricule, userPhone: phone)),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Erreur: $e")));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: const Text("Connexion")),
      body: FadeTransition(
        opacity: _fade,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Icon(Icons.lock_person_rounded, size: 80, color: AppTheme.registerPrimary),
                const SizedBox(height: 16),
                const Text("Bon retour parmi nous !", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                const SizedBox(height: 32),
                
                TextFormField(
                  controller: _plateCtrl,
                  textCapitalization: TextCapitalization.characters,
                  inputFormatters: [TunisianPlateFormatter()],
                  decoration: InputDecoration(
                    labelText: l10n.licensePlateLabel,
                    prefixIcon: const Icon(Icons.directions_car_filled_rounded),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? "Champ obligatoire" : null,
                ),
                const SizedBox(height: 16),
                
                TextFormField(
                  controller: _phoneCtrl,
                  keyboardType: TextInputType.phone,
                  inputFormatters: [TunisianPhoneFormatter()],
                  decoration: InputDecoration(
                    labelText: l10n.phoneNumberLabel,
                    prefixIcon: const Icon(Icons.phone_rounded),
                  ),
                  validator: (v) => (v == null || v.isEmpty) ? "Champ obligatoire" : null,
                ),
                const SizedBox(height: 48),
                
                SizedBox(
                  width: double.infinity,
                  height: 58,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _onLogin,
                    style: ElevatedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading ? const CircularProgressIndicator() : const Text("Se connecter"),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
