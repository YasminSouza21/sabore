import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:sabore/src/app.dart';
import 'package:sabore/src/recipe_api.dart';

void main() {
  final pasta = {
    'id': 1,
    'name': 'Pasta Primavera',
    'ingredients': ['Massa', 'Tomate'],
    'instructions': ['Cozinhe a massa', 'Misture o tomate'],
    'prepTimeMinutes': 10,
    'cookTimeMinutes': 20,
    'servings': 2,
  };

  testWidgets('pesquisa, detalhe e favoritos', (tester) async {
    final requests = <Uri>[];
    final api = RecipeApi(
      client: MockClient((request) async {
        requests.add(request.url);
        final term = request.url.queryParameters['q'];
        return http.Response(
          jsonEncode({
            'recipes': term == null || term == 'Pasta Primavera' ? [pasta] : [],
          }),
          200,
        );
      }),
    );
    await tester.pumpWidget(SaboreApp(api: api));
    await tester.pumpAndSettle();

    expect(find.text('Pasta Primavera'), findsOneWidget);
    expect(requests.single.path, '/recipes');

    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Buscar receitas'));
    await tester.pump();
    expect(find.text('Digite um nome para pesquisar.'), findsOneWidget);
    expect(requests, hasLength(1));

    await tester.enterText(find.byType(TextField), '  Pasta   Primavera  ');
    await tester.tap(find.text('Buscar receitas'));
    await tester.pumpAndSettle();
    expect(requests.last.queryParameters['q'], 'Pasta Primavera');
    expect(find.text('Resultados para “Pasta Primavera”'), findsOneWidget);

    await tester.tap(find.byTooltip('Adicionar aos favoritos'));
    await tester.pump();
    await tester.tap(find.text('Pasta Primavera'));
    await tester.pumpAndSettle();
    expect(find.text('Ingredientes'), findsOneWidget);
    expect(find.text('Massa'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Modo de preparo'),
      250,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Modo de preparo'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();

    await tester.tap(find.text('Favoritos'));
    await tester.pumpAndSettle();
    expect(find.text('Pasta Primavera'), findsOneWidget);
    expect(find.text('1 salvas'), findsOneWidget);
  });

  testWidgets('distingue sem resultados e erro de rede', (tester) async {
    var fail = false;
    final api = RecipeApi(
      client: MockClient((request) async {
        if (fail) return http.Response('erro', 500);
        return http.Response(
          jsonEncode({
            'recipes': request.url.path == '/recipes' ? [pasta] : [],
          }),
          200,
        );
      }),
    );
    await tester.pumpWidget(SaboreApp(api: api));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Inexistente');
    await tester.tap(find.text('Buscar receitas'));
    await tester.pumpAndSettle();
    expect(find.text('Nenhum resultado'), findsOneWidget);

    fail = true;
    await tester.drag(find.byType(CustomScrollView), const Offset(0, -400));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Ver todas as receitas'));
    await tester.pumpAndSettle();
    expect(find.text('Não foi possível carregar as receitas.'), findsOneWidget);
    expect(find.text('Tentar novamente'), findsOneWidget);
  });

  test('rejeita resposta incompatível e status de erro', () async {
    final api = RecipeApi(
      client: MockClient((request) async {
        if (request.url.path == '/recipes') {
          return http.Response(jsonEncode({'recipes': 'incompatível'}), 200);
        }
        return http.Response('falha', 503);
      }),
    );
    await expectLater(api.list(), throwsA(isA<RecipeApiException>()));
    await expectLater(api.search('pasta'), throwsA(isA<RecipeApiException>()));
    api.dispose();
  });
}
