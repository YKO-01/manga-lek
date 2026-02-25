import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/theme_provider.dart';
import '../../services/manga_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mangaService = Provider.of<MangaService>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Statistics Section
          _buildSectionHeader(context, 'Statistics'),
          _buildSettingsCard(
            context,
            children: [
              _buildStatTile(
                icon: Icons.menu_book,
                title: 'Total Manga',
                value: '${mangaService.allMangas.length}',
              ),
              const Divider(height: 1),
              _buildStatTile(
                icon: Icons.library_books,
                title: 'Total Chapters',
                value: '${mangaService.allChapters.length}',
              ),
              const Divider(height: 1),
              _buildStatTile(
                icon: Icons.favorite,
                title: 'Favorites',
                value: '${mangaService.favoriteMangas.length}',
              ),
              const Divider(height: 1),
              _buildStatTile(
                icon: Icons.category,
                title: 'Categories',
                value: '${mangaService.categories.length}',
              ),
            ],
          ),
          const SizedBox(height: 24),
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
          _buildSettingsCard(
            context,
            children: [
              _buildSwitchTile(
                icon: Icons.swap_vert,
                title: 'Default Vertical Mode',
                subtitle: 'Open reader in vertical scroll mode',
                value: true,
                onChanged: (_) {},
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.visibility,
                title: 'Keep Screen On',
                subtitle: 'Prevent screen from turning off while reading',
                value: true,
                onChanged: (_) {},
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Downloads Section
          _buildSectionHeader(context, 'Downloads'),
          _buildSettingsCard(
            context,
            children: [
              _buildNavigationTile(
                icon: Icons.folder,
                title: 'Download Location',
                subtitle: 'Internal Storage',
                onTap: () {},
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.wifi,
                title: 'Download Only on Wi-Fi',
                subtitle: 'Save mobile data',
                value: true,
                onChanged: (_) {},
              ),
              const Divider(height: 1),
              _buildNavigationTile(
                icon: Icons.delete_outline,
                title: 'Clear Download Cache',
                subtitle: '0 MB used',
                onTap: () => _showClearCacheDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Notifications Section
          _buildSectionHeader(context, 'Notifications'),
          _buildSettingsCard(
            context,
            children: [
              _buildSwitchTile(
                icon: Icons.notifications,
                title: 'Push Notifications',
                subtitle: 'Get notified about new chapters',
                value: true,
                onChanged: (_) {},
              ),
              const Divider(height: 1),
              _buildSwitchTile(
                icon: Icons.new_releases,
                title: 'New Release Alerts',
                subtitle: 'Notify when favorited manga updates',
                value: true,
                onChanged: (_) {},
              ),
            ],
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

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.primary,
            ),
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

  Widget _buildStatTile({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.primary,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
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
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  void _showClearCacheDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: Theme.of(context).cardTheme.color,
        title: const Text('Clear Cache'),
        content: const Text(
          'Are you sure you want to clear the download cache? This will remove all downloaded manga.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Cache cleared successfully')),
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
