import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepku/models/recipe.dart';
import 'package:resepku/services/recipe_service.dart';
import 'package:resepku/widgets/error_view.dart';
import 'package:resepku/widgets/recipe_tile.dart';

class SearchPage extends StatefulWidget {
  const SearchPage({super.key});

  @override
  State<SearchPage> createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  // Future masih null sebelum pengguna mencari.
  Future<List<Recipe>>? _searchFuture;

  String _query = '';

  // Menjalankan pencarian.
  void _search(String value) {
    final query = value.trim();

    if (query.isEmpty) return;

    setState(() {
      _query = query;
      _searchFuture =
          context.read<RecipeService>().searchRecipes(query);
    });
  }

  // Mengulangi pencarian jika terjadi error.
  void _retry() {
    if (_query.isEmpty) return;

    setState(() {
      _searchFuture =
          context.read<RecipeService>().searchRecipes(_query);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: TextField(
          autofocus: true,
          textInputAction: TextInputAction.search,
          decoration: const InputDecoration(
            hintText: 'Cari resep...',
            border: InputBorder.none,
          ),
          onSubmitted: _search,
        ),
      ),

      body: _searchFuture == null
          ? const Center(
              child: Text('Masukkan nama resep untuk mencari.'),
            )
          : FutureBuilder<List<Recipe>>(
              future: _searchFuture,
              builder: (context, snapshot) {

                // Loading state.
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                // Error state.
                if (snapshot.hasError) {
                  return ErrorView(
                    message: 'Gagal mencari resep.\n${snapshot.error}',
                    onRetry: _retry,
                  );
                }

                final recipes = snapshot.data ?? [];

                // Hasil pencarian kosong.
                if (recipes.isEmpty) {
                  return const Center(
                    child: Text('Resep tidak ditemukan.'),
                  );
                }

                // Menampilkan hasil pencarian.
                return ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    return RecipeTile(
                      recipe: recipes[index],
                    );
                  },
                );
              },
            ),
    );
  }
}
