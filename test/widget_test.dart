import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sabore/src/app.dart';

void main() {
  testWidgets('navega entre lista, detalhe e favoritos', (tester) async {
    await tester.pumpWidget(const SaboreApp());
    await tester.pumpAndSettle();
    expect(find.text('Pasta Primavera'), findsOneWidget);

    await tester.tap(find.byTooltip('Adicionar aos favoritos').first);
    await tester.pump();
    await tester.tap(find.text('Favoritos'));
    await tester.pumpAndSettle();
    expect(find.text('Pasta Primavera'), findsOneWidget);

    await tester.tap(find.text('Pasta Primavera'));
    await tester.pumpAndSettle();
    expect(find.text('Ingredientes'), findsOneWidget);
    expect(find.text('Massa'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Favoritos'), findsWidgets);

    await tester.tap(find.text('Explorar'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Pasta');
    await tester.tap(find.text('Buscar receitas'));
    await tester.pumpAndSettle();
    expect(find.text('Resultados para “Pasta”'), findsOneWidget);
    await tester.tap(find.text('Pasta Primavera'));
    await tester.pumpAndSettle();
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('Resultados para “Pasta”'), findsOneWidget);
  });
}
