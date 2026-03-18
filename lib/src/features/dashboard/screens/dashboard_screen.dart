import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/connectivity_provider.dart';
import '../../../core/providers/sync_status_provider.dart';
import '../../../core/providers/theme_provider.dart';
import '../../../core/services/sync_service.dart';
import '../../../components/animated_background.dart';
import '../widgets/sidebar.dart';
import '../widgets/dashboard_content.dart';
import '../widgets/sync_status_widget.dart';
import 'profile_page.dart';
import 'settings_page.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _selectedIndex = 0;
  bool _sidebarOpen = false;

  @override
  void initState() {
    super.initState();
    // Set initial sidebar state based on screen size
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _updateSidebarState();
      // Initialize SyncService with SyncStatusProvider
      final syncStatusProvider = context.read<SyncStatusProvider>();
      SyncService.setSyncStatusProvider(syncStatusProvider);
    });
  }

  void _updateSidebarState() {
    if (mounted) {
      final screenWidth = MediaQuery.of(context).size.width;
      setState(() {
        // On desktop (lg+), sidebar is open by default
        // On mobile/tablet, sidebar is closed by default
        _sidebarOpen = screenWidth >= 1024;
      });
    }
  }

  void _onItemSelected(int index) {
    setState(() {
      _selectedIndex = index;
      // On mobile, close sidebar after selection
      if (MediaQuery.of(context).size.width < 1024) {
        _sidebarOpen = false;
      }
    });
  }

  void _toggleSidebar() {
    setState(() {
      _sidebarOpen = !_sidebarOpen;
    });
  }

  Widget _buildTopBarTitle(
    ThemeData theme,
    LocaleProvider localeProvider,
    bool isMobile,
  ) {
    final pageTitle = _getPageTitle(localeProvider);

    if (isMobile) {
      return Text(
        pageTitle,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: -0.2,
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          pageTitle,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        Text(
          localeProvider.translate('nav.brandName'),
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildConnectivityButton(AppThemeTokens? tokens) {
    return Consumer<ConnectivityProvider>(
      builder: (context, connectivityProvider, child) {
        final isOnline = connectivityProvider.isOnline;
        final statusColor = isOnline
            ? (tokens?.online ?? Colors.green)
            : (tokens?.offline ?? Colors.red);

        return Tooltip(
          message: isOnline ? 'Online' : 'Offline',
          child: Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: statusColor.withValues(alpha: 0.3)),
            ),
            child: Icon(
              isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
              size: 18,
              color: statusColor,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppThemeTokens>();
    final themeProvider = context.watch<ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 1024;
    final isDark = themeProvider.isDark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Animated Background
          AnimatedBackground(isDark: isDark),
          // Rest of the UI
          Column(
            children: [
              Padding(
                padding: EdgeInsets.fromLTRB(
                  12,
                  MediaQuery.of(context).padding.top + 8,
                  12,
                  8,
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
                    child: Container(
                      decoration: BoxDecoration(
                        color: theme.cardColor.withValues(alpha: 0.78),
                        border: Border.all(
                          color: theme.dividerColor.withValues(alpha: 0.32),
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: AppBar(
                        toolbarHeight: 66,
                        backgroundColor: Colors.transparent,
                        elevation: 0,
                        automaticallyImplyLeading: false,
                        leadingWidth: isMobile ? 56 : 8,
                        leading: isMobile
                            ? IconButton.filledTonal(
                                onPressed: _toggleSidebar,
                                icon: Icon(
                                  _sidebarOpen ? Icons.close : Icons.menu,
                                ),
                              )
                            : const SizedBox.shrink(),
                        titleSpacing: isMobile ? 4 : 16,
                        title: _buildTopBarTitle(theme, localeProvider, isMobile),
                        actions: [
                          Padding(
                            padding: const EdgeInsets.only(right: 6),
                            child: _buildConnectivityButton(tokens),
                          ),
                          const Padding(
                            padding: EdgeInsets.only(right: 6),
                            child: SyncStatusWidget(compact: true),
                          ),
                          PopupMenuButton<String>(
                            color: theme.cardColor.withValues(alpha: 0.95),
                            elevation: 10,
                            shadowColor: theme.shadowColor.withValues(alpha: 0.3),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: theme.dividerColor.withValues(alpha: 0.2),
                              ),
                            ),
                            onSelected: (value) {
                              if (value == 'profile') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const ProfilePage(),
                                  ),
                                );
                              } else if (value == 'settings') {
                                Navigator.of(context).push(
                                  MaterialPageRoute(
                                    builder: (context) => const SettingsPage(),
                                  ),
                                );
                              } else if (value == 'logout') {
                                context.read<AuthProvider>().signOut();
                              }
                            },
                            itemBuilder: (context) => [
                              PopupMenuItem(
                                value: 'profile',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.person,
                                      color: theme.colorScheme.onSurfaceVariant,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(localeProvider.translate('profile')),
                                  ],
                                ),
                              ),
                              PopupMenuItem(
                                value: 'settings',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.settings,
                                      color: theme.colorScheme.onSurfaceVariant,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(localeProvider.translate('settings')),
                                  ],
                                ),
                              ),
                              const PopupMenuDivider(),
                              PopupMenuItem(
                                value: 'logout',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.logout,
                                      color: theme.colorScheme.error,
                                      size: 20,
                                    ),
                                    const SizedBox(width: 12),
                                    Text(
                                      localeProvider.translate('auth.sign_out'),
                                      style: TextStyle(
                                        color: theme.colorScheme.error,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                            icon: Container(
                              width: 36,
                              height: 36,
                              decoration: BoxDecoration(
                                color: theme.colorScheme.surface.withValues(
                                  alpha: 0.45,
                                ),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: theme.dividerColor.withValues(alpha: 0.18),
                                ),
                              ),
                              child: Icon(
                                Icons.more_horiz,
                                color: theme.colorScheme.onSurface,
                                size: 18,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              // Body
              Expanded(
                child: Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
                      child: Row(
                        children: [
                          if (!isMobile && _sidebarOpen) ...[
                            Sidebar(
                              selectedIndex: _selectedIndex,
                              onItemSelected: _onItemSelected,
                            ),
                            const SizedBox(width: 12),
                          ],
                          Expanded(
                            child: DashboardContent(
                              selectedIndex: _selectedIndex,
                              onNavigate: _onItemSelected,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Mobile sidebar overlay
                    if (isMobile && _sidebarOpen)
                      Sidebar(
                        selectedIndex: _selectedIndex,
                        onItemSelected: _onItemSelected,
                        isOpen: _sidebarOpen,
                        onToggle: (bool value) => _toggleSidebar(),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _getPageTitle(LocaleProvider localeProvider) {
    switch (_selectedIndex) {
      case 0:
        return localeProvider.translate('nav.dashboardTitle');
      case 1:
        return localeProvider.translate('nav.applications');
      case 2:
        return localeProvider.translate('nav.beneficiaries');
      case 3:
        return localeProvider.translate('nav.disbursements');
      case 4:
        return localeProvider.translate('nav.reports');
      case 5:
        return localeProvider.translate('nav.grievance');
      case 6:
        return localeProvider.translate('nav.feedback');
      default:
        return localeProvider.translate('nav.dashboardTitle');
    }
  }
}

