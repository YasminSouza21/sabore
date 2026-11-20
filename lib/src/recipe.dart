class Recipe {
  const Recipe({
    required this.id,
    required this.name,
    required this.ingredients,
    required this.instructions,
    this.image,
    this.prepMinutes,
    this.cookMinutes,
    this.servings,
    this.rating,
    this.difficulty,
    this.cuisine,
    this.mealTypes = const [],
  });

  final int id;
  final String name;
  final List<String> ingredients;
  final List<String> instructions;
  final String? image;
  final int? prepMinutes;
  final int? cookMinutes;
  final int? servings;
  final num? rating;
  final String? difficulty;
  final String? cuisine;
  final List<String> mealTypes;

  int? get totalMinutes => prepMinutes == null || cookMinutes == null
      ? null
      : prepMinutes! + cookMinutes!;

  factory Recipe.fromJson(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Receita incompatível.');
    }
    final id = value['id'];
    final name = value['name'];
    if (id is! int || name is! String) {
      throw const FormatException('Receita sem identidade.');
    }
    return Recipe(
      id: id,
      name: name.trim().isEmpty ? 'Receita sem nome' : name,
      ingredients: _strings(value['ingredients']),
      instructions: _strings(value['instructions']),
      image: _nonEmpty(value['image']),
      prepMinutes: _nonNegativeInt(value['prepTimeMinutes']),
      cookMinutes: _nonNegativeInt(value['cookTimeMinutes']),
      servings: _positiveInt(value['servings']),
      rating: value['rating'] is num ? value['rating'] as num : null,
      difficulty: _nonEmpty(value['difficulty']),
      cuisine: _nonEmpty(value['cuisine']),
      mealTypes: _strings(value['mealType']),
    );
  }

  static List<String> _strings(Object? value) => value is List
      ? value.whereType<String>().where((s) => s.trim().isNotEmpty).toList()
      : const [];
  static String? _nonEmpty(Object? value) =>
      value is String && value.trim().isNotEmpty ? value : null;
  static int? _nonNegativeInt(Object? value) =>
      value is int && value >= 0 ? value : null;
  static int? _positiveInt(Object? value) =>
      value is int && value > 0 ? value : null;
}
