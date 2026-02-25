import 'package:flutter/material.dart';
import '../../models/manga.dart';
import '../../core/navigation/app_router.dart';
import '../../widgets/manga_card.dart';

class SeeAllScreen extends StatelessWidget {
  final String title;
  final List<Manga> mangaList;

  const SeeAllScreen({
    super.key,
    required this.title,
    required this.mangaList,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: mangaList.isEmpty
          ? const Center(
              child: Text('No manga available'),
            )
          : GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 0.65,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: mangaList.length,
              itemBuilder: (context, index) {
                final manga = mangaList[index];
                return MangaCard(
                  manga: manga,
                  onTap: () {
                    Navigator.pushNamed(
                      context,
                      AppRouter.mangaDetail,
                      arguments: manga,
                    );
                  },
                );
              },
            ),
    );
  }
}
