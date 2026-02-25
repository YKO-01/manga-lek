import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:html/parser.dart' as html_parser;

class ChapterFetcherService {
  static final ChapterFetcherService _instance = ChapterFetcherService._internal();
  factory ChapterFetcherService() => _instance;
  ChapterFetcherService._internal();

  // Cache for fetched pages
  final Map<String, List<String>> _pagesCache = {};

  /// Fetch chapter pages from URL
  Future<List<String>> fetchChapterPages(String? chapterUrl) async {
    if (chapterUrl == null || chapterUrl.isEmpty) {
      return [];
    }

    // Check cache first
    if (_pagesCache.containsKey(chapterUrl)) {
      return _pagesCache[chapterUrl]!;
    }

    try {
      final response = await http.get(
        Uri.parse(chapterUrl),
        headers: {
          'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
          'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        },
      );

      if (response.statusCode != 200) {
        print('Failed to fetch chapter: ${response.statusCode}');
        return [];
      }

      final List<String> pages = [];
      final body = response.body;
      
      // ThunderScans uses ts_reader.run() JavaScript to load images
      // Extract images from: ts_reader.run({...sources:[{images:[...]}]})
      final tsReaderMatch = RegExp(r'ts_reader\.run\((\{.*?\})\);', dotAll: true).firstMatch(body);
      if (tsReaderMatch != null) {
        try {
          final jsonStr = tsReaderMatch.group(1);
          if (jsonStr != null) {
            final data = jsonDecode(jsonStr);
            final sources = data['sources'] as List?;
            if (sources != null && sources.isNotEmpty) {
              final images = sources[0]['images'] as List?;
              if (images != null) {
                for (final img in images) {
                  if (img is String && img.isNotEmpty) {
                    pages.add(img);
                  }
                }
              }
            }
          }
        } catch (e) {
          print('Error parsing ts_reader JSON: $e');
        }
      }
      
      // If ts_reader didn't work, try HTML parsing
      if (pages.isEmpty) {
        final document = html_parser.parse(body);
        
        // Try different image selectors used by manga sites
        final selectors = [
          '#readerarea img',
          '.reading-content img',
          '.chapter-content img',
          'div.reader-area img',
          '.container-chapter-reader img',
          '.page-break img',
          'div#content img',
          '.entry-content img.wp-manga-chapter-img',
          'img.wp-manga-chapter-img',
        ];

        for (final selector in selectors) {
          final images = document.querySelectorAll(selector);
          if (images.isNotEmpty) {
            for (final img in images) {
              String? src = img.attributes['src'] ?? 
                            img.attributes['data-src'] ?? 
                            img.attributes['data-lazy-src'];
              
              if (src != null) {
                // Filter out logos, banners, ads
                final lowerSrc = src.toLowerCase();
                if (!lowerSrc.contains('logo') && 
                    !lowerSrc.contains('banner') &&
                    !lowerSrc.contains('avatar') &&
                    !lowerSrc.contains('icon') &&
                    !lowerSrc.contains('ads') &&
                    !lowerSrc.contains('gravatar') &&
                    !lowerSrc.contains('readerarea.svg') &&
                    (lowerSrc.contains('.jpg') || 
                     lowerSrc.contains('.jpeg') || 
                     lowerSrc.contains('.png') || 
                     lowerSrc.contains('.webp') ||
                     lowerSrc.contains('.gif') ||
                     lowerSrc.contains('/manga/') ||
                     lowerSrc.contains('/uploads/'))) {
                  pages.add(src);
                }
              }
            }
            if (pages.isNotEmpty) break;
          }
        }
      }

      // Cache the result
      if (pages.isNotEmpty) {
        _pagesCache[chapterUrl] = pages;
      }

      return pages;
    } catch (e) {
      print('Error fetching chapter pages: $e');
      return [];
    }
  }

  /// Clear cache for a specific chapter
  void clearCache(String chapterUrl) {
    _pagesCache.remove(chapterUrl);
  }

  /// Clear all cache
  void clearAllCache() {
    _pagesCache.clear();
  }
}
