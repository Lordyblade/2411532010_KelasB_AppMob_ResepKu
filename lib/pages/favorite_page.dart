import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resepku/providers/favorite_provider.dart';
import 'package:resepku/widgets/recipe_image.dart';
 
class FavoritePage extends StatelessWidget {
  const FavoritePage({super.key});
 
  @override
  Widget build(BuildContext context) {
    return Consumer<FavoriteProvider>(
      builder: (context, favorite, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Favorit Saya'),
            actions: [
              IconButton(
                tooltip: 'Hapus semua',
                icon: const Icon(Icons.delete_sweep),
                onPressed: favorite.count == 0
                    ? null
                    : () async {
                        final confirm = await showDialog<bool>(
                          context: context,
                          builder: (dialogContext) {
                            return AlertDialog(
                              title: const Text('Hapus Semua Favorit?'),
                              content: const Text(
                                'Apakah Anda yakin ingin menghapus seluruh '
                                'resep dari daftar favorit?',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(
                                    dialogContext, false,
                                  ),
                                  child: const Text('Batal'),
                                ),
                                FilledButton(
                                  onPressed: () => Navigator.pop(
                                    dialogContext, true,
                                  ),
                                  child: const Text('Hapus Semua'),
                                ),
                              ],
                            );
                          },
                        );
 
                        if (confirm == true) {
                          context.read<FavoriteProvider>().clear();
                        }
                      },
              ),
            ],
          ),
          body: favorite.count == 0
              ? const Center(
                  child: Text(
                    'Belum ada resep favorit.\n'
                    'Tekan ikon hati di daftar resep.',
                    textAlign: TextAlign.center,
                  ),
                )
              : ListView.separated(
                  itemCount: favorite.items.length,
                  itemBuilder: (context, index) {
                    final recipe = favorite.items[index];
 
                    return Dismissible(
                      key: ValueKey(recipe.id),
                      direction: DismissDirection.endToStart,
                      background: Container(
                        color: Colors.red,
                        alignment: Alignment.centerRight,
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: const Icon(
                          Icons.delete,
                          color: Colors.white,
                        ),
                      ),
                      onDismissed: (direction) {
                        context.read<FavoriteProvider>().toggle(recipe);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              '${recipe.name} dihapus dari favorit.',
                            ),
                          ),
                        );
                      },
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 4,
                        ),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: SizedBox(
                            width: 64,
                            height: 64,
                            child: RecipeImage(
                              url: recipe.image,
                              cacheWidth: 192,
                            ),
                          ),
                        ),
                        title: Text(
                          recipe.name,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        subtitle: Text(
                          '${recipe.cuisine} • ${recipe.totalTimeMinutes} menit',
                        ),
                      ),
                    );
                  },
                  separatorBuilder: (context, index) {
                    return const Divider(height: 1, indent: 88);
                  },
                ),
        );
      },
    );
  }
}