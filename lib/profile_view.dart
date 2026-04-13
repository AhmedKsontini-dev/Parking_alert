import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'theme_app.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'plate_utils.dart';
import 'package:flutter/services.dart';
import 'core/api_service.dart';

class ProfileView extends StatefulWidget {
  final String userMatricule;
  final String userPhone;
  final Function(String, String) onUpdate;

  const ProfileView({
    super.key,
    required this.userMatricule,
    required this.userPhone,
    required this.onUpdate,
  });

  @override
  State<ProfileView> createState() => _ProfileViewState();
}

class _ProfileViewState extends State<ProfileView> with SingleTickerProviderStateMixin {
  late TextEditingController _plateCtrl;
  late TextEditingController _phoneCtrl;
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _plateCtrl = TextEditingController(text: widget.userMatricule);
    _phoneCtrl = TextEditingController(text: widget.userPhone);
    
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _plateCtrl.dispose();
    _phoneCtrl.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    final newPlate = _plateCtrl.text.trim().toUpperCase();
    final newPhone = _phoneCtrl.text.trim();

    if (newPlate.isEmpty || newPhone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorAllFields), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    try {
      final success = await ApiService.updateUser(widget.userMatricule, {
        'matricule': newPlate,
        'phone': newPhone,
      });

      if (!success) {
        throw Exception("Failed to update profile on server");
      }

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('userMatricule', newPlate);
      await prefs.setString('userPhone', newPhone);

      widget.onUpdate(newPlate, newPhone);

      setState(() => _isEditing = false);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.successProfileUpdated), behavior: SnackBarBehavior.floating),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("${AppLocalizations.of(context)!.error}: $e"), behavior: SnackBarBehavior.floating),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        flexibleSpace: AppTheme.getAppBarGradient(isDark),
        title: Text(AppLocalizations.of(context)!.myProfile, style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(_isEditing ? Icons.save_rounded : Icons.edit_rounded, color: Colors.white),
            onPressed: () {
              if (_isEditing) {
                _saveProfile();
              } else {
                setState(() => _isEditing = true);
              }
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 20),
              Center(
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: colorScheme.secondary, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 60,
                    backgroundColor: colorScheme.primary.withOpacity(0.1),
                    child: Icon(Icons.person_rounded, size: 80, color: colorScheme.primary),
                  ),
                ),
              ),
              const SizedBox(height: 40),
              
              _buildEditableField(
                AppLocalizations.of(context)!.licensePlateLabel, 
                _plateCtrl, 
                Icons.directions_car_rounded, 
                _isEditing, 
                isDark, 
                colorScheme,
                inputFormatters: [TunisianPlateFormatter()],
              ),
              const SizedBox(height: 20),
              _buildEditableField(
                AppLocalizations.of(context)!.phoneNumberLabel, 
                _phoneCtrl, 
                Icons.phone_rounded, 
                _isEditing, 
                isDark, 
                colorScheme,
                inputFormatters: [TunisianPhoneFormatter()],
              ),
              
              if (_isEditing) ...[
                const SizedBox(height: 32),
                TextButton(
                  onPressed: () {
                    setState(() {
                      _isEditing = false;
                      _plateCtrl.text = widget.userMatricule;
                      _phoneCtrl.text = widget.userPhone;
                    });
                  },
                  child: Text(AppLocalizations.of(context)!.cancelEditing, style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                ),
              ],
              
              const SizedBox(height: 48),
              Text(
                "${AppLocalizations.of(context)!.appTitle} ${AppLocalizations.of(context)!.version} 2.0.0",
                style: TextStyle(color: isDark ? Colors.white24 : Colors.black26, fontSize: 12, fontWeight: FontWeight.w900),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEditableField(
      String title, 
      TextEditingController controller, 
      IconData icon, 
      bool editing, 
      bool isDark, 
      ColorScheme colorScheme,
      {List<TextInputFormatter>? inputFormatters}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? colorScheme.surfaceVariant.withOpacity(0.5) : Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: editing ? colorScheme.secondary : (isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
          width: editing ? 2 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 15,
            offset: const Offset(0, 8),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: colorScheme.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: colorScheme.primary, size: 22),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.black54, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                if (editing)
                  TextField(
                    controller: controller,
                    autofocus: true,
                    textCapitalization: TextCapitalization.characters,
                    inputFormatters: inputFormatters,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.1),
                    decoration: const InputDecoration(
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      filled: false,
                    ),
                  )
                else
                  Text(
                    controller.text, 
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, letterSpacing: 1.1)
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
