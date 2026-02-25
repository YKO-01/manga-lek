import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../models/manga.dart';
import '../models/chapter.dart';
import '../models/category.dart';

class MangaService extends ChangeNotifier {
  // Supabase URLs
  static const String _mangaDataUrl =
      'https://dufgldnpzvzrmpwmskli.supabase.co/storage/v1/object/public/manga/manga_data.json';
  static const String _chaptersUrl =
      'https://dufgldnpzvzrmpwmskli.supabase.co/storage/v1/object/public/manga/chapters.json';
  static const String _categoriesUrl =
      'https://dufgldnpzvzrmpwmskli.supabase.co/storage/v1/object/public/manga/categories.json';

  List<Manga> _allMangas = [];
  List<Manga> _favoriteMangas = [];
  List<Manga> _recentlyReadMangas = [];
  List<Chapter> _allChapters = [];
  List<Category> _categories = [];
  bool _isLoading = false;
  String? _error;

  // Getters
  List<Manga> get allMangas => _allMangas;
  List<Manga> get favoriteMangas => _favoriteMangas;
  List<Manga> get recentlyReadMangas => _recentlyReadMangas;
  List<Chapter> get allChapters => _allChapters;
  List<Category> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get error => _error;

  List<Manga> get trendingMangas {
    final sorted = List<Manga>.from(_allMangas);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted.take(5).toList();
  }

  List<Manga> get popularMangas {
    final sorted = List<Manga>.from(_allMangas);
    sorted.sort((a, b) => b.chapterCount.compareTo(a.chapterCount));
    return sorted.take(10).toList();
  }

  List<Manga> get newReleases {
    return _allMangas.where((m) => m.status == 'Ongoing').toList();
  }

  // Load data from Supabase URLs
  Future<void> loadData() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Fetch manga_data.json from Supabase
      final mangaDataResponse = await http.get(Uri.parse(_mangaDataUrl));
      if (mangaDataResponse.statusCode != 200) {
        throw Exception(
          'Failed to fetch manga data: ${mangaDataResponse.statusCode}',
        );
      }
      final Map<String, dynamic> jsonData = json.decode(mangaDataResponse.body);

      // Parse mangas
      final mangaList = jsonData['mangas'] as List;
      _allMangas = mangaList.map((m) => Manga.fromJson(m)).toList();

      // Load chapters from manga objects first
      _allChapters = [];
      for (final manga in _allMangas) {
        for (final chapter in manga.chapters) {
          _allChapters.add(
            Chapter(
              id: chapter.id,
              mangaId: manga.id,
              number: chapter.number,
              title: chapter.title,
              releaseDate: chapter.releaseDate,
              pages: chapter.pages,
              isRead: chapter.isRead,
              url: chapter.url,
              views: chapter.views,
            ),
          );
        }
      }

      // Fetch chapters.json from Supabase (contains pages)
      final chaptersResponse = await http.get(Uri.parse(_chaptersUrl));
      if (chaptersResponse.statusCode == 200) {
        final List<dynamic> chapterList = json.decode(chaptersResponse.body);
        for (final chapterJson in chapterList) {
          final chapter = Chapter.fromJson(chapterJson as Map<String, dynamic>);
          final existingIndex = _allChapters.indexWhere(
            (c) => c.mangaId == chapter.mangaId && c.number == chapter.number,
          );
          if (existingIndex != -1) {
            _allChapters[existingIndex] = Chapter(
              id: chapter.id,
              mangaId: chapter.mangaId,
              number: chapter.number,
              title: _allChapters[existingIndex].title,
              releaseDate: chapter.releaseDate.isNotEmpty
                  ? chapter.releaseDate
                  : _allChapters[existingIndex].releaseDate,
              pages: chapter.pages,
              isRead: _allChapters[existingIndex].isRead,
              url: (chapter.url?.isNotEmpty ?? false)
                  ? chapter.url
                  : _allChapters[existingIndex].url,
              views: chapter.views,
            );
          } else {
            _allChapters.add(chapter);
          }
        }
      }

      // Fetch categories.json from Supabase
      final categoriesResponse = await http.get(Uri.parse(_categoriesUrl));
      if (categoriesResponse.statusCode == 200) {
        final List<dynamic> categoryList = json.decode(categoriesResponse.body);
        _categories = categoryList.map((c) => Category.fromJson(c)).toList();
      } else {
        _categories = [];
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Failed to load manga data: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Get manga by ID
  Manga? getMangaById(String id) {
    try {
      return _allMangas.firstWhere((m) => m.id == id);
    } catch (e) {
      return null;
    }
  }

  // Get chapters for a manga
  List<Chapter> getChaptersForManga(String mangaId) {
    return _allChapters.where((c) => c.mangaId == mangaId).toList()
      ..sort((a, b) => a.number.compareTo(b.number));
  }

  // Get mangas by genre
  List<Manga> getMangasByGenre(String genre) {
    return _allMangas.where((m) => m.genres.contains(genre)).toList();
  }

  // Search mangas
  List<Manga> searchMangas(String query) {
    if (query.isEmpty) return [];
    final lowerQuery = query.toLowerCase();
    return _allMangas.where((m) {
      return m.title.toLowerCase().contains(lowerQuery) ||
          m.description.toLowerCase().contains(lowerQuery) ||
          m.genres.any((g) => g.toLowerCase().contains(lowerQuery));
    }).toList();
  }

  // Toggle favorite
  void toggleFavorite(String mangaId) {
    final index = _allMangas.indexWhere((m) => m.id == mangaId);
    if (index != -1) {
      final manga = _allMangas[index];
      final updatedManga = manga.copyWith(isFavorite: !manga.isFavorite);
      _allMangas[index] = updatedManga;

      if (updatedManga.isFavorite) {
        _favoriteMangas.add(updatedManga);
      } else {
        _favoriteMangas.removeWhere((m) => m.id == mangaId);
      }
      notifyListeners();
    }
  }

  // Check if manga is favorite
  bool isFavorite(String mangaId) {
    return _favoriteMangas.any((m) => m.id == mangaId);
  }

  // Mark chapter as read
  void markChapterAsRead(String chapterId) {
    final index = _allChapters.indexWhere((c) => c.id == chapterId);
    if (index != -1) {
      _allChapters[index] = _allChapters[index].copyWith(isRead: true);
      notifyListeners();
    }
  }

  // Update last read
  void updateLastRead(String mangaId, int chapterNumber) {
    final index = _allMangas.indexWhere((m) => m.id == mangaId);
    if (index != -1) {
      final manga = _allMangas[index];
      final updatedManga = manga.copyWith(
        lastRead: DateTime.now(),
        lastReadChapter: chapterNumber,
      );
      _allMangas[index] = updatedManga;

      // Update recently read list
      _recentlyReadMangas.removeWhere((m) => m.id == mangaId);
      _recentlyReadMangas.insert(0, updatedManga);
      if (_recentlyReadMangas.length > 10) {
        _recentlyReadMangas = _recentlyReadMangas.take(10).toList();
      }
      notifyListeners();
    }
  }

  // Get reading progress for a manga
  double getReadingProgress(String mangaId) {
    final chapters = getChaptersForManga(mangaId);
    if (chapters.isEmpty) return 0;
    final readChapters = chapters.where((c) => c.isRead).length;
    return readChapters / chapters.length;
  }

  // Clear all favorites
  void clearAllFavorites() {
    for (var i = 0; i < _allMangas.length; i++) {
      if (_allMangas[i].isFavorite) {
        _allMangas[i] = _allMangas[i].copyWith(isFavorite: false);
      }
    }
    _favoriteMangas.clear();
    notifyListeners();
  }

  // Clear reading history
  void clearReadingHistory() {
    for (var i = 0; i < _allMangas.length; i++) {
      _allMangas[i] = _allMangas[i].copyWith(
        lastRead: null,
        lastReadChapter: null,
      );
    }
    _recentlyReadMangas.clear();

    // Also reset chapter read status
    for (var i = 0; i < _allChapters.length; i++) {
      _allChapters[i] = _allChapters[i].copyWith(isRead: false);
    }
    notifyListeners();
  }
}
