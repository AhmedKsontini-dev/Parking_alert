import 'package:flutter/material.dart';
import 'main.dart';
import 'theme_app.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SettingsView extends StatefulWidget {
  const SettingsView({super.key});

  @override
  State<SettingsView> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeIn);
    _ctrl.forward();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: AppBar(
        flexibleSpace: AppTheme.getAppBarGradient(isDark),
        title: Text(l10n.settings, style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            _buildSettingTile(
              context,
              l10n.darkMode,
              l10n.darkModeSubtitle,
              Icons.dark_mode_rounded,
              trailing: Switch(
                value: ParkingAlertApp.of(context).isDarkMode,
                onChanged: (v) => ParkingAlertApp.of(context).toggleTheme(v),
                activeColor: colorScheme.secondary,
              ),
            ),
            _buildSettingTile(
              context, 
              l10n.language, 
              l10n.languageSubtitle, 
              Icons.translate_rounded,
              onTap: () => _showLanguagePicker(context),
            ),
            _buildSettingTile(context, l10n.notifications, l10n.notificationsSubtitle, Icons.notifications_active_rounded),
            _buildSettingTile(context, l10n.privacyPolicy, l10n.privacyPolicySubtitle, Icons.shield_rounded),
            _buildSettingTile(context, l10n.helpSupport, l10n.helpSupportSubtitle, Icons.help_center_rounded),
            const SizedBox(height: 40),
            Center(
              child: Text(
                "${l10n.version} 2.0.0",
                style: TextStyle(color: Colors.grey.withOpacity(0.5), fontSize: 12, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingTile(BuildContext context, String title, String subtitle, IconData icon, {Widget? trailing, VoidCallback? onTap}) {
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 0,
      color: isDark ? colorScheme.surfaceVariant.withOpacity(0.5) : Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: colorScheme.primary.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(icon, color: colorScheme.primary, size: 24),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15)),
        subtitle: Text(subtitle, style: TextStyle(fontSize: 12, color: Colors.grey.withOpacity(0.8))),
        trailing: trailing ?? Icon(Icons.chevron_right_rounded, color: Colors.grey.withOpacity(0.5)),
        onTap: onTap,
      ),
    );
  }

  void _showLanguagePicker(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final appState = ParkingAlertApp.of(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                l10n.selectLanguage,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 20),
              _buildLanguageOption(context, l10n.english, "en", Icons.language_rounded, appState),
              _buildLanguageOption(context, l10n.french, "fr", Icons.language_rounded, appState),
              const SizedBox(height: 10),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLanguageOption(BuildContext context, String title, String code, IconData icon, ParkingAlertAppState appState) {
    final isSelected = appState.locale?.languageCode == code || (appState.locale == null && code == "en");
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(icon, color: isSelected ? colorScheme.primary : Colors.grey),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w900 : FontWeight.w500,
          color: isSelected ? colorScheme.primary : null,
        ),
      ),
      trailing: isSelected ? Icon(Icons.check_circle_rounded, color: colorScheme.primary) : null,
      onTap: () {
        appState.setLocale(Locale(code));
        Navigator.pop(context);
      },
    );
  }
}
