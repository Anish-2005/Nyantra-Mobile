import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/sync_status_provider.dart';
import '../../../core/providers/theme_provider.dart' as pref_theme;
import '../../../core/services/sync_service.dart';

class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _isSyncing = false;

  Future<void> _runSyncNow() async {
    if (_isSyncing) {
      return;
    }

    final syncProvider = context.read<SyncStatusProvider>();
    final localeProvider = context.read<LocaleProvider>();
    final syncService = SyncService(syncStatusProvider: syncProvider);

    setState(() => _isSyncing = true);
    syncProvider.setStatus(SyncStatus.syncing);

    try {
      final isOnline = await syncService.isOnline();
      if (!isOnline) {
        syncProvider.setStatus(
          SyncStatus.error,
          error: localeProvider.translate('settingsPage.sync.noInternetError'),
        );
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              localeProvider.translate('settingsPage.sync.offlineSnack'),
            ),
          ),
        );
        return;
      }

      await syncService.syncFromFirestore();
      syncProvider.setStatus(SyncStatus.success);
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localeProvider.translate('settingsPage.sync.successSnack'),
          ),
        ),
      );
    } catch (error) {
      syncProvider.setStatus(SyncStatus.error, error: error.toString());
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            localeProvider.translate(
              'settingsPage.sync.failedSnack',
              {'error': error.toString()},
            ),
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSyncing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final themeProvider = context.watch<pref_theme.ThemeProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final syncProvider = context.watch<SyncStatusProvider>();
    final t = localeProvider.translate;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(title: Text(t('settingsPage.title'))),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _SettingsSection(
                title: t('settingsPage.appearance.title'),
                subtitle: t('settingsPage.appearance.subtitle'),
                child: SwitchListTile.adaptive(
                  value: themeProvider.isDark,
                  onChanged: (value) {
                    themeProvider.setTheme(
                      value
                          ? pref_theme.AppTheme.dark
                          : pref_theme.AppTheme.light,
                    );
                  },
                  title: Text(
                    themeProvider.isDark
                        ? t('settingsPage.appearance.darkTheme')
                        : t('settingsPage.appearance.lightTheme'),
                  ),
                  subtitle: Text(t('settingsPage.appearance.applyInstantly')),
                  secondary: Icon(
                    themeProvider.isDark
                        ? Icons.dark_mode_rounded
                        : Icons.light_mode_rounded,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _SettingsSection(
                title: t('settingsPage.language.title'),
                subtitle: t('settingsPage.language.subtitle'),
                child: Wrap(
                  spacing: 10,
                  runSpacing: 10,
                  children: [
                    ChoiceChip(
                      label: Text(t('settingsPage.language.english')),
                      selected: localeProvider.locale == AppLocale.en,
                      onSelected: (_) => localeProvider.setLocale(AppLocale.en),
                    ),
                    ChoiceChip(
                      label: Text(t('settingsPage.language.hindi')),
                      selected: localeProvider.locale == AppLocale.hi,
                      onSelected: (_) => localeProvider.setLocale(AppLocale.hi),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingsSection(
                title: t('settingsPage.dataSync.title'),
                subtitle: t('settingsPage.dataSync.subtitle'),
                child: Column(
                  children: [
                    Row(
                      children: [
                        Icon(
                          syncProvider.getStatusIcon(),
                          size: 18,
                          color: syncProvider.getStatusColor(),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            syncProvider.getStatusText(),
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: syncProvider.getStatusColor(),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Text(
                          t('settingsPage.dataSync.lastSync'),
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            _formatSyncTime(
                              syncProvider.lastSyncTime,
                              t('settingsPage.dataSync.notSyncedYet'),
                            ),
                            style: theme.textTheme.bodySmall,
                            textAlign: TextAlign.right,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _isSyncing ? null : _runSyncNow,
                        icon: _isSyncing
                            ? const SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : const Icon(Icons.sync_rounded),
                        label: Text(
                          _isSyncing
                              ? t('settingsPage.dataSync.syncing')
                              : t('settingsPage.dataSync.syncNow'),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SettingsSection(
                title: t('settingsPage.session.title'),
                subtitle: t('settingsPage.session.subtitle'),
                child: SizedBox(
                  width: double.infinity,
                  child: OutlinedButton.icon(
                    onPressed: () async {
                      await context.read<AuthProvider>().signOut();
                      if (context.mounted) {
                        Navigator.of(context).maybePop();
                      }
                    },
                    icon: const Icon(Icons.logout_rounded),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: theme.colorScheme.error,
                      side: BorderSide(
                        color: theme.colorScheme.error.withValues(alpha: 0.35),
                      ),
                    ),
                    label: Text(t('auth.sign_out')),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _SettingsSection(
                title: t('settingsPage.about.title'),
                subtitle: t('settingsPage.about.subtitle'),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t('settingsPage.about.appName'),
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${t('settingsPage.about.version')} 1.0.0',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatSyncTime(DateTime? dateTime, String fallbackText) {
    if (dateTime == null) {
      return fallbackText;
    }
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:'
        '${dateTime.minute.toString().padLeft(2, '0')}';
  }
}

class _SettingsSection extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget child;

  const _SettingsSection({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.dividerColor.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}
