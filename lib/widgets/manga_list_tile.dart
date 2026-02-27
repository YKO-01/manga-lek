import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:shimmer/shimmer.dart';
import '../../models/manga.dart';
import '../../core/theme/app_colors.dart';

class MangaListTile extends StatelessWidget {
  final Manga manga;
  final VoidCallback? onTap;
  final Widget? trailing;

  const MangaListTile({
    super.key,
    required this.manga,
    this.onTap,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardTheme.color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Cover Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: manga.coverImage,
                width: 70,
                height: 100,
                fit: BoxFit.cover,
                placeholder: (context, url) => Shimmer.fromColors(
                  baseColor: AppColors.surfaceDark,
                  highlightColor: AppColors.cardDark,
                  child: Container(
                    width: 70,
                    height: 100,
                    color: AppColors.surfaceDark,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  width: 70,
                  height: 100,
                  color: AppColors.surfaceDark,
                  child: const Icon(Icons.broken_image),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    manga.title,
                    style: Theme.of(context).textTheme.titleLarge,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    manga.status,
                    style: Theme.of(context).textTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _buildInfoChip(
                        context,
                        Icons.star,
                        manga.rating.toStringAsFixed(1),
                        AppColors.warning,
                      ),
                      const SizedBox(width: 12),
                      // _buildInfoChip(
                      //   context,
                      //   Icons.book,
                      //   '${manga.chapterCount} Ch',
                      //   AppColors.info,
                      // ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  // Genres
                  Wrap(
                    spacing: 6,
                    runSpacing: 4,
                    children: manga.genres.take(2).map((genre) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.getGenreColor(genre).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          genre,
                          style: TextStyle(
                            color: AppColors.getGenreColor(genre),
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
            if (trailing != null) trailing!,
          ],
        ),
      ),
    );
  }

  Widget _buildInfoChip(
    BuildContext context,
    IconData icon,
    String text,
    Color color,
  ) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: color),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
