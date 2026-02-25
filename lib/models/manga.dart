import 'chapter.dart';

class Manga {
  final String id;
  final String title;
  final String coverImage;
  final String description;
  final List<String> genres;
  final double rating;
  final List<Chapter> chapters;
  final String status;
  final String? type;
  final String? url;
  final bool isFavorite;
  final DateTime? lastRead;
  final int? lastReadChapter;

  const Manga({
    required this.id,
    required this.title,
    required this.coverImage,
    required this.description,
    required this.genres,
    required this.rating,
    required this.chapters,
    required this.status,
    this.type,
    this.url,
    this.isFavorite = false,
    this.lastRead,
    this.lastReadChapter,
  });

  /// Get chapter count
  int get chapterCount => chapters.length;

  factory Manga.fromJson(Map<String, dynamic> json) {
    // Handle chapters as either a list of objects or an int
    List<Chapter> chapterList = [];
    if (json['chapters'] != null) {
      if (json['chapters'] is List) {
        chapterList = (json['chapters'] as List)
            .map((ch) => Chapter.fromJson(ch as Map<String, dynamic>))
            .toList();
      }
    }

    return Manga(
      id: json['id'] as String,
      title: json['title'] as String,
      coverImage: json['coverImage'] as String,
      description: json['description'] as String? ?? '',
      genres: json['genres'] != null
          ? List<String>.from(json['genres'] as List)
          : ['Action'],
      rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
      chapters: chapterList,
      status: json['status'] as String? ?? 'Unknown',
      type: json['type'] as String?,
      url: json['url'] as String?,
      isFavorite: json['isFavorite'] as bool? ?? false,
      lastRead: json['lastRead'] != null
          ? DateTime.parse(json['lastRead'] as String)
          : null,
      lastReadChapter: json['lastReadChapter'] as int?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'coverImage': coverImage,
      'description': description,
      'genres': genres,
      'rating': rating,
      'chapters': chapters.map((ch) => ch.toJson()).toList(),
      'status': status,
      'type': type,
      'url': url,
      'isFavorite': isFavorite,
      'lastRead': lastRead?.toIso8601String(),
      'lastReadChapter': lastReadChapter,
    };
  }

  Manga copyWith({
    String? id,
    String? title,
    String? coverImage,
    String? description,
    List<String>? genres,
    double? rating,
    List<Chapter>? chapters,
    String? status,
    String? type,
    String? url,
    bool? isFavorite,
    DateTime? lastRead,
    int? lastReadChapter,
  }) {
    return Manga(
      id: id ?? this.id,
      title: title ?? this.title,
      coverImage: coverImage ?? this.coverImage,
      description: description ?? this.description,
      genres: genres ?? this.genres,
      rating: rating ?? this.rating,
      chapters: chapters ?? this.chapters,
      status: status ?? this.status,
      type: type ?? this.type,
      url: url ?? this.url,
      isFavorite: isFavorite ?? this.isFavorite,
      lastRead: lastRead ?? this.lastRead,
      lastReadChapter: lastReadChapter ?? this.lastReadChapter,
    );
  }
}
