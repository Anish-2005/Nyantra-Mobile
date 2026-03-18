import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/providers/sync_status_provider.dart';
import '../../../core/theme/app_theme.dart';

class SyncStatusWidget extends StatelessWidget {
  const SyncStatusWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tokens = theme.extension<AppThemeTokens>();

    return Consumer<SyncStatusProvider?>(
      builder: (context, syncProvider, child) {
        if (syncProvider == null) {
          return const SizedBox.shrink();
        }

        final statusColor = syncProvider.getStatusColor();

        return InkWell(
          onTap: syncProvider.status == SyncStatus.error
              ? () => _showErrorDialog(context, syncProvider)
              : syncProvider.hasPendingSync
              ? () => _triggerManualSync(context)
              : null,
          borderRadius: BorderRadius.circular(999),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(999),
              border: Border.all(
                color: statusColor.withValues(alpha: 0.35),
                width: 1,
              ),
              boxShadow: [
                BoxShadow(
                  color: (tokens?.shadowSoft ?? Colors.black12).withValues(
                    alpha: 0.18,
                  ),
                  blurRadius: 10,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  syncProvider.getStatusIcon(),
                  size: 14,
                  color: statusColor,
                ),
                const SizedBox(width: 6),
                Text(
                  syncProvider.getStatusText(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (syncProvider.status == SyncStatus.syncing)
                  Padding(
                    padding: const EdgeInsets.only(left: 6),
                    child: SizedBox(
                      width: 12,
                      height: 12,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showErrorDialog(BuildContext context, SyncStatusProvider syncProvider) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Error'),
        content: Text(syncProvider.lastError ?? 'Unknown error occurred'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Dismiss'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _triggerManualSync(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
              foregroundColor: theme.colorScheme.onPrimary,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  void _triggerManualSync(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Manual sync triggered')),
    );
  }
}
