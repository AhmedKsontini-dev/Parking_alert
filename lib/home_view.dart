import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'plate_utils.dart';
import 'intro_view.dart';
import 'core/api_service.dart';
import 'theme_app.dart';
import 'notifications_view.dart';

class HomeView extends StatefulWidget {
  final String userMatricule;
  final String userPhone;
  final int pendingCount;
  final VoidCallback onRefreshNotifications;

  const HomeView({
    super.key,
    required this.userMatricule,
    required this.userPhone,
    required this.pendingCount,
    required this.onRefreshNotifications,
  });

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {

  late TextEditingController _plateCtrl;
  late TextEditingController _messageCtrl;

  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  bool _isSending = false;

  @override
  void initState() {
    super.initState();

    _plateCtrl = TextEditingController();
    _messageCtrl = TextEditingController();

    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _slideAnim = Tween<Offset>(begin: const Offset(0, 0.1), end: Offset.zero).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.elasticOut),
    );

    _ctrl.forward();
  }

  @override
  void dispose() {
    _plateCtrl.dispose();
    _messageCtrl.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  void _showNotifications() {
     showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
          child: NotificationsView(userMatricule: widget.userMatricule),
        ),
      ),
    ).then((_) => widget.onRefreshNotifications());
  }

  Future<void> _sendAlert() async {
    final l10n = AppLocalizations.of(context)!;
    final plate = _plateCtrl.text.trim().toUpperCase();
    final message = _messageCtrl.text.trim();

    if (plate.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorPlateEmpty), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    if (message.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(AppLocalizations.of(context)!.errorMessageEmpty), behavior: SnackBarBehavior.floating),
      );
      return;
    }

    setState(() => _isSending = true);
    HapticFeedback.mediumImpact();

    try {
      final user = await ApiService.getUser(plate);

      if (user == null) {
        setState(() => _isSending = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.errorPlateNotRegistered), behavior: SnackBarBehavior.floating),
        );
        return;
      }

      final success = await ApiService.sendAlert({
        'receiverMatricule': plate,
        'message': message,
        'senderMatricule': widget.userMatricule,
        'senderPhone': widget.userPhone,
      });

      if (!success) {
        throw Exception("Failed to send alert to server");
      }

      setState(() => _isSending = false);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(l10n.successAlertSent), behavior: SnackBarBehavior.floating),
      );

      _plateCtrl.clear();
      _messageCtrl.clear();
    } catch (e) {
      setState(() => _isSending = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("${l10n.error}: $e"), behavior: SnackBarBehavior.floating),
      );
    }
  }

  Future<void> _logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(builder: (context) => const IntroView()),
      (route) => false,
    );
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
        title: Text(l10n.appTitle, style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: _showNotifications,
            icon: Badge(
              label: Text('${widget.pendingCount}'),
              isLabelVisible: widget.pendingCount > 0,
              child: const Icon(Icons.notifications_none_rounded, color: Colors.white),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  title: Text(l10n.logout),
                  content: Text(l10n.logoutConfirm),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: Text(l10n.cancel),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        _logout();
                      },
                      child: Text(l10n.logout, style: const TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: SlideTransition(
          position: _slideAnim,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.urbanRoadGuard,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.notifyDrivers,
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.black54,
                  ),
                ),
                const SizedBox(height: 32),
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: isDark ? colorScheme.surfaceVariant.withOpacity(0.5) : Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                        blurRadius: 20,
                        spreadRadius: 5,
                        offset: const Offset(0, 10),
                      )
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.warning_amber_rounded, color: colorScheme.secondary, size: 28),
                          const SizedBox(width: 12),
                          Text(
                            l10n.newAlert,
                            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _plateCtrl,
                        textCapitalization: TextCapitalization.characters,
                        inputFormatters: [TunisianPlateFormatter()],
                        decoration: InputDecoration(
                          hintText: l10n.plateNumberHint,
                          prefixIcon: const Icon(Icons.directions_car_filled_rounded),
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        controller: _messageCtrl,
                        decoration: InputDecoration(
                          hintText: l10n.issueHint,
                          prefixIcon: const Icon(Icons.maps_ugc_rounded),
                        ),
                        maxLines: 3,
                      ),
                      const SizedBox(height: 32),
                      Container(
                        width: double.infinity,
                        height: 56,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(16),
                          gradient: LinearGradient(
                            colors: [colorScheme.primary, colorScheme.primary.withOpacity(0.8)],
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: colorScheme.primary.withOpacity(0.3),
                              blurRadius: 12,
                              offset: const Offset(0, 6),
                            )
                          ],
                        ),
                        child: ElevatedButton(
                          onPressed: _isSending ? null : _sendAlert,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          ),
                          child: _isSending
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Icon(Icons.send_rounded, color: Colors.white, size: 20),
                                    const SizedBox(width: 8),
                                    Text(
                                      l10n.sendAlert,
                                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                                    ),
                                  ],
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 48),
                Center(
                  child: Column(
                    children: [
                      Icon(Icons.security_rounded, color: colorScheme.secondary.withOpacity(0.6), size: 40),
                      const SizedBox(height: 12),
                      Text(
                        l10n.secureAnonymousUrban,
                        style: TextStyle(
                          fontSize: 14,
                          letterSpacing: 1.5,
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white38 : Colors.black45,
                        ),
                      ),
                    ],
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