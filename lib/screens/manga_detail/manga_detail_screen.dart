import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:manga_lek/const.dart';
import 'package:provider/provider.dart';
import '../../models/manga.dart';
import '../../models/chapter.dart';
import '../../services/manga_service.dart';
import '../../core/navigation/app_router.dart';
import '../../core/theme/app_colors.dart';

class MangaDetailScreen extends StatefulWidget {
  final Manga manga;

  const MangaDetailScreen({super.key, required this.manga});

  @override
  State<MangaDetailScreen> createState() => _MangaDetailScreenState();
}

class _MangaDetailScreenState extends State<MangaDetailScreen> {
  bool _isDescriptionExpanded = false;

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'manhwa':
        return const Color(0xFF2196F3); // Blue
      case 'manhua':
        return const Color(0xFF9C27B0); // Purple
      case 'manga':
        return const Color(0xFFFF9800); // Orange
      case 'comic':
        return const Color(0xFFE91E63); // Pink
      default:
        return AppColors.primary;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Consumer<MangaService>(
        builder: (context, mangaService, child) {
          final chapters = mangaService.getChaptersForManga(widget.manga.id);
          final isFavorite = mangaService.isFavorite(widget.manga.id);

          return CustomScrollView(
            slivers: [
              // App Bar with Cover Image
              _buildSliverAppBar(context, isFavorite, mangaService),
              // Content
              SliverToBoxAdapter(
                child: _buildContent(context, chapters, mangaService),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildSliverAppBar(
    BuildContext context,
    bool isFavorite,
    MangaService mangaService,
  ) {
    return SliverAppBar(
      expandedHeight: 350,
      pinned: true,
      backgroundColor: AppColors.backgroundDark,
      leading: IconButton(
        icon: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.5),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        IconButton(
          icon: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: isFavorite ? AppColors.error : Colors.white,
            ),
          ),
          onPressed: () => mangaService.toggleFavorite(widget.manga.id),
        ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Background Image
            CachedNetworkImage(
              imageUrl: widget.manga.coverImage,
              fit: BoxFit.cover,
              errorWidget: (context, url, error) => Container(
                color: AppColors.surfaceDark,
              ),
            ),
            // Gradient Overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AppColors.backgroundDark.withOpacity(0.8),
                    AppColors.backgroundDark,
                  ],
                  stops: const [0.0, 0.7, 1.0],
                ),
              ),
            ),
            // Title at bottom
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Status and Type Badges
                  Row(
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: widget.manga.status == 'Ongoing'
                              ? AppColors.success
                              : AppColors.info,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          widget.manga.status,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      // Type Badge
                      if (widget.manga.type != null && widget.manga.type!.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: _getTypeColor(widget.manga.type!),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            widget.manga.type!,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    widget.manga.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Type and Status
                  Text(
                    '${widget.manga.type ?? 'Manga'} • ${widget.manga.status}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(
    BuildContext context,
    List<Chapter> chapters,
    MangaService mangaService,
  ) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Stats Row
          _buildStatsRow(chapters.length),
          const SizedBox(height: 24),
          // Genres
          _buildGenres(),
          const SizedBox(height: 24),
          // Description
          _buildDescription(context),
          const SizedBox(height: 24),
          // Action Buttons
          _buildActionButtons(context, chapters, mangaService),
          const SizedBox(height: 24),
          // Chapters List
          _buildChaptersList(context, chapters, mangaService),
          const SizedBox(height: 100),
        ],
      ),
    );
  }

  Widget _buildStatsRow(int chapterCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            Icons.star,
            widget.manga.rating.toStringAsFixed(1),
            'Rating',
            AppColors.warning,
          ),
          _buildDivider(),
          _buildStatItem(
            Icons.book,
            '$chapterCount',
            'Chapters',
            AppColors.info,
          ),
          _buildDivider(),
          _buildStatItem(
            Icons.visibility,
            '1.2M',
            'Views',
            AppColors.success,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(IconData icon, String value, String label, Color color) {
    return Column(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: color,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textTertiaryDark,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(
      width: 1,
      height: 50,
      color: AppColors.surfaceDark,
    );
  }

  Widget _buildGenres() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.manga.genres.map((genre) {
        final color = AppColors.getGenreColor(genre);
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withOpacity(0.2),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color, width: 1),
          ),
          child: Text(
            genre,
            style: TextStyle(
              color: color,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Synopsis',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () {
            setState(() {
              _isDescriptionExpanded = !_isDescriptionExpanded;
            });
          },
          child: AnimatedCrossFade(
            firstChild: Text(
              widget.manga.description,
              style: Theme.of(context).textTheme.bodyMedium,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
            secondChild: Text(
              widget.manga.description,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            crossFadeState: _isDescriptionExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 200),
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () {
            setState(() {
              _isDescriptionExpanded = !_isDescriptionExpanded;
            });
          },
          child: Text(
            _isDescriptionExpanded ? 'Show less' : 'Read more',
            style: const TextStyle(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(
    BuildContext context,
    List<Chapter> chapters,
    MangaService mangaService,
  ) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            onPressed: chapters.isNotEmpty
                ? () {
                    gAds.rewardInstance.showRewardAd(() {
                      Navigator.pushNamed(
                        context,
                        AppRouter.reader,
                        arguments: {
                          'chapter': chapters.first,
                          'manga': widget.manga,
                        },
                      );
                    });
                  }
                : null,
            icon: const Icon(Icons.play_arrow),
            label: const Text('Start Reading'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChaptersList(
    BuildContext context,
    List<Chapter> chapters,
    MangaService mangaService,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Chapters',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            Text(
              '${chapters.length} chapters',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (chapters.isEmpty)
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  const Icon(
                    Icons.book_outlined,
                    size: 48,
                    color: AppColors.textTertiaryDark,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No chapters available',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          )
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: chapters.length,
            itemBuilder: (context, index) {
              final chapter = chapters[index];
              return _buildChapterTile(context, chapter, mangaService);
            },
          ),
      ],
    );
  }

  Widget _buildChapterTile(
    BuildContext context,
    Chapter chapter,
    MangaService mangaService,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: AppColors.cardDark,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        onTap: () {
          gAds.rewardInstance.showRewardAd(() {
            Navigator.pushNamed(
              context,
              AppRouter.reader,
              arguments: {
                'chapter': chapter,
                'manga': widget.manga,
              },
            );
          });
        },
        leading: Container(
          width: 45,
          height: 45,
          decoration: BoxDecoration(
            color: chapter.isRead
                ? AppColors.success.withOpacity(0.2)
                : AppColors.primary.withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Center(
            child: Text(
              '${chapter.number}',
              style: TextStyle(
                color: chapter.isRead ? AppColors.success : AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        title: Text(
          chapter.title,
          style: TextStyle(
            color: chapter.isRead
                ? AppColors.textTertiaryDark
                : AppColors.textPrimaryDark,
            fontWeight: FontWeight.w500,
          ),
        ),
        subtitle: Text(
          _formatDate(chapter.releaseDate),
          style: const TextStyle(
            color: AppColors.textTertiaryDark,
            fontSize: 12,
          ),
        ),
        trailing: chapter.isRead
            ? const Icon(Icons.check_circle, color: AppColors.success)
            : const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textTertiaryDark,
              ),
      ),
    );
  }

  String _formatDate(String dateString) {
    // releaseDate is now a String from the JSON, display it directly
    if (dateString.isEmpty) return '';
    return dateString;
  }
}
