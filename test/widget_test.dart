import 'package:flutter_test/flutter_test.dart';
import 'package:sabore/main.dart';

void main() {
  testWidgets('mostra a identidade e o layout inicial', (tester) async {
    await tester.pumpWidget(const SaboreApp());
    expect(find.text('Saborê'), findsOneWidget);
    expect(find.text('Encontre sua próxima receita'), findsOneWidget);
    expect(find.text('Descubra receitas'), findsOneWidget);
  });
}
