import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/manga_service.dart';
import '../../core/navigation/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/manga_list_tile.dart';

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorites'),
      ),
      body: Consumer<MangaService>(
        builder: (context, mangaService, child) {
          final favorites = mangaService.favoriteMangas;

          if (favorites.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.favorite_border,
                    size: 80,
                    color: AppColors.textTertiaryDark,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Add manga to your favorites to see them here',
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: favorites.length,
            itemBuilder: (context, index) {
              final manga = favorites[index];
              return Dismissible(
                key: Key(manga.id),
                direction: DismissDirection.endToStart,
                background: Container(
                  alignment: Alignment.centerRight,
                  padding: const EdgeInsets.only(right: 20),
                  decoration: BoxDecoration(
                    color: AppColors.error,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.delete,
                    color: Colors.white,
                  ),
                ),
                onDismissed: (_) {
                  mangaService.toggleFavorite(manga.id);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('${manga.title} removed from favorites'),
                      action: SnackBarAction(
                        label: 'Undo',
                        onPressed: () {
                          mangaService.toggleFavorite(manga.id);
                        },
                      ),
                    ),
                  );
                },
                child: MangaListTile(
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
                    Navigator.pushNamed(
                      context,
                      AppRouter.mangaDetail,
                      arguments: manga,
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
