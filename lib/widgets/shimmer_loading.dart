import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../../core/theme/app_colors.dart';

class ShimmerLoading extends StatelessWidget {
  final double width;
  final double height;
  final double borderRadius;

  const ShimmerLoading({
    super.key,
    this.width = double.infinity,
    this.height = 100,
    this.borderRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: AppColors.surfaceDark,
      highlightColor: AppColors.cardDark,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceDark,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class MangaCardShimmer extends StatelessWidget {
  final double width;
  final double height;

  const MangaCardShimmer({
    super.key,
    this.width = 140,
    this.height = 200,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      margin: const EdgeInsets.only(right: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: ShimmerLoading(
              width: width,
              height: height,
            ),
          ),
          const SizedBox(height: 8),
          const ShimmerLoading(width: 100, height: 14, borderRadius: 4),
          const SizedBox(height: 4),
          const ShimmerLoading(width: 70, height: 12, borderRadius: 4),
        ],
      ),
    );
  }
}

class MangaListShimmer extends StatelessWidget {
  const MangaListShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardTheme.color,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const ShimmerLoading(width: 70, height: 100, borderRadius: 8),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const ShimmerLoading(width: 150, height: 18, borderRadius: 4),
                const SizedBox(height: 8),
                const ShimmerLoading(width: 100, height: 14, borderRadius: 4),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const ShimmerLoading(width: 50, height: 14, borderRadius: 4),
                    const SizedBox(width: 12),
                    const ShimmerLoading(width: 60, height: 14, borderRadius: 4),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
