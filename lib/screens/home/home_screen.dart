import 'package:flutter/material.dart';
import 'package:manga_lek/const.dart';
import 'package:provider/provider.dart';
import '../../services/manga_service.dart';
import '../../core/navigation/app_router.dart';
import '../../core/theme/app_colors.dart';
import '../../widgets/manga_card.dart';
import '../../widgets/featured_manga_card.dart';
import '../../widgets/section_header.dart';
import '../../widgets/shimmer_loading.dart';
import '../../widgets/search_bar_widget.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final PageController _featuredController = PageController(
    viewportFraction: 0.9,
  );
  int _currentFeaturedIndex = 0;

  @override
  void dispose() {
    _featuredController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Consumer<MangaService>(
          builder: (context, mangaService, child) {
            if (mangaService.isLoading) {
              return _buildLoadingState();
            }

            if (mangaService.error != null) {
              return _buildErrorState(mangaService.error!);
            }

            return CustomScrollView(
              slivers: [
                // App Bar
                SliverToBoxAdapter(child: _buildHeader(context)),
                // Search Bar
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: SearchBarWidget(
                      readOnly: true,
                      onTap: () {
                        Navigator.pushNamed(context, AppRouter.search);
                      },
                    ),
                  ),
                ),
                // Featured Section
                SliverToBoxAdapter(child: _buildFeaturedSection(mangaService)),
                // Continue Reading
                if (mangaService.recentlyReadMangas.isNotEmpty)
                  SliverToBoxAdapter(
                    child: _buildContinueReadingSection(mangaService),
                  ),
                // Trending Now
                SliverToBoxAdapter(child: _buildTrendingSection(mangaService)),
                // Popular Manga
                SliverToBoxAdapter(child: _buildPopularSection(mangaService)),
                // New Releases
                SliverToBoxAdapter(
                  child: _buildNewReleasesSection(mangaService),
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

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Welcome back! 👋',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
              const SizedBox(height: 4),
              Text(
                'Discover Manga',
                style: Theme.of(context).textTheme.displaySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeaturedSection(MangaService mangaService) {
    final trending = mangaService.trendingMangas;
    if (trending.isEmpty) return const SizedBox();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionHeader(title: 'Featured'),
        SizedBox(
          height: 280,
          child: PageView.builder(
            controller: _featuredController,
            onPageChanged: (index) {
              setState(() => _currentFeaturedIndex = index);
            },
            itemCount: trending.length,
            itemBuilder: (context, index) {
              final manga = trending[index];
              return FeaturedMangaCard(
                manga: manga,
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
          ),
        ),
        const SizedBox(height: 12),
        // Page Indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            trending.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: _currentFeaturedIndex == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentFeaturedIndex == index
                    ? AppColors.primary
                    : AppColors.surfaceDark,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildContinueReadingSection(MangaService mangaService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        const SectionHeader(title: 'Continue Reading'),
        SizedBox(
          height: 180,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: mangaService.recentlyReadMangas.length,
            itemBuilder: (context, index) {
              final manga = mangaService.recentlyReadMangas[index];
              return MangaCard(
                manga: manga,
                width: 120,
                height: 160,
                showRating: false,
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
          ),
        ),
      ],
    );
  }

  Widget _buildTrendingSection(MangaService mangaService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        SectionHeader(
          title: 'Trending Now 🔥',
          actionText: 'See All',
          onActionTap: () {
            Navigator.pushNamed(
              context,
              AppRouter.seeAll,
              arguments: {
                'title': 'Trending Now',
                'mangaList': mangaService.trendingMangas,
              },
            );
          },
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: mangaService.trendingMangas.length,
            itemBuilder: (context, index) {
              final manga = mangaService.trendingMangas[index];
              return MangaCard(
                manga: manga,
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
          ),
        ),
      ],
    );
  }

  Widget _buildPopularSection(MangaService mangaService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        SectionHeader(
          title: 'Popular Manga',
          actionText: 'See All',
          onActionTap: () {
            Navigator.pushNamed(
              context,
              AppRouter.seeAll,
              arguments: {
                'title': 'Popular Manga',
                'mangaList': mangaService.popularMangas,
              },
            );
          },
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: mangaService.popularMangas.length,
            itemBuilder: (context, index) {
              final manga = mangaService.popularMangas[index];
              return MangaCard(
                manga: manga,
                showStatus: true,
                onTap: () {
                  gAds.rewardInstance.showRewardAd(() {
                    Navigator.pushNamed(
                      context,
                      AppRouter.mangaDetail,
                      arguments: manga,
                    );
                  });
                  // Navigator.pushNamed(
                  //   context,
                  //   AppRouter.mangaDetail,
                  //   arguments: manga,
                  // );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNewReleasesSection(MangaService mangaService) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 24),
        SectionHeader(
          title: 'New Releases',
          actionText: 'See All',
          onActionTap: () {
            Navigator.pushNamed(
              context,
              AppRouter.seeAll,
              arguments: {
                'title': 'New Releases',
                'mangaList': mangaService.newReleases,
              },
            );
          },
        ),
        SizedBox(
          height: 220,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            scrollDirection: Axis.horizontal,
            itemCount: mangaService.newReleases.length,
            itemBuilder: (context, index) {
              final manga = mangaService.newReleases[index];
              return MangaCard(
                manga: manga,
                showStatus: true,
                onTap: () {
                  gAds.rewardInstance.showRewardAd(() {
                    Navigator.pushNamed(
                      context,
                      AppRouter.mangaDetail,
                      arguments: manga,
                    );
                  });
                  // Navigator.pushNamed(
                  //   context,
                  //   AppRouter.mangaDetail,
                  //   arguments: manga,
                  // );
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context),
          const Padding(
            padding: EdgeInsets.all(16),
            child: ShimmerLoading(height: 50, borderRadius: 12),
          ),
          const Padding(
            padding: EdgeInsets.all(16),
            child: ShimmerLoading(height: 280, borderRadius: 16),
          ),
          const SizedBox(height: 24),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16),
            child: ShimmerLoading(height: 24, width: 150, borderRadius: 4),
          ),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              itemCount: 4,
              itemBuilder: (context, index) => const MangaCardShimmer(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 64, color: AppColors.error),
          const SizedBox(height: 16),
          Text(
            'Oops! Something went wrong',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: Theme.of(context).textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              context.read<MangaService>().loadData();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}
