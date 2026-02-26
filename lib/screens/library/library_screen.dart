import 'package:flutter/material.dart';
import 'package:manga_lek/const.dart';
import 'package:provider/provider.dart';
import '../../services/manga_service.dart';
import '../../core/navigation/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/manga_list_tile.dart';

class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                'Library',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ),
            // Tabs
            TabBar(
              controller: _tabController,
              indicatorColor: AppColors.primary,
              labelColor: AppColors.primary,
              unselectedLabelColor: AppColors.textSecondaryDark,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(text: 'Favorites'),
                Tab(text: 'Reading'),
                Tab(text: 'Completed'),
              ],
            ),
            // Tab Views
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildFavoritesTab(),
                  _buildReadingTab(),
                  _buildCompletedTab(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFavoritesTab() {
    return Consumer<MangaService>(
      builder: (context, mangaService, child) {
        final favorites = mangaService.favoriteMangas;
        
        if (favorites.isEmpty) {
          return _buildEmptyState(
            Icons.favorite_border,
            'No favorites yet',
            'Add manga to your favorites to see them here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: favorites.length,
          itemBuilder: (context, index) {
            final manga = favorites[index];
            return MangaListTile(
              manga: manga,
              trailing: IconButton(
                icon: const Icon(
                  Icons.favorite,
                  color: AppColors.error,
                ),
                onPressed: () {
                  mangaService.toggleFavorite(manga.id);
                },
              ),
              onTap: () {
                gAds.rewardInstance.showRewardAd(() {
                  Navigator.pushNamed(
                    context,
                    AppRouter.mangaDetail,
                    arguments: manga,
                  );
                });
              },
            );
          },
        );
      },
    );
  }

  Widget _buildReadingTab() {
    return Consumer<MangaService>(
      builder: (context, mangaService, child) {
        final reading = mangaService.recentlyReadMangas;
        
        if (reading.isEmpty) {
          return _buildEmptyState(
            Icons.menu_book_outlined,
            'Nothing in progress',
            'Start reading manga to track your progress',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: reading.length,
          itemBuilder: (context, index) {
            final manga = reading[index];
            return MangaListTile(
              manga: manga,
              trailing: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Ch. ${manga.lastReadChapter ?? 0}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  SizedBox(
                    width: 50,
                    child: LinearProgressIndicator(
                      value: mangaService.getReadingProgress(manga.id),
                      backgroundColor: AppColors.surfaceDark,
                      valueColor: const AlwaysStoppedAnimation(AppColors.primary),
                    ),
                  ),
                ],
              ),
              onTap: () {
                gAds.rewardInstance.showRewardAd(() {
                  Navigator.pushNamed(
                    context,
                    AppRouter.mangaDetail,
                    arguments: manga,
                  );
                });
              },
            );
          },
        );
      },
    );
  }

  Widget _buildCompletedTab() {
    return Consumer<MangaService>(
      builder: (context, mangaService, child) {
        final completed = mangaService.allMangas
            .where((m) => mangaService.getReadingProgress(m.id) == 1.0)
            .toList();
        
        if (completed.isEmpty) {
          return _buildEmptyState(
            Icons.check_circle_outline,
            'No completed manga',
            'Complete reading manga to see them here',
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: completed.length,
          itemBuilder: (context, index) {
            final manga = completed[index];
            return MangaListTile(
              manga: manga,
              trailing: const Icon(
                Icons.check_circle,
                color: AppColors.success,
              ),
              onTap: () {
                gAds.rewardInstance.showRewardAd(() { 
                  Navigator.pushNamed(
                    context,
                    AppRouter.mangaDetail,
                    arguments: manga,
                  );
                });
              },
            );
          },
        );
      },
    );
  }

  Widget _buildEmptyState(IconData icon, String title, String subtitle) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 80,
            color: AppColors.textTertiaryDark,
          ),
          const SizedBox(height: 16),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
