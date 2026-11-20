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

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final _controller = TextEditingController();
  String? _error;
  String? _term;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _search() {
    final term = _controller.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (term.isEmpty) {
      setState(() => _error = 'Digite o nome de uma receita para pesquisar.');
      return;
    }
    FocusScope.of(context).unfocus();
    setState(() {
      _error = null;
      _term = term;
    });
  }

  void _newSearch() {
    _controller.clear();
    setState(() {
      _term = null;
      _error = null;
    });
  }

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
            'Pesquise pelo nome da receita que deseja preparar.',
            style: TextStyle(color: Color(0xFF66786E)),
          ),
          const SizedBox(height: 18),
          TextField(
            controller: _controller,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => _search(),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
            decoration: InputDecoration(
              labelText: 'Nome da receita',
              hintText: 'Ex.: Pasta Primavera',
              errorText: _error,
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          const SizedBox(height: 12),
          FilledButton(
            onPressed: _search,
            style: FilledButton.styleFrom(backgroundColor: green),
            child: const Text('Buscar receitas'),
          ),
          if (_term != null) ...[
            const SizedBox(height: 14),
            Text(
              'Pesquisa recebida: $_term',
              style: const TextStyle(color: ink, fontWeight: FontWeight.w700),
            ),
            TextButton.icon(
              onPressed: _newSearch,
              icon: const Icon(Icons.close),
              label: const Text('Nova pesquisa'),
            ),
          ],
          const SizedBox(height: 22),
          const Text(
            'Sugestões',
            style: TextStyle(
              color: ink,
              fontSize: 20,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 12),
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
