import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../../core/providers/auth_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/theme/app_theme.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppThemeTokens>();
    final authProvider = context.watch<AuthProvider>();
    final localeProvider = context.watch<LocaleProvider>();
    final user = authProvider.user;
    final hasUid = (user?.uid ?? '').trim().isNotEmpty;
    final hasEmail = (user?.email ?? '').trim().isNotEmpty;
    final hasPhone = (user?.phoneNumber ?? '').trim().isNotEmpty;

    final displayName = (user?.displayName ?? '').trim().isNotEmpty
        ? user!.displayName!.trim()
        : localeProvider.translate('profilePage.defaultName');
    final email = hasEmail
        ? user!.email!.trim()
        : localeProvider.translate('profilePage.noEmail');
    final phone = hasPhone
        ? user!.phoneNumber!.trim()
        : localeProvider.translate('profilePage.noPhone');
    final uid = hasUid
        ? user!.uid
        : localeProvider.translate('profilePage.notAvailable');

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(localeProvider.translate('profilePage.title')),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient:
                      tokens?.brandGradient ??
                      const LinearGradient(
                        colors: [Color(0xFF0EA5E9), Color(0xFF7DD3FC)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      child: Text(
                        _avatarLabel(displayName),
                        style: theme.textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            displayName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            email,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: Colors.white.withValues(alpha: 0.9),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: localeProvider.translate('profilePage.accountDetails'),
                children: [
                  _InfoRow(
                    label: localeProvider.translate('profilePage.labels.userId'),
                    value: uid,
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: OutlinedButton.icon(
                      onPressed: () async {
                        if (!hasUid) {
                          return;
                        }
                        await Clipboard.setData(ClipboardData(text: uid));
                        if (!context.mounted) {
                          return;
                        }
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              localeProvider.translate(
                                'profilePage.userIdCopied',
                              ),
                            ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.copy_rounded, size: 16),
                      label: Text(
                        localeProvider.translate('profilePage.copyUserId'),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: localeProvider.translate('profilePage.labels.email'),
                    value: email,
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: localeProvider.translate('profilePage.labels.phone'),
                    value: phone,
                  ),
                ],
              ),
              const SizedBox(height: 16),
              _SectionCard(
                title: localeProvider.translate('profilePage.securityAccess'),
                children: [
                  _InfoRow(
                    label: localeProvider.translate('profilePage.labels.joined'),
                    value: _formatDate(
                      user?.metadata.creationTime,
                      localeProvider,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: localeProvider.translate(
                      'profilePage.labels.lastSignIn',
                    ),
                    value: _formatDate(
                      user?.metadata.lastSignInTime,
                      localeProvider,
                    ),
                  ),
                  const SizedBox(height: 8),
                  _InfoRow(
                    label: localeProvider.translate(
                      'profilePage.labels.provider',
                    ),
                    value: _providerName(user?.providerData, localeProvider),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    await context.read<AuthProvider>().signOut();
                    if (context.mounted) {
                      Navigator.of(context).maybePop();
                    }
                  },
                  icon: const Icon(Icons.logout_rounded),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: theme.colorScheme.errorContainer,
                    foregroundColor: theme.colorScheme.onErrorContainer,
                  ),
                  label: Text(localeProvider.translate('auth.sign_out')),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _avatarLabel(String displayName) {
    final trimmed = displayName.trim();
    if (trimmed.isEmpty) {
      return 'U';
    }
    return trimmed.substring(0, 1).toUpperCase();
  }

  String _formatDate(DateTime? dateTime, LocaleProvider localeProvider) {
    if (dateTime == null) {
      return localeProvider.translate('profilePage.notAvailable');
    }
    return '${dateTime.day.toString().padLeft(2, '0')}/'
        '${dateTime.month.toString().padLeft(2, '0')}/'
        '${dateTime.year}';
  }

  String _providerName(
    List<dynamic>? providerData,
    LocaleProvider localeProvider,
  ) {
    if (providerData == null || providerData.isEmpty) {
      return localeProvider.translate('profilePage.provider.unknown');
    }
    final raw = providerData.first.toString().toLowerCase();
    if (raw.contains('google')) {
      return localeProvider.translate('profilePage.provider.google');
    }
    if (raw.contains('phone')) {
      return localeProvider.translate('profilePage.provider.phone');
    }
    if (raw.contains('password')) {
      return localeProvider.translate('profilePage.provider.emailPassword');
    }
    return localeProvider.translate('profilePage.provider.connected');
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SectionCard({required this.title, required this.children});

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
          const SizedBox(height: 12),
          ...children,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;

  const _InfoRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 110,
          child: Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
