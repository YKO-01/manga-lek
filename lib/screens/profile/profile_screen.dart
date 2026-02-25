import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../core/settings/settings_provider.dart';
import '../../services/manga_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Settings'), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Appearance Section
          _buildSectionHeader(context, 'Appearance'),
          _buildSettingsCard(
            context,
            children: [
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return _buildSwitchTile(
                    icon: Icons.dark_mode,
                    title: 'Dark Mode',
                    subtitle: 'Switch between light and dark theme',
                    value: themeProvider.isDarkMode,
                    onChanged: (_) => themeProvider.toggleTheme(),
                  );
                },
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Reading Section
          _buildSectionHeader(context, 'Reading'),
          Consumer<SettingsProvider>(
            builder: (context, settings, child) {
              return _buildSettingsCard(
                context,
                children: [
                  _buildSwitchTile(
                    icon: Icons.swap_vert,
                    title: 'Default Vertical Mode',
                    subtitle: 'Open reader in vertical scroll mode',
                    value: settings.defaultVerticalMode,
                    onChanged: (value) =>
                        settings.setDefaultVerticalMode(value),
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    icon: Icons.visibility,
                    title: 'Keep Screen On',
                    subtitle: 'Prevent screen from turning off while reading',
                    value: settings.keepScreenOn,
                    onChanged: (value) => settings.setKeepScreenOn(value),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // Data Section
          _buildSectionHeader(context, 'Data'),
          _buildSettingsCard(
            context,
            children: [
              _buildNavigationTile(
                icon: Icons.cloud_download_outlined,
                title: 'Refresh Manga Data',
                subtitle: 'Fetch latest manga and chapters',
                onTap: () => _showRefreshDataDialog(context),
              ),
              const Divider(height: 1),
              _buildNavigationTile(
                icon: Icons.history,
                title: 'Clear Reading History',
                onTap: () => _showClearHistoryDialog(context),
              ),
              const Divider(height: 1),
              _buildNavigationTile(
                icon: Icons.favorite_border,
                title: 'Clear Favorites',
                onTap: () => _showClearFavoritesDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // Statistics Section
          _buildSectionHeader(context, 'Statistics'),
          Consumer<MangaService>(
            builder: (context, mangaService, child) {
              final chaptersRead = mangaService.allChapters
                  .where((c) => c.isRead)
                  .length;
              final mangaRead = mangaService.recentlyReadMangas.length;
              return Row(
                children: [
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.menu_book,
                      title: 'Manga Read',
                      value: '$mangaRead',
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _buildStatCard(
                      context,
                      icon: Icons.auto_stories,
                      title: 'Chapters Read',
                      value: '$chaptersRead',
                      color: Colors.purple,
                    ),
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 24),

          // About Section
          _buildSectionHeader(context, 'About'),
          _buildSettingsCard(
            context,
            children: [
              _buildNavigationTile(
                icon: Icons.info_outline,
                title: 'App Version',
                subtitle: '1.0.0',
                onTap: () {},
              ),
            ],
          ),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3), width: 1),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 12),
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 14,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: Theme.of(
          context,
        ).textTheme.titleLarge?.copyWith(color: AppColors.primary),
      ),
    );
  }

  Widget _buildSettingsCard(
    BuildContext context, {
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: children),
    );
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondaryDark),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: Switch(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primary,
      ),
      onTap: () => onChanged(!value),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textSecondaryDark),
      title: Text(title),
      subtitle: subtitle != null ? Text(subtitle) : null,
      trailing: const Icon(
        Icons.chevron_right,
        color: AppColors.textTertiaryDark,
      ),
      onTap: onTap,
    );
  }

  void _showRefreshDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Refresh Data'),
        content: const Text(
          'This will fetch the latest manga and chapter data. Continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final mangaService = Provider.of<MangaService>(
                context,
                listen: false,
              );
              await mangaService.loadData();
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data refreshed successfully')),
                );
              }
            },
            child: const Text('Refresh'),
          ),
        ],
      ),
    );
  }

  void _showClearHistoryDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear History'),
        content: const Text(
          'This will clear all your reading history and reset reading progress. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final mangaService = Provider.of<MangaService>(
                context,
                listen: false,
              );
              mangaService.clearReadingHistory();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Reading history cleared')),
              );
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }

  void _showClearFavoritesDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Clear Favorites'),
        content: const Text(
          'This will remove all manga from your favorites. Are you sure?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              final mangaService = Provider.of<MangaService>(
                context,
                listen: false,
              );
              mangaService.clearAllFavorites();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('All favorites cleared')),
              );
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: AppColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
