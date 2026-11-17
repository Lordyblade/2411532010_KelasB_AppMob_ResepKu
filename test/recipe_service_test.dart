import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:resepku/models/recipe.dart';
import 'package:resepku/services/recipe_service.dart';

void main() {
  group('Recipe.fromJson', () {
    test(
      'rating integer menjadi double dan field kosong memakai nilai default',
      () {
        final recipe = Recipe.fromJson({
          'id': 1,
          'name': 'Resep Uji',
          'rating': 5,
        });

        // Memastikan rating integer dikonversi menjadi double.
        expect(recipe.rating, 5.0);

        // Memastikan field yang tidak tersedia menggunakan nilai default.
        expect(recipe.cuisine, '-');
        expect(recipe.difficulty, '-');
        expect(recipe.prepTimeMinutes, 0);
        expect(recipe.cookTimeMinutes, 0);
        expect(recipe.servings, 1);
        expect(recipe.caloriesPerServing, 0);
        expect(recipe.image, '');
        expect(recipe.ingredients, isEmpty);
        expect(recipe.instructions, isEmpty);
      },
    );
  });

  group('RecipeService.fetchRecipes', () {
    test(
      'mengembalikan List Recipe dari respons palsu',
      () async {
        final client = MockClient((request) async {
          expect(request.method, 'GET');
          expect(request.url.path, '/recipes');
          expect(request.url.queryParameters['limit'], '50');

          return http.Response(
            jsonEncode({
              'recipes': [
                {
                  'id': 1,
                  'name': 'Resep Uji',
                  'cuisine': 'Indonesian',
                  'rating': 5,
                }
              ],
              'total': 1,
              'skip': 0,
              'limit': 50,
            }),
            200,
            headers: {
              'content-type': 'application/json',
            },
          );
        });

        final service = RecipeService(client: client);

        addTearDown(service.close);

        final recipes = await service.fetchRecipes();

        expect(recipes, isA<List<Recipe>>());
        expect(recipes.length, 1);
        expect(recipes.first.name, 'Resep Uji');
        expect(recipes.first.rating, 5.0);
      },
    );

    test(
      'melempar RecipeServiceException jika status 404',
      () async {
        final client = MockClient((request) async {
          return http.Response(
            '{"message":"Not Found"}',
            404,
          );
        });

        final service = RecipeService(client: client);

        addTearDown(service.close);

        await expectLater(
          service.fetchRecipes(),
          throwsA(isA<RecipeServiceException>()),
        );
      },
    );
  });
}
