import 'package:flutter/material.dart';

void main() => runApp(const SaboreApp());

const green = Color(0xFF245A49);
const cream = Color(0xFFF8F6F0);
const ink = Color(0xFF203C32);

class SaboreApp extends StatelessWidget {
  const SaboreApp({super.key});

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Saborê',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: cream,
      colorScheme: ColorScheme.fromSeed(seedColor: green),
    ),
    home: const HomePage(),
  );
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      backgroundColor: cream,
      title: const Text(
        'Saborê',
        style: TextStyle(color: ink, fontWeight: FontWeight.w800),
      ),
    ),
    body: SafeArea(
      child: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: green,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(Icons.restaurant_menu, color: Colors.white, size: 34),
                SizedBox(height: 22),
                Text(
                  'Encontre sua próxima receita',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Ideias simples e saborosas para cada momento.',
                  style: TextStyle(color: Color(0xFFE2EFE7), fontSize: 15),
                ),
              ],
            ),
          ),
          const SizedBox(height: 30),
          const Text(
            'Descubra receitas',
            style: TextStyle(
              color: ink,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Em breve: pesquisa por nome e receitas da API.',
            style: TextStyle(color: Color(0xFF66786E)),
          ),
          const SizedBox(height: 18),
          const _PreviewCard(
            name: 'Pasta Primavera',
            detail: 'Uma opção para o almoço',
          ),
          const SizedBox(height: 12),
          const _PreviewCard(
            name: 'Salada fresca',
            detail: 'Leve e fácil de preparar',
          ),
        ],
      ),
    ),
  );
}

class _PreviewCard extends StatelessWidget {
  const _PreviewCard({required this.name, required this.detail});
  final String name;
  final String detail;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      border: Border.all(color: const Color(0xFFDCE4DA)),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Row(
      children: [
        Container(
          width: 58,
          height: 58,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F0E8),
            borderRadius: BorderRadius.circular(14),
          ),
          child: const Icon(Icons.restaurant, color: green),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: const TextStyle(color: ink, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 4),
              Text(detail, style: const TextStyle(color: Color(0xFF66786E))),
            ],
          ),
        ),
      ],
    ),
  );
}
