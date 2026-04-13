import 'package:flutter/material.dart';
import 'theme_app.dart';
import 'core/api_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'main_view.dart';
import 'register_view.dart';

class WaitingApprovalView extends StatefulWidget {
  const WaitingApprovalView({super.key});

  @override
  State<WaitingApprovalView> createState() => _WaitingApprovalViewState();
}

class _WaitingApprovalViewState extends State<WaitingApprovalView> {
  bool _isChecking = false;

  Future<void> _checkStatus() async {
    setState(() => _isChecking = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final matricule = prefs.getString('userMatricule');
      
      if (matricule != null) {
        final user = await ApiService.getUser(matricule);
        if (user != null && user['isApproved'] == true) {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => MainView(
                userMatricule: matricule,
                userPhone: user['phone'] ?? '',
              ),
            ),
          );
          return;
        }
      }
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Votre compte est toujours en attente de validation.")),
        );
      }
    } catch (e) {
       if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de la vérification : $e")),
        );
      }
    } finally {
      if (mounted) setState(() => _isChecking = false);
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const RegisterView()));
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      body: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(32),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [colorScheme.primary.withOpacity(0.05), Colors.white],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.verified_user_outlined, size: 80, color: Colors.orange),
            const SizedBox(height: 32),
            const Text(
              "Compte en attente",
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              "L'administrateur vérifie actuellement vos documents (Carte Grise). Cette opération peut prendre quelques minutes.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, color: Colors.black54),
            ),
            const SizedBox(height: 48),
            if (_isChecking)
              const CircularProgressIndicator()
            else
              ElevatedButton.icon(
                onPressed: _checkStatus,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text("Vérifier à nouveau"),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
              ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: _logout,
              child: const Text("Se déconnecter / Utiliser un autre compte"),
            ),
          ],
        ),
      ),
    );
  }
}
