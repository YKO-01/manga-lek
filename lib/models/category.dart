class Category {
  final String id;
  final String name;
  final String icon;
  final int mangaCount;
  final String? color;
  final String? filterType;  // "type", "status", or "all"
  final String? filterValue; // "Manhwa", "Manga", "Ongoing", etc.

  const Category({
    required this.id,
    required this.name,
    required this.icon,
    this.mangaCount = 0,
    this.color,
    this.filterType,
    this.filterValue,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      icon: json['icon'] as String? ?? 'category',
      mangaCount: json['mangaCount'] as int? ?? 0,
      color: json['color'] as String?,
      filterType: json['filterType'] as String?,
      filterValue: json['filterValue'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'icon': icon,
      'mangaCount': mangaCount,
      'color': color,
      'filterType': filterType,
      'filterValue': filterValue,
    };
  }
}
