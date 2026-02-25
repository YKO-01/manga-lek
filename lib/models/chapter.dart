class Chapter {
  final String id;
  final String? mangaId;
  final double number;
  final String title;
  final List<String> pages;
  final String releaseDate;
  final String? url;
  final int views;
  final bool isRead;

  const Chapter({
    required this.id,
    this.mangaId,
    required this.number,
    required this.title,
    this.pages = const [],
    required this.releaseDate,
    this.url,
    this.views = 0,
    this.isRead = false,
  });

  factory Chapter.fromJson(Map<String, dynamic> json) {
    return Chapter(
      id: json['id'] as String? ?? '',
      mangaId: json['mangaId'] as String?,
      number: (json['number'] as num?)?.toDouble() ?? 0.0,
      title: json['title'] as String? ?? '',
      pages: json['pages'] != null
          ? List<String>.from(json['pages'] as List)
          : [],
      releaseDate: json['releaseDate'] as String? ?? '',
      url: json['url'] as String?,
      views: json['views'] as int? ?? 0,
      isRead: json['isRead'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mangaId': mangaId,
      'number': number,
      'title': title,
      'pages': pages,
      'releaseDate': releaseDate,
      'url': url,
      'views': views,
      'isRead': isRead,
    };
  }

  Chapter copyWith({
    String? id,
    String? mangaId,
    double? number,
    String? title,
    List<String>? pages,
    String? releaseDate,
    String? url,
    int? views,
    bool? isRead,
  }) {
    return Chapter(
      id: id ?? this.id,
      mangaId: mangaId ?? this.mangaId,
      number: number ?? this.number,
      title: title ?? this.title,
      pages: pages ?? this.pages,
      releaseDate: releaseDate ?? this.releaseDate,
      url: url ?? this.url,
      views: views ?? this.views,
      isRead: isRead ?? this.isRead,
    );
  }
}
