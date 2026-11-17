import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:resepku/models/recipe.dart';
import 'package:resepku/providers/favorite_provider.dart';
import 'package:resepku/services/recipe_service.dart';

class DetailPage extends StatefulWidget {
  const DetailPage({super.key, required this.recipe});

  final Recipe recipe;

  @override
  State<DetailPage> createState() => _DetailPageState();
}

class _DetailPageState extends State<DetailPage> {
  late int _servings;

  @override
  void initState() {
    super.initState();
    _servings = widget.recipe.servings;
  }

  // Menambah jumlah porsi
  void _addServing() {
    setState(() {
      _servings++;
    });
  }

  // Mengurangi jumlah porsi
  void _removeServing() {
    if (_servings > 1) {
      setState(() {
        _servings--;
      });
    }
  }

  // Mengubah nama resep
  Future<void> _editRecipeName() async {
    String inputName = widget.recipe.name;

    // Menampilkan dialog untuk mengubah nama resep.
    final String? editedName = await showDialog<String>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Ubah Nama Resep'),
          content: TextFormField(
            initialValue: widget.recipe.name,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              labelText: 'Nama Resep',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              inputName = value;
            },
            onFieldSubmitted: (value) {
              final name = value.trim();

              if (name.isNotEmpty) {
                Navigator.of(dialogContext).pop(name);
              }
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop();
              },
              child: const Text('Batal'),
            ),
            ElevatedButton(
              onPressed: () {
                final name = inputName.trim();

                if (name.isNotEmpty) {
                  Navigator.of(dialogContext).pop(name);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        );
      },
    );

    // Pastikan halaman masih aktif dan nama tidak kosong.
    if (!mounted || editedName == null || editedName.trim().isEmpty) {
      return;
    }

    try {
      // Mengirim perubahan nama menggunakan API PUT.
      await context.read<RecipeService>().updateRecipe(
        id: widget.recipe.id,
        name: editedName,
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Nama resep berhasil diubah menjadi "$editedName".',
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal mengubah nama resep: $e'),
        ),
      );
    }
  }


  // Menghapus resep
  Future<void> _confirmDeleteRecipe() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Hapus Resep?'),
          content: const Text(
            'Apakah Anda yakin ingin menghapus resep ini?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (!mounted || confirm != true) return;

    try {
      final result = await context
          .read<RecipeService>()
          .deleteRecipe(widget.recipe.id);

      if (!mounted) return;

      if (result['isDeleted'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resep berhasil dihapus.'),
          ),
        );

        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Resep gagal dihapus.'),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal menghapus resep: $e'),
        ),
      );
    }
  }


  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;

    final totalCalories =
        recipe.caloriesPerServing * _servings;

    final isFavorite =
        context.watch<FavoriteProvider>().isFavorite(recipe);

    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      body: CustomScrollView(
        slivers: [

          // SliverAppBar dengan foto resep
          SliverAppBar(
            pinned: true,
            expandedHeight: 260,
            title: Text(recipe.name),

            actions: [
              IconButton(
                icon: Icon(
                  isFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: isFavorite ? Colors.red : null,
                ),
                onPressed: () {
                  context
                      .read<FavoriteProvider>()
                      .toggle(recipe);
                },
              ),

               // Menu ubah dan hapus resep.
              PopupMenuButton<String>(
                onSelected: (value) {
                  if (value == 'edit') {
                    _editRecipeName();
                  } else if (value == 'delete') {
                    _confirmDeleteRecipe();
                  }
                },
                itemBuilder: (context) => const [
                  PopupMenuItem(
                    value: 'edit',
                    child: Text('Ubah nama'),
                  ),
                  PopupMenuItem(
                    value: 'delete',
                    child: Text('Hapus resep'),
                  ),
                ],
              ),
            ],

            // Foto resep menggunakan cache
            flexibleSpace: FlexibleSpaceBar(
              background: CachedNetworkImage(
                imageUrl: recipe.image,
                fit: BoxFit.cover,

                placeholder: (context, url) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                },

                errorWidget: (context, url, error) {
                  return Image.asset(
                    'assets/images/placeholder.png',
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),

          // Informasi resep dan jumlah porsi
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${recipe.cuisine} • '
                    '${recipe.difficulty} • '
                    '${recipe.totalTimeMinutes} menit',
                    style: textTheme.bodyLarge,
                  ),

                  const SizedBox(height: 16),

                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Row(
                        children: [
                          Text(
                            'Porsi',
                            style: textTheme.titleMedium,
                          ),

                          const Spacer(),

                          IconButton.filledTonal(
                            onPressed: _servings > 1
                                ? _removeServing
                                : null,
                            icon: const Icon(Icons.remove),
                          ),

                          Padding(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                            ),
                            child: Text(
                              '$_servings',
                              style: textTheme.titleLarge,
                            ),
                          ),

                          IconButton.filledTonal(
                            onPressed: _addServing,
                            icon: const Icon(Icons.add),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 8),

                  Text(
                    'Total kalori: $totalCalories kkal',
                    style: textTheme.titleMedium,
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Bahan',
                    style: textTheme.titleLarge,
                  ),
                ],
              ),
            ),
          ),

          // Daftar bahan resep
          SliverPadding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16,
            ),
            sliver: SliverList.builder(
              itemCount: recipe.ingredients.length,
              itemBuilder: (context, index) {
                final item = recipe.ingredients[index];

                return ListTile(
                  dense: true,
                  leading: const Icon(
                    Icons.check_circle_outline,
                  ),
                  title: Text(item),
                );
              },
            ),
          ),

          // Judul Langkah hanya ditampilkan jika tersedia
          if (recipe.instructions.isNotEmpty)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  16, 24, 16, 0,
                ),
                child: Text(
                  'Langkah',
                  style: textTheme.titleLarge,
                ),
              ),
            ),

          // Daftar langkah memasak dari API
          SliverList.builder(
            itemCount: recipe.instructions.length,
            itemBuilder: (context, index) {
              return ListTile(
                dense: true,
                leading: CircleAvatar(
                  radius: 12,
                  child: Text('${index + 1}'),
                ),
                title: Text(recipe.instructions[index]),
              );
            },
          ),

          // Ruang di bawah langkah terakhir
          const SliverToBoxAdapter(
            child: SizedBox(height: 24),
          ),
        ],
      ),
    );
  }
}
