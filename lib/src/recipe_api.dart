import 'dart:convert';

import 'package:http/http.dart' as http;

import 'recipe.dart';

class RecipeApi {
  RecipeApi({http.Client? client}) : _client = client ?? http.Client();
  final http.Client _client;
  static final _base = Uri.parse('https://dummyjson.com');

  Future<List<Recipe>> list() =>
      _fetch(_base.replace(path: '/recipes', queryParameters: {'limit': '0'}));

  Future<List<Recipe>> search(String term) => _fetch(
    _base.replace(path: '/recipes/search', queryParameters: {'q': term}),
  );

  Future<List<Recipe>> _fetch(Uri uri) async {
    try {
      final response = await _client
          .get(uri)
          .timeout(const Duration(seconds: 12));
      if (response.statusCode != 200) throw const RecipeApiException();
      final decoded = jsonDecode(response.body);
      if (decoded is! Map<String, dynamic> || decoded['recipes'] is! List) {
        throw const RecipeApiException();
      }
      return (decoded['recipes'] as List).map(Recipe.fromJson).toList();
    } on RecipeApiException {
      rethrow;
    } catch (_) {
      throw const RecipeApiException();
    }
  }

  void dispose() => _client.close();
}

class RecipeApiException implements Exception {
  const RecipeApiException();
}
