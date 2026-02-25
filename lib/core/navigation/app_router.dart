import 'package:flutter/material.dart';
import '../../screens/splash/splash_screen.dart';
import '../../screens/main/main_screen.dart';
import '../../screens/manga_detail/manga_detail_screen.dart';
import '../../screens/reader/reader_screen.dart';
import '../../screens/search/search_screen.dart';
import '../../screens/favorites/favorites_screen.dart';
import '../../screens/settings/settings_screen.dart';
import '../../screens/see_all/see_all_screen.dart';
import '../../models/manga.dart';
import '../../models/chapter.dart';

class AppRouter {
  static const String splash = '/';
  static const String main = '/main';
  static const String mangaDetail = '/manga-detail';
  static const String reader = '/reader';
  static const String search = '/search';
  static const String favorites = '/favorites';
  static const String settings = '/settings';
  static const String seeAll = '/see-all';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case splash:
        return _buildRoute(const SplashScreen(), settings);
      
      case main:
        return _buildRoute(const MainScreen(), settings);
      
      case mangaDetail:
        final manga = settings.arguments as Manga;
        return _buildRoute(MangaDetailScreen(manga: manga), settings);
      
      case reader:
        final args = settings.arguments as Map<String, dynamic>;
        final chapter = args['chapter'] as Chapter;
        final manga = args['manga'] as Manga;
        return _buildRoute(
          ReaderScreen(chapter: chapter, manga: manga), 
          settings,
        );
      
      case search:
        return _buildRoute(const SearchScreen(), settings);
      
      case favorites:
        return _buildRoute(const FavoritesScreen(), settings);
      
      case AppRouter.settings:
        return _buildRoute(const SettingsScreen(), settings);
      
      case seeAll:
        final args = settings.arguments as Map<String, dynamic>;
        final title = args['title'] as String;
        final mangaList = args['mangaList'] as List<Manga>;
        return _buildRoute(
          SeeAllScreen(title: title, mangaList: mangaList),
          settings,
        );
      
      default:
        return _buildRoute(
          Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
          settings,
        );
    }
  }

  static PageRouteBuilder _buildRoute(Widget page, RouteSettings settings) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => page,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        const begin = Offset(1.0, 0.0);
        const end = Offset.zero;
        const curve = Curves.easeInOut;
        
        var tween = Tween(begin: begin, end: end).chain(
          CurveTween(curve: curve),
        );
        
        return SlideTransition(
          position: animation.drive(tween),
          child: child,
        );
      },
      transitionDuration: const Duration(milliseconds: 300),
    );
  }
}
