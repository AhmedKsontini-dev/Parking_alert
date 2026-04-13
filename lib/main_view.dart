import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';
import 'home_view.dart';
import 'notifications_view.dart';
import 'messages_view.dart';
import 'profile_view.dart';
import 'settings_view.dart';
import 'theme_app.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'core/api_service.dart';
import 'dart:async';

class MainView extends StatefulWidget {
  final String userMatricule;
  final String userPhone;

  const MainView({
    super.key,
    required this.userMatricule,
    required this.userPhone,
  });

  @override
  State<MainView> createState() => _MainViewState();
}

class _MainViewState extends State<MainView> {
  int _currentIndex = 0;
  late String _userMatricule;
  late String _userPhone;
  int _pendingCount = 0;
  Timer? _refreshTimer;

  @override
  void initState() {
    super.initState();
    _userMatricule = widget.userMatricule;
    _userPhone = widget.userPhone;
    
    // ⚡ Mettre à jour le Token FCM au démarrage
    NotificationService.updateTokenInBackend(_userMatricule);
    
    // Initial fetch and set timer for periodic refresh (simulation of real-time)
    _fetchPendingCount();
    _refreshTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      _fetchPendingCount();
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchPendingCount() async {
    final alerts = await ApiService.getAlerts(_userMatricule);
    if (!mounted) return;
    setState(() {
      _pendingCount = alerts.where((a) => a['status'] == 'pending' && a['receiverMatricule'] == _userMatricule).length;
    });
  }

  void _updateUserInfo(String newMatricule, String newPhone) {
    setState(() {
      _userMatricule = newMatricule;
      _userPhone = newPhone;
    });
    _fetchPendingCount();
  }

  List<Widget> get _pages => [
        HomeView(
          userMatricule: _userMatricule, 
          userPhone: _userPhone, 
          pendingCount: _pendingCount,
          onRefreshNotifications: _fetchPendingCount,
        ),
        MessagesView(userMatricule: _userMatricule),
        ProfileView(
          userMatricule: _userMatricule,
          userPhone: _userPhone,
          onUpdate: _updateUserInfo,
        ),
        const SettingsView(),
      ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final colorScheme = Theme.of(context).colorScheme;
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: colorScheme.surface,
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black54 : Colors.black.withAlpha(26),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: NavigationBar(
          selectedIndex: _currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              _currentIndex = index;
            });
            _fetchPendingCount();
          },
          backgroundColor: colorScheme.surface,
          indicatorColor: colorScheme.primary.withAlpha(30),
          destinations: [
            NavigationDestination(
              icon: const Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded, color: colorScheme.primary),
              label: l10n.navHome,
            ),
            
            NavigationDestination(
              icon: const Icon(Icons.chat_outlined),
              selectedIcon: Icon(Icons.chat_rounded, color: colorScheme.primary),
              label: l10n.navMessages,
            ),
            NavigationDestination(
              icon: const Icon(Icons.person_outline),
              selectedIcon: Icon(Icons.person_rounded, color: colorScheme.primary),
              label: l10n.navProfile,
            ),
            NavigationDestination(
              icon: const Icon(Icons.settings_outlined),
              selectedIcon: Icon(Icons.settings_rounded, color: colorScheme.primary),
              label: l10n.navSettings,
            ),
          ],
        ),
      ),
    );
  }
}
