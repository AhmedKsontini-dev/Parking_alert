// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'theme_app.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'core/api_service.dart';

class NotificationsView extends StatefulWidget {
  final String userMatricule;
  
  const NotificationsView({super.key, required this.userMatricule});

  @override
  State<NotificationsView> createState() => _NotificationsViewState();
}

class _NotificationsViewState extends State<NotificationsView> with SingleTickerProviderStateMixin {
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

  Future<void> _refresh() async {
    setState(() {});
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
        title: Text(l10n.recentAlerts, style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: RefreshIndicator(
          onRefresh: _refresh,
          child: FutureBuilder<List<dynamic>>(
            future: ApiService.getAlerts(widget.userMatricule),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return Center(child: Text('${l10n.error}: ${snapshot.error}'));
              }
          
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
          
              if (!snapshot.hasData || snapshot.data == null) {
                return Center(child: Text(l10n.noNotifications));
              }
          
              final alerts = snapshot.data!;
              // On affiche UNIQUEMENT les messages non lus (pending)
              final pendingAlerts = alerts.where((a) => a['status'] == 'pending' && a['receiverMatricule'] == widget.userMatricule).toList();
          
              if (pendingAlerts.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notifications_off_rounded, size: 80, color: Colors.grey.withOpacity(0.3)),
                      const SizedBox(height: 16),
                      Text(
                        l10n.allClear,
                        style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                );
              }
          
              return ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                itemCount: pendingAlerts.length,
                itemBuilder: (context, index) {
                  final data = pendingAlerts[index] as Map<String, dynamic>;
                  final message = data['message'] ?? '';
                  final senderMatricule = data['senderMatricule'] ?? 'Unknown';
                  final status = data['status'] ?? 'pending';
                  final createdAtStr = data['created_at'];
                  final createdAt = createdAtStr != null ? DateTime.parse(createdAtStr) : null;
                  
                  final timeStr = createdAt != null 
                      ? DateFormat('dd/MM HH:mm').format(createdAt)
                      : '';
                  
                  final bool isOpen = status == 'open';
          
                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    elevation: 0,
                    color: !isOpen 
                        ? (isDark ? Colors.green.withAlpha(40) : Colors.green.withAlpha(30)) // Toujours Vert car filtré sur pending
                        : (isDark ? Colors.white.withAlpha(10) : Colors.grey.withAlpha(20)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: !isOpen ? Colors.green.withOpacity(0.3) : Colors.black.withAlpha(10),
                        width: 1
                      ),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: () async {
                        if (!isOpen) {
                          final alertId = data['_id'];
                          if (alertId != null) {
                            final success = await ApiService.updateAlertStatus(alertId, 'open');
                            if (success) {
                              _refresh(); // Rafraîchir la liste
                            }
                          }
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    CircleAvatar(
                                      radius: 18,
                                      backgroundColor: isOpen ? Colors.green.withOpacity(0.2) : colorScheme.primary.withOpacity(0.1),
                                      child: Icon(
                                        isOpen ? Icons.mark_email_read_rounded : Icons.mark_email_unread_rounded,
                                        size: 18,
                                        color: isOpen ? Colors.green : colorScheme.primary,
                                      ),
                                    ),
                                    const SizedBox(width: 12),
                                     Text(
                                      "${l10n.fromLabel}$senderMatricule",
                                      style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                                    ),
                                  ],
                                ),
                                if (!isOpen)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: colorScheme.secondary,
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                     child: Text(
                                      l10n.newBadge,
                                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              message,
                              style: TextStyle(
                                fontSize: 16,
                                height: 1.4,
                                fontWeight: isOpen ? FontWeight.normal : FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Icon(Icons.access_time_rounded, size: 14, color: Colors.grey.withOpacity(0.7)),
                                const SizedBox(width: 4),
                                Text(
                                  timeStr,
                                  style: TextStyle(fontSize: 12, color: Colors.grey.withOpacity(0.7), fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );
  }
}
