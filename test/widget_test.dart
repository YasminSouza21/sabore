import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:sabore/main.dart';

void main() {
  testWidgets('mostra a identidade e o layout inicial', (tester) async {
    await tester.pumpWidget(const SaboreApp());
    expect(find.text('Saborê'), findsOneWidget);
    expect(find.text('Encontre sua próxima receita'), findsOneWidget);
    expect(find.text('Descubra receitas'), findsOneWidget);
  });

  testWidgets('valida espaços e permite repetir a pesquisa', (tester) async {
    await tester.pumpWidget(const SaboreApp());
    await tester.enterText(find.byType(TextField), '   ');
    await tester.tap(find.text('Buscar receitas'));
    await tester.pump();
    expect(
      find.text('Digite o nome de uma receita para pesquisar.'),
      findsOneWidget,
    );
    expect(find.textContaining('Pesquisa recebida:'), findsNothing);

    await tester.enterText(find.byType(TextField), '  Pasta   Primavera  ');
    await tester.tap(find.text('Buscar receitas'));
    await tester.pump();
    expect(find.text('Pesquisa recebida: Pasta Primavera'), findsOneWidget);
    await tester.ensureVisible(find.text('Nova pesquisa'));
    await tester.tap(find.text('Nova pesquisa'));
    await tester.pump();
    expect(find.textContaining('Pesquisa recebida:'), findsNothing);
  });
}
