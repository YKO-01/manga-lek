import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:provider/provider.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import '../../models/manga.dart';
import '../../models/chapter.dart';
import '../../services/manga_service.dart';
import '../../services/chapter_fetcher_service.dart';
import '../../core/theme/app_colors.dart';
import '../../core/settings/settings_provider.dart';

class ReaderScreen extends StatefulWidget {
  final Chapter chapter;
  final Manga manga;

  const ReaderScreen({super.key, required this.chapter, required this.manga});

  @override
  State<ReaderScreen> createState() => _ReaderScreenState();
}

class _ReaderScreenState extends State<ReaderScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _showControls = true;
  late bool _isVerticalMode;

  late Chapter _currentChapter;
  List<Chapter> _allChapters = [];
  int _currentChapterIndex = 0;

  // Dynamic page loading
  List<String> _currentPages = [];
  bool _isLoadingPages = false;
  String? _loadError;

  final ChapterFetcherService _chapterFetcher = ChapterFetcherService();

  @override
  void initState() {
    super.initState();
    _currentChapter = widget.chapter;

    // Load default settings from SettingsProvider
    final settings = Provider.of<SettingsProvider>(context, listen: false);
    _isVerticalMode = settings.defaultVerticalMode;

    // Apply keep screen on setting
    if (settings.keepScreenOn) {
      WakelockPlus.enable();
    }

    // Enter fullscreen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);

    // Load chapters and mark as read
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadChapters();
      _loadPagesForCurrentChapter();
      _markAsRead();
    });
  }

  Future<void> _loadPagesForCurrentChapter() async {
    setState(() {
      _isLoadingPages = true;
      _loadError = null;
      _currentPages = [];
    });

    try {
      // First check if chapter has embedded pages (from JSON)
      if (_currentChapter.pages.isNotEmpty) {
        setState(() {
          _currentPages = _currentChapter.pages;
          _isLoadingPages = false;
        });
        return;
      }
      
      // Check if we have a chapter with pages in _allChapters
      final chapterWithPages = _allChapters.firstWhere(
        (c) => c.id == _currentChapter.id && c.pages.isNotEmpty,
        orElse: () => _currentChapter,
      );
      
      if (chapterWithPages.pages.isNotEmpty) {
        setState(() {
          _currentPages = chapterWithPages.pages;
          _isLoadingPages = false;
        });
        return;
      }

      // Fetch pages from chapter URL dynamically
      final pages = await _chapterFetcher.fetchChapterPages(_currentChapter.url);
      
      setState(() {
        _currentPages = pages;
        _isLoadingPages = false;
        if (pages.isEmpty) {
          _loadError = 'No pages found for this chapter';
        }
      });
    } catch (e) {
      setState(() {
        _isLoadingPages = false;
        _loadError = 'Failed to load pages: $e';
      });
    }
  }

  void _loadChapters() {
    final mangaService = context.read<MangaService>();
    _allChapters = mangaService.getChaptersForManga(widget.manga.id);

    // Find current chapter index
    _currentChapterIndex = _allChapters.indexWhere(
      (c) => c.id == _currentChapter.id,
    );

    if (_currentChapterIndex == -1) {
      _currentChapterIndex = 0;
    }

    setState(() {});
  }

  void _markAsRead() {
    final mangaService = context.read<MangaService>();
    mangaService.markChapterAsRead(_currentChapter.id);
    mangaService.updateLastRead(widget.manga.id, _currentChapter.number.toInt());
  }

  bool get _hasPreviousChapter => _currentChapterIndex > 0;
  bool get _hasNextChapter => _currentChapterIndex < _allChapters.length - 1;

  void _goToPreviousChapter() {
    if (!_hasPreviousChapter) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This is the first chapter'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    _currentChapterIndex--;
    _currentChapter = _allChapters[_currentChapterIndex];
    _currentPage = 0;
    
    _loadPagesForCurrentChapter();
    _markAsRead();
  }

  void _goToNextChapter() {
    if (!_hasNextChapter) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('This is the last chapter'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    _currentChapterIndex++;
    _currentChapter = _allChapters[_currentChapterIndex];
    _currentPage = 0;
    
    _loadPagesForCurrentChapter();
    _markAsRead();
  }

  void _showChapterSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        maxChildSize: 0.9,
        minChildSize: 0.3,
        expand: false,
        builder: (context, scrollController) => Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  const Text(
                    'Select Chapter',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: ListView.builder(
                controller: scrollController,
                itemCount: _allChapters.length,
                itemBuilder: (context, index) {
                  final chapter = _allChapters[index];
                  final isCurrentChapter = chapter.id == _currentChapter.id;

                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isCurrentChapter
                          ? AppColors.primary
                          : AppColors.surfaceDark,
                      child: Text(
                        '${chapter.number}',
                        style: TextStyle(
                          color: isCurrentChapter
                              ? Colors.white
                              : AppColors.textSecondaryDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    title: Text(
                      'Chapter ${chapter.number}',
                      style: TextStyle(
                        fontWeight: isCurrentChapter
                            ? FontWeight.bold
                            : FontWeight.normal,
                        color: isCurrentChapter ? AppColors.primary : null,
                      ),
                    ),
                    subtitle: Text(
                      chapter.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: chapter.isRead
                        ? const Icon(
                            Icons.check_circle,
                            color: AppColors.success,
                            size: 20,
                          )
                        : null,
                    onTap: () {
                      Navigator.pop(context);
                      _currentChapterIndex = index;
                      _currentChapter = chapter;
                      _currentPage = 0;
                      _loadPagesForCurrentChapter();
                      _markAsRead();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    // Exit fullscreen mode
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    // Disable wakelock when leaving reader
    WakelockPlus.disable();
    _pageController.dispose();
    super.dispose();
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Reader Content
          GestureDetector(
            onTap: _toggleControls,
            child: _isVerticalMode
                ? _buildVerticalReader()
                : _buildHorizontalReader(),
          ),
          // Top Controls
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            top: _showControls ? 0 : -100,
            left: 0,
            right: 0,
            child: _buildTopControls(),
          ),
          // Bottom Controls
          AnimatedPositioned(
            duration: const Duration(milliseconds: 200),
            bottom: _showControls ? 0 : -150,
            left: 0,
            right: 0,
            child: _buildBottomControls(),
          ),
        ],
      ),
    );
  }

  Widget _buildVerticalReader() {
    // Show loading state
    if (_isLoadingPages) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Loading pages...',
              style: TextStyle(color: AppColors.textSecondaryDark),
            ),
          ],
        ),
      );
    }

    // Show error state
    if (_loadError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _loadError!,
              style: const TextStyle(color: AppColors.textSecondaryDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadPagesForCurrentChapter,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show placeholder if no pages
    if (_currentPages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image_not_supported,
              color: AppColors.textTertiaryDark,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'No pages available',
              style: TextStyle(color: AppColors.textSecondaryDark),
            ),
            const SizedBox(height: 24),
            if (_hasNextChapter)
              ElevatedButton(
                onPressed: _goToNextChapter,
                child: const Text('Go to Next Chapter'),
              ),
          ],
        ),
      );
    }

    return ListView.builder(
      itemCount: _currentPages.length,
      itemBuilder: (context, index) {
        return CachedNetworkImage(
          imageUrl: _currentPages[index],
          fit: BoxFit.fitWidth,
          placeholder: (context, url) => Container(
            height: 500,
            color: AppColors.surfaceDark,
            child: const Center(
              child: CircularProgressIndicator(color: AppColors.primary),
            ),
          ),
          errorWidget: (context, url, error) => Container(
            height: 500,
            color: AppColors.surfaceDark,
            child: const Center(
              child: Icon(
                Icons.broken_image,
                color: AppColors.textTertiaryDark,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHorizontalReader() {
    // Show loading state
    if (_isLoadingPages) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.primary),
            SizedBox(height: 16),
            Text(
              'Loading pages...',
              style: TextStyle(color: AppColors.textSecondaryDark),
            ),
          ],
        ),
      );
    }

    // Show error state
    if (_loadError != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              color: AppColors.error,
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              _loadError!,
              style: const TextStyle(color: AppColors.textSecondaryDark),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loadPagesForCurrentChapter,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Show placeholder if no pages
    if (_currentPages.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.image_not_supported,
              color: AppColors.textTertiaryDark,
              size: 64,
            ),
            const SizedBox(height: 16),
            const Text(
              'No pages available',
              style: TextStyle(color: AppColors.textSecondaryDark),
            ),
            const SizedBox(height: 24),
            if (_hasNextChapter)
              ElevatedButton(
                onPressed: _goToNextChapter,
                child: const Text('Go to Next Chapter'),
              ),
          ],
        ),
      );
    }

    return PageView.builder(
      controller: _pageController,
      onPageChanged: (index) {
        setState(() {
          _currentPage = index;
        });
      },
      itemCount: _currentPages.length,
      itemBuilder: (context, index) {
        return InteractiveViewer(
          minScale: 1.0,
          maxScale: 4.0,
          child: CachedNetworkImage(
            imageUrl: _currentPages[index],
            fit: BoxFit.contain,
            placeholder: (context, url) => Container(
              color: AppColors.surfaceDark,
              child: const Center(
                child: CircularProgressIndicator(color: AppColors.primary),
              ),
            ),
            errorWidget: (context, url, error) => Container(
              color: AppColors.surfaceDark,
              child: const Center(
                child: Icon(
                  Icons.broken_image,
                  color: AppColors.textTertiaryDark,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopControls() {
    return Container(
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top,
        left: 8,
        right: 8,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black.withOpacity(0.8), Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
          Expanded(
            child: GestureDetector(
              onTap: _showChapterSelector,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    widget.manga.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Row(
                    children: [
                      Text(
                        'Chapter ${_currentChapter.number}',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                      if (_currentChapter.title.isNotEmpty) ...[
                        Text(
                          ': ${_currentChapter.title}',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: 12,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      const Icon(
                        Icons.keyboard_arrow_down,
                        color: Colors.white70,
                        size: 16,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // IconButton(
          //   icon: const Icon(Icons.bookmark_border, color: Colors.white),
          //   onPressed: () {},
          // ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).padding.bottom + 8,
        left: 16,
        right: 16,
        top: 16,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black.withOpacity(0.9), Colors.transparent],
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Chapter indicator
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              'Chapter ${_currentChapter.number.toInt()} of ${_allChapters.isNotEmpty ? _allChapters.length : widget.manga.chapterCount}',
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 12,
              ),
            ),
          ),
          // Page Indicator
          if (!_isVerticalMode && _currentPages.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '${_currentPage + 1}',
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    ' / ${_currentPages.length}',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.7),
                      fontSize: 18,
                    ),
                  ),
                ],
              ),
            ),
          // Slider
          if (!_isVerticalMode && _currentPages.isNotEmpty)
            SliderTheme(
              data: SliderThemeData(
                trackHeight: 4,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
                overlayShape: const RoundSliderOverlayShape(overlayRadius: 16),
                activeTrackColor: AppColors.primary,
                inactiveTrackColor: Colors.white.withOpacity(0.3),
                thumbColor: AppColors.primary,
                overlayColor: AppColors.primary.withOpacity(0.2),
              ),
              child: Slider(
                value: _currentPage.toDouble(),
                min: 0,
                max: (_currentPages.length - 1).toDouble().clamp(
                  0,
                  double.infinity,
                ),
                onChanged: (value) {
                  _pageController.jumpToPage(value.toInt());
                },
              ),
            ),
          const SizedBox(height: 8),
          // Control Buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildControlButton(
                icon: Icons.skip_previous,
                label: 'Previous',
                onTap: _goToPreviousChapter,
                isEnabled: _hasPreviousChapter,
              ),
              _buildControlButton(
                icon: _isVerticalMode ? Icons.swap_horiz : Icons.swap_vert,
                label: _isVerticalMode ? 'Horizontal' : 'Vertical',
                onTap: () {
                  setState(() {
                    _isVerticalMode = !_isVerticalMode;
                  });
                },
              ),
              _buildControlButton(
                icon: Icons.list,
                label: 'Chapters',
                onTap: _showChapterSelector,
              ),
              _buildControlButton(
                icon: Icons.settings,
                label: 'Settings',
                onTap: _showSettingsSheet,
              ),
              _buildControlButton(
                icon: Icons.skip_next,
                label: 'Next',
                onTap: _goToNextChapter,
                isEnabled: _hasNextChapter,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isEnabled = true,
  }) {
    return GestureDetector(
      onTap: isEnabled ? onTap : null,
      child: Opacity(
        opacity: isEnabled ? 1.0 : 0.4,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.7),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showSettingsSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.cardDark,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Reader Settings',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: const Icon(Icons.swap_vert),
              title: const Text('Reading Direction'),
              subtitle: Text(_isVerticalMode ? 'Vertical' : 'Horizontal'),
              trailing: Switch(
                value: _isVerticalMode,
                onChanged: (value) {
                  setState(() {
                    _isVerticalMode = value;
                  });
                  Navigator.pop(context);
                },
                activeColor: AppColors.primary,
              ),
            ),
            // ListTile(
            //   leading: const Icon(Icons.screen_rotation),
            //   title: const Text('Auto-rotate'),
            //   trailing: Switch(
            //     value: false,
            //     onChanged: (value) {},
            //     activeColor: AppColors.primary,
            //   ),
            // ),
            // ListTile(
            //   leading: const Icon(Icons.visibility),
            //   title: const Text('Keep screen on'),
            //   trailing: Switch(
            //     value: true,
            //     onChanged: (value) {},
            //     activeColor: AppColors.primary,
            //   ),
            // ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
