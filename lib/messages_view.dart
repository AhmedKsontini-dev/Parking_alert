// import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'theme_app.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'core/api_service.dart';

class MessagesView extends StatefulWidget {
  final String userMatricule;
  
  const MessagesView({super.key, required this.userMatricule});

  @override
  State<MessagesView> createState() => _MessagesViewState();
}

class _MessagesViewState extends State<MessagesView> with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _fadeAnim;
  
  // 🔘 0: Reçus, 1: Envoyés
  int _activeFilter = 0;

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
        title: Text(l10n.messageHistory, style: const TextStyle(fontWeight: FontWeight.w800, letterSpacing: 1.2)),
        centerTitle: true,
      ),
      body: FadeTransition(
        opacity: _fadeAnim,
        child: Column(
          children: [
            // 🏷️ Filter Toggle
            _buildFilterToggle(l10n),
            
            Expanded(
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
                      return Center(child: Text(l10n.noMessages));
                    }
                
                    final allAlerts = snapshot.data!;
                    final filteredDocs = allAlerts.where((alert) {
                      if (_activeFilter == 0) {
                        return alert['receiverMatricule'] == widget.userMatricule;
                      } else {
                        return alert['senderMatricule'] == widget.userMatricule;
                      }
                    }).toList();
                
                    if (filteredDocs.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _activeFilter == 0 ? Icons.move_to_inbox_rounded : Icons.outbox_rounded, 
                              size: 80, 
                              color: Colors.grey.withOpacity(0.3)
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _activeFilter == 0 ? l10n.noReceivedMessages : l10n.noSentMessages,
                              style: const TextStyle(fontSize: 18, color: Colors.grey, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                      );
                    }
                
                    return ListView.builder(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      itemCount: filteredDocs.length,
                      itemBuilder: (context, index) {
                        final data = filteredDocs[index] as Map<String, dynamic>;
                        final message = data['message'] ?? '';
                        final sender = data['senderMatricule'] ?? 'Unknown';
                        final recipient = data['receiverMatricule'] ?? 'Unknown';
                        final status = data['status'] ?? 'pending';
                        final createdAtStr = data['created_at'];
                        final createdAt = createdAtStr != null ? DateTime.parse(createdAtStr) : null;
                        
                        final timeStr = createdAt != null 
                            ? DateFormat('dd/MM HH:mm').format(createdAt)
                            : '';
                        
                        final isSent = sender == widget.userMatricule;
                        final isOpen = status == 'open';
                
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16),
                          elevation: 0,
                          color: !isSent && !isOpen 
                              ? (isDark ? Colors.green.withAlpha(40) : Colors.green.withAlpha(30)) // NOUVEAU = Vert
                              : (isDark ? Colors.white.withAlpha(10) : Colors.grey.withAlpha(20)), // LU = Gris clair / Transparent
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                            side: BorderSide(
                              color: !isSent && !isOpen ? Colors.green.withOpacity(0.3) : Colors.black.withAlpha(10),
                              width: 1
                            ),
                          ),
                          child: InkWell(
                            borderRadius: BorderRadius.circular(20),
                            onTap: () async {
                              if (!isSent && !isOpen) {
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
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.all(10),
                                        decoration: BoxDecoration(
                                          color: isSent 
                                              ? colorScheme.primary.withOpacity(0.1) 
                                              : (isOpen ? Colors.green.withOpacity(0.1) : colorScheme.secondary.withOpacity(0.1)),
                                          shape: BoxShape.circle,
                                        ),
                                        child: Icon(
                                          isSent ? Icons.outbox_rounded : Icons.move_to_inbox_rounded,
                                          color: isSent ? colorScheme.primary : (isOpen ? Colors.green : colorScheme.secondary),
                                          size: 22,
                                        ),
                                      ),
                                      const SizedBox(width: 16),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                              children: [
                                                Text(
                                                  isSent ? "${l10n.toLabel}$recipient" : "${l10n.fromLabel}$sender",
                                                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13),
                                                ),
                                                Text(
                                                  timeStr,
                                                  style: TextStyle(fontSize: 11, color: Colors.grey.withOpacity(0.8), fontWeight: FontWeight.bold),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              message,
                                              style: TextStyle(
                                                fontSize: 15,
                                                height: 1.4,
                                                fontWeight: (!isSent && !isOpen) ? FontWeight.bold : FontWeight.normal,
                                                color: isDark ? Colors.white : Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  if (isSent) _buildStatusBadge(isOpen, l10n),
                                  if (!isSent && !isOpen) _buildNewBadge(colorScheme, l10n),
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
          ],
        ),
      ),
    );
  }

  Widget _buildFilterToggle(AppLocalizations l10n) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        children: [
          _buildFilterButton(0, l10n.received, Icons.move_to_inbox_rounded, l10n),
          const SizedBox(width: 12),
          _buildFilterButton(1, l10n.sent, Icons.outbox_rounded, l10n),
        ],
      ),
    );
  }

  Widget _buildFilterButton(int index, String label, IconData icon, AppLocalizations l10n) {
    final active = _activeFilter == index;
    final colorScheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() => _activeFilter = index);
        },
        child: AnimatedContainer(
          height: 52,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          decoration: BoxDecoration(
            color: active 
                ? (isDark ? colorScheme.primary : colorScheme.primary.withOpacity(0.1)) 
                : (isDark ? Colors.white.withAlpha(10) : Colors.black.withAlpha(10)),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: active ? colorScheme.primary : Colors.transparent,
              width: 2,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon, 
                size: 18, 
                color: active ? (isDark ? Colors.white : colorScheme.primary) : Colors.grey
              ),
              const SizedBox(width: 10),
              Text(
                label,
                style: TextStyle(
                  fontWeight: active ? FontWeight.w900 : FontWeight.w500,
                  fontSize: 14,
                  color: active ? (isDark ? Colors.white : colorScheme.primary) : Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(bool isOpen, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: isOpen ? Colors.green.withOpacity(0.1) : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(
                isOpen ? Icons.done_all_rounded : Icons.done_rounded,
                size: 14,
                color: isOpen ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 6),
              Text(
                isOpen ? l10n.readStatus : l10n.sentStatus,
                style: TextStyle(
                  fontSize: 10, 
                  color: isOpen ? Colors.green : Colors.grey,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildNewBadge(ColorScheme colorScheme, AppLocalizations l10n) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: colorScheme.secondary,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            l10n.newStatus,
            style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w900),
          ),
        ),
      ],
    );
  }
}
