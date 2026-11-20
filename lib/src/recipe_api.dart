import 'recipe.dart';

class RecipeApi {
  static const _examples = [
    Recipe(
      id: 1,
      name: 'Pasta Primavera',
      ingredients: ['Massa', 'Tomate', 'Azeite'],
      instructions: ['Cozinhe a massa.', 'Misture os ingredientes e sirva.'],
      prepMinutes: 10,
      cookMinutes: 20,
      servings: 2,
      difficulty: 'Fácil',
      cuisine: 'Italiana',
      mealTypes: ['Almoço'],
    ),
    Recipe(
      id: 2,
      name: 'Salada fresca',
      ingredients: ['Alface', 'Tomate'],
      instructions: ['Lave os ingredientes.', 'Misture e sirva.'],
      prepMinutes: 12,
      cookMinutes: 0,
      servings: 2,
      difficulty: 'Fácil',
      mealTypes: ['Acompanhamento'],
    ),
  ];

  Future<List<Recipe>> list() async => _examples;

  Future<List<Recipe>> search(String term) async => _examples
      .where((recipe) => recipe.name.toLowerCase().contains(term.toLowerCase()))
      .toList();

  void dispose() {}
}
