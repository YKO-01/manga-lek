# Manga Lek 📚

A production-ready Manga Reader Flutter application with a clean, modern UI and dark theme support.

## Features

- 🎨 **Modern Dark Theme** - Beautiful dark UI with orange accent colors
- 📱 **Responsive Design** - No overflow issues, clean layouts
- 🔍 **Search & Filter** - Search manga by title, author, or genre
- ❤️ **Favorites** - Save your favorite manga for quick access
- 📖 **Reading Progress** - Track your reading history and continue where you left off
- 📚 **Chapter Reader** - Vertical and horizontal reading modes
- 🎛️ **Customizable** - Dark/Light theme toggle, reader settings
- 💾 **Local Data** - JSON-based data service (easily extensible to API)

## Project Structure

```
lib/
├── main.dart                    # App entry point
├── core/
│   ├── theme/
│   │   ├── app_colors.dart      # Color constants
│   │   ├── app_theme.dart       # Theme configuration
│   │   └── theme_provider.dart  # Theme state management
│   └── navigation/
│       └── app_router.dart      # Navigation routes
├── models/
│   ├── manga.dart               # Manga model
│   ├── chapter.dart             # Chapter model
│   └── category.dart            # Category model
├── services/
│   └── manga_service.dart       # Data service (JSON reader)
├── screens/
│   ├── splash/                  # Splash screen
│   ├── main/                    # Main navigation
│   ├── home/                    # Home screen
│   ├── explore/                 # Explore/Browse
│   ├── library/                 # Library (Favorites, Reading, Completed)
│   ├── profile/                 # Profile & Settings access
│   ├── manga_detail/            # Manga details & chapters
│   ├── reader/                  # Chapter reader
│   ├── search/                  # Search screen
│   ├── favorites/               # Favorites list
│   └── settings/                # Settings screen
└── widgets/
    ├── manga_card.dart          # Manga card widget
    ├── manga_list_tile.dart     # Manga list item
    ├── featured_manga_card.dart # Featured carousel card
    ├── genre_chip.dart          # Genre tag chip
    ├── search_bar_widget.dart   # Search input
    ├── section_header.dart      # Section titles
    └── shimmer_loading.dart     # Loading placeholders
```

## Getting Started

### Prerequisites

- Flutter SDK (>=3.8.1)
- Dart SDK
- iOS Simulator or Android Emulator

### Installation

1. Clone the repository
2. Install dependencies:
   ```bash
   flutter pub get
   ```
3. Run the app:
   ```bash
   flutter run
   ```

### Build for iOS

```bash
flutter build ios --release
```

### Build for Android

```bash
flutter build apk --release
```

## Dependencies

- `provider` - State management
- `cached_network_image` - Image caching
- `shimmer` - Loading animations
- `flutter_svg` - SVG support
- `flutter_cache_manager` - Cache management

## Screens

1. **Splash Screen** - Animated logo with loading
2. **Home Screen** - Featured manga, trending, popular, new releases
3. **Explore Screen** - Browse by category and genre
4. **Library Screen** - Favorites, currently reading, completed
5. **Profile Screen** - User stats, settings access, theme toggle
6. **Manga Detail Screen** - Full manga info, chapter list
7. **Reader Screen** - Full-screen reading with controls
8. **Search Screen** - Search with recent searches and genre filters
9. **Settings Screen** - App preferences and configuration

## Customization

### Adding New Manga Data

Edit `assets/data/manga_data.json` to add or modify manga entries.

### Changing Theme Colors

Edit `lib/core/theme/app_colors.dart` to customize the color palette.

### Connecting to an API

Modify `lib/services/manga_service.dart` to fetch data from a remote API instead of local JSON.

## License

This project is for educational purposes.
