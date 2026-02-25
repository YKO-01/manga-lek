import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../services/manga_service.dart';
import '../../models/category.dart';
import '../../core/navigation/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/manga_card.dart';
import '../../widgets/genre_chip.dart';
import '../../widgets/section_header.dart';

class ExploreScreen extends StatefulWidget {
  const ExploreScreen({super.key});

  @override
  State<ExploreScreen> createState() => _ExploreScreenState();
}

class _ExploreScreenState extends State<ExploreScreen> {
  String? _selectedGenre;
  Category? _selectedCategory; // Changed to Category object
  String _sortBy = 'title'; // title, rating, chapters

  // Manga type categories (Manga, Manhwa, Manhua)
  final List<Category> _typeCategories = const [
    Category(
      id: 'manga',
      name: 'Manga',
      icon: '🇯🇵',
      mangaCount: 0,
      filterType: 'type',
      filterValue: 'Manga',
    ),
    Category(
      id: 'manhwa',
      name: 'Manhwa',
      icon: '🇰🇷',
      mangaCount: 0,
      filterType: 'type',
      filterValue: 'Manhwa',
    ),
    Category(
      id: 'manhua',
      name: 'Manhua',
      icon: '🇨🇳',
      mangaCount: 0,
      filterType: 'type',
      filterValue: 'Manhua',
    ),
  ];

  // Get all unique genres from manga data
  List<String> _getUniqueGenres(MangaService mangaService) {
    final Set<String> genres = {'All'};
    for (final manga in mangaService.allMangas) {
      genres.addAll(manga.genres);
    }
    return genres.toList()..sort((a, b) {
      if (a == 'All') return -1;
      if (b == 'All') return 1;
      return a.compareTo(b);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<MangaService>(
          builder: (context, mangaService, child) {
            // Get unique genres from actual data
            final genres = _getUniqueGenres(mangaService);

            // Filter mangas
            var filteredMangas = mangaService.allMangas.toList();

            // Filter by category (type or status based)
            if (_selectedCategory != null &&
                _selectedCategory!.filterType != 'all') {
              final filterType = _selectedCategory!.filterType;
              final filterValue = _selectedCategory!.filterValue;

              if (filterType == 'type' && filterValue != null) {
                // Filter by manga type (Manhwa, Manhua, Manga)
                filteredMangas = filteredMangas
                    .where(
                      (m) => m.type?.toLowerCase() == filterValue.toLowerCase(),
                    )
                    .toList();
              } else if (filterType == 'status' && filterValue != null) {
                // Filter by status (Ongoing, Completed)
                filteredMangas = filteredMangas
                    .where(
                      (m) =>
                          m.status.toLowerCase() == filterValue.toLowerCase(),
                    )
                    .toList();
              }
            }

            // Filter by genre
            if (_selectedGenre != null && _selectedGenre != 'All') {
              filteredMangas = filteredMangas
                  .where((m) => m.genres.contains(_selectedGenre))
                  .toList();
            }

            // Sort
            switch (_sortBy) {
              case 'rating':
                filteredMangas = List.from(filteredMangas)
                  ..sort((a, b) => b.rating.compareTo(a.rating));
                break;
              case 'chapters':
                filteredMangas = List.from(filteredMangas)
                  ..sort((a, b) => b.chapterCount.compareTo(a.chapterCount));
                break;
              case 'title':
              default:
                filteredMangas = List.from(filteredMangas)
                  ..sort((a, b) => a.title.compareTo(b.title));
            }

            return CustomScrollView(
              slivers: [
                // Header with sort button
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        Text(
                          'Explore',
                          style: Theme.of(context).textTheme.displaySmall,
                        ),
                        const Spacer(),
                        PopupMenuButton<String>(
                          icon: const Icon(Icons.sort),
                          onSelected: (value) {
                            setState(() {
                              _sortBy = value;
                            });
                          },
                          itemBuilder: (context) => [
                            PopupMenuItem(
                              value: 'title',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.sort_by_alpha,
                                    color: _sortBy == 'title'
                                        ? AppColors.primary
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('By Title'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'rating',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.star,
                                    color: _sortBy == 'rating'
                                        ? AppColors.primary
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('By Rating'),
                                ],
                              ),
                            ),
                            PopupMenuItem(
                              value: 'chapters',
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.book,
                                    color: _sortBy == 'chapters'
                                        ? AppColors.primary
                                        : null,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('By Chapters'),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                // Categories (Manga Types)
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SectionHeader(title: 'Categories'),
                      SizedBox(
                        height: 90,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: _typeCategories.length,
                          itemBuilder: (context, index) {
                            final category = _typeCategories[index];
                            final isSelected =
                                _selectedCategory?.id == category.id;
                            // Count manga of this type
                            final count = mangaService.allMangas
                                .where(
                                  (m) =>
                                      m.type?.toLowerCase() ==
                                      category.filterValue?.toLowerCase(),
                                )
                                .length;
                            return _buildCategoryCard(
                              category.name,
                              category.icon,
                              count,
                              isSelected,
                              () {
                                setState(() {
                                  if (isSelected) {
                                    _selectedCategory = null;
                                  } else {
                                    _selectedCategory = category;
                                    _selectedGenre = null; // Reset genre filter
                                  }
                                });
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Genre Filter
                SliverToBoxAdapter(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Row(
                          children: [
                            const Text(
                              'Filter by Genre',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const Spacer(),
                            if (_selectedGenre != null ||
                                _selectedCategory != null)
                              TextButton(
                                onPressed: () {
                                  setState(() {
                                    _selectedGenre = null;
                                    _selectedCategory = null;
                                  });
                                },
                                child: const Text('Clear All'),
                              ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      SizedBox(
                        height: 50,
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          scrollDirection: Axis.horizontal,
                          itemCount: genres.length,
                          itemBuilder: (context, index) {
                            final genre = genres[index];
                            final isSelected =
                                _selectedGenre == genre ||
                                (_selectedGenre == null &&
                                    _selectedCategory == null &&
                                    genre == 'All');
                            return Padding(
                              padding: const EdgeInsets.only(right: 8),
                              child: GenreChip(
                                genre: genre,
                                isSelected: isSelected,
                                onTap: () {
                                  setState(() {
                                    _selectedGenre = genre == 'All'
                                        ? null
                                        : genre;
                                    _selectedCategory =
                                        null; // Reset category filter
                                  });
                                },
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                // Results count
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      '${filteredMangas.length} manga found',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ),
                ),
                // Empty state
                if (filteredMangas.isEmpty)
                  SliverToBoxAdapter(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.search_off,
                              size: 64,
                              color: AppColors.textTertiaryDark,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'No manga found',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Try a different filter',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                            const SizedBox(height: 16),
                            ElevatedButton(
                              onPressed: () {
                                setState(() {
                                  _selectedGenre = null;
                                  _selectedCategory = null;
                                });
                              },
                              child: const Text('Clear Filters'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                // Manga Grid
                if (filteredMangas.isNotEmpty)
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    sliver: SliverGrid(
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisSpacing: 16,
                            crossAxisSpacing: 12,
                            childAspectRatio: 0.55,
                          ),
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final manga = filteredMangas[index];
                        return MangaCard(
                          manga: manga,
                          width: double.infinity,
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRouter.mangaDetail,
                              arguments: manga,
                            );
                          },
                        );
                      }, childCount: filteredMangas.length),
                    ),
                  ),
                // Bottom Padding
                const SliverToBoxAdapter(child: SizedBox(height: 100)),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildCategoryCard(
    String name,
    String iconName,
    int count,
    bool isSelected,
    VoidCallback onTap,
  ) {
    // Check if iconName is an emoji (starts with unicode flag or special char)
    final isEmoji =
        iconName.contains(
          RegExp(r'[\u{1F1E0}-\u{1F1FF}]|[\u{1F300}-\u{1F9FF}]', unicode: true),
        ) ||
        iconName.length <= 4 && !iconName.contains(RegExp(r'[a-zA-Z]'));

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 100,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primary : AppColors.cardDark,
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? null
              : Border.all(color: AppColors.surfaceDark, width: 1),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (isEmoji)
              Text(iconName, style: const TextStyle(fontSize: 28))
            else
              Icon(
                _getIconData(iconName),
                color: isSelected ? Colors.white : AppColors.primary,
                size: 28,
              ),
            const SizedBox(height: 4),
            Text(
              name,
              style: TextStyle(
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                color: isSelected ? Colors.white : AppColors.textPrimaryDark,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            Text(
              '$count',
              style: TextStyle(
                fontSize: 10,
                color: isSelected
                    ? Colors.white.withOpacity(0.8)
                    : AppColors.textTertiaryDark,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'bolt':
        return Icons.bolt;
      case 'explore':
        return Icons.explore;
      case 'mood':
        return Icons.mood;
      case 'theater_comedy':
        return Icons.theater_comedy;
      case 'auto_awesome':
        return Icons.auto_awesome;
      case 'visibility_off':
        return Icons.visibility_off;
      case 'search':
        return Icons.search;
      case 'favorite':
        return Icons.favorite;
      case 'rocket_launch':
        return Icons.rocket_launch;
      case 'stars':
        return Icons.stars;
      case 'public':
        return Icons.public;
      case 'history':
        return Icons.history;
      case 'psychology':
        return Icons.psychology;
      case 'warning':
        return Icons.warning;
      case 'sports_martial_arts':
        return Icons.sports_martial_arts;
      case 'school':
        return Icons.school;
      case 'boy':
        return Icons.boy;
      case 'man':
        return Icons.man;
      case 'home':
        return Icons.home;
      default:
        return Icons.category;
    }
  }
}
