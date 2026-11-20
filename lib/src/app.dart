import 'package:flutter/material.dart';

import 'recipe.dart';
import 'recipe_api.dart';

const ink = Color(0xFF203C32);
const green = Color(0xFF245A49);
const cream = Color(0xFFF8F6F0);
const muted = Color(0xFF66786E);
const rust = Color(0xFFBE4F2A);

class SaboreApp extends StatelessWidget {
  const SaboreApp({super.key, this.api});
  final RecipeApi? api;

  @override
  Widget build(BuildContext context) => MaterialApp(
    title: 'Saborê',
    debugShowCheckedModeBanner: false,
    theme: ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: cream,
      colorScheme: ColorScheme.fromSeed(seedColor: green, surface: cream),
      appBarTheme: const AppBarTheme(
        backgroundColor: cream,
        foregroundColor: ink,
        elevation: 0,
        centerTitle: false,
      ),
      textTheme: Theme.of(context).textTheme
          .apply(bodyColor: ink, displayColor: ink),
    ),
    home: RecipeHome(api: api ?? RecipeApi()),
  );
}

class RecipeHome extends StatefulWidget {
  const RecipeHome({super.key, required this.api});
  final RecipeApi api;

  @override
  State<RecipeHome> createState() => _RecipeHomeState();
}

class _RecipeHomeState extends State<RecipeHome> {
  final _queryController = TextEditingController();
  final _favorites = <int, Recipe>{};
  List<Recipe> _recipes = const [];
  String? _query;
  String? _validation;
  bool _loading = false;
  bool _failed = false;
  int _tab = 0;
  int _requestId = 0;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _queryController.dispose();
    widget.api.dispose();
    super.dispose();
  }

  Future<void> _load([String? query]) async {
    if (_loading) return;
    final request = ++_requestId;
    setState(() {
      _loading = true;
      _failed = false;
      _query = query;
      _validation = null;
    });
    try {
      final recipes = query == null
          ? await widget.api.list()
          : await widget.api.search(query);
      if (!mounted || request != _requestId) return;
      setState(() {
        _recipes = recipes;
        _loading = false;
      });
    } catch (_) {
      if (!mounted || request != _requestId) return;
      setState(() {
        _failed = true;
        _loading = false;
      });
    }
  }

  void _search() {
    final term = _queryController.text.trim().replaceAll(RegExp(r'\s+'), ' ');
    if (term.isEmpty) {
      setState(() => _validation = 'Digite um nome para pesquisar.');
      return;
    }
    FocusScope.of(context).unfocus();
    _load(term);
  }

  void _clearSearch() {
    if (_loading) return;
    _queryController.clear();
    _load();
  }

  void _toggleFavorite(Recipe recipe) {
    setState(() {
      if (_favorites.containsKey(recipe.id)) {
        _favorites.remove(recipe.id);
      } else {
        _favorites[recipe.id] = recipe;
      }
    });
  }

  void _openDetail(Recipe recipe) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => RecipeDetail(
          recipe: recipe,
          isFavorite: () => _favorites.containsKey(recipe.id),
          onFavorite: () => _toggleFavorite(recipe),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: const Text(
        'Saborê',
        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
      ),
      actions: [
        if (_tab == 1)
          Padding(
            padding: const EdgeInsets.only(right: 18),
            child: Center(
              child: Text(
                '${_favorites.length} salvas',
                style: const TextStyle(
                  color: muted,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    ),
    body: SafeArea(child: _tab == 0 ? _explore() : _favoritesView()),
    bottomNavigationBar: NavigationBar(
      backgroundColor: Colors.white,
      indicatorColor: const Color(0xFFE8F0E8),
      selectedIndex: _tab,
      onDestinationSelected: (tab) => setState(() => _tab = tab),
      destinations: const [
        NavigationDestination(icon: Icon(Icons.search), label: 'Explorar'),
        NavigationDestination(
          icon: Icon(Icons.favorite_border),
          selectedIcon: Icon(Icons.favorite, color: rust),
          label: 'Favoritos',
        ),
      ],
    ),
  );

  Widget _explore() => CustomScrollView(
    slivers: [
      SliverPadding(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 14),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            const Divider(color: Color(0xFFDCE4DA)),
            const SizedBox(height: 12),
            const Text(
              'Receitas',
              style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 4),
            const Text(
              'Descubra pratos para cada momento.',
              style: TextStyle(color: muted),
            ),
            const SizedBox(height: 22),
            TextField(
              controller: _queryController,
              enabled: !_loading,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _search(),
              onChanged: (_) {
                if (_validation != null) setState(() => _validation = null);
              },
              decoration: InputDecoration(
                labelText: 'Nome da receita',
                hintText: 'Buscar pelo nome',
                prefixIcon: const Icon(Icons.search),
                errorText: _validation,
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
            const SizedBox(height: 12),
            _PrimaryAction(
              label: 'Buscar receitas',
              onPressed: _loading ? null : _search,
            ),
            const SizedBox(height: 26),
            Row(
              children: [
                Expanded(
                  child: Text(
                    _query == null
                        ? 'Receitas disponíveis'
                        : 'Resultados para “$_query”',
                    style: const TextStyle(
                      fontSize: 21,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                if (_query != null && !_loading)
                  IconButton(
                    tooltip: 'Limpar pesquisa',
                    onPressed: _clearSearch,
                    icon: const Icon(Icons.close, color: green),
                  ),
              ],
            ),
            const SizedBox(height: 3),
            Text(
              _query == null
                  ? 'Selecione uma receita para ver o preparo.'
                  : 'Toque na receita para ver o preparo.',
              style: const TextStyle(color: muted),
            ),
            const SizedBox(height: 18),
          ]),
        ),
      ),
      if (_loading) const SliverToBoxAdapter(child: _LoadingView()),
      if (_failed)
        SliverToBoxAdapter(
          child: _MessageView(
            icon: Icons.error_outline,
            title: 'Não foi possível carregar as receitas.',
            message: 'Verifique sua conexão e tente novamente.',
            button: 'Tentar novamente',
            onPressed: () => _load(_query),
          ),
        ),
      if (!_loading && !_failed && _recipes.isEmpty)
        SliverToBoxAdapter(
          child: _MessageView(
            icon: Icons.search_off,
            title: 'Nenhum resultado',
            message:
                'Não encontramos receitas para esse nome. Tente outro termo.',
            button: 'Ver todas as receitas',
            onPressed: _clearSearch,
          ),
        ),
      if (!_loading && !_failed && _recipes.isNotEmpty)
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
          sliver: SliverList.separated(
            itemCount: _recipes.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (_, index) => RecipeTile(
              recipe: _recipes[index],
              favorite: _favorites.containsKey(_recipes[index].id),
              onTap: () => _openDetail(_recipes[index]),
              onFavorite: () => _toggleFavorite(_recipes[index]),
            ),
          ),
        ),
    ],
  );

  Widget _favoritesView() {
    final recipes = _favorites.values.toList();
    return CustomScrollView(
      slivers: [
        const SliverPadding(
          padding: EdgeInsets.fromLTRB(20, 14, 20, 22),
          sliver: SliverToBoxAdapter(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Divider(color: Color(0xFFDCE4DA)),
                SizedBox(height: 12),
                Text(
                  'Favoritos',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800),
                ),
                SizedBox(height: 4),
                Text(
                  'Receitas salvas nesta sessão.',
                  style: TextStyle(color: muted),
                ),
              ],
            ),
          ),
        ),
        if (recipes.isEmpty)
          SliverToBoxAdapter(
            child: _MessageView(
              icon: Icons.favorite_border,
              title: 'Nenhum favorito',
              message:
                  'Marque uma receita como favorita para encontrá-la aqui.',
              button: 'Explorar receitas',
              onPressed: () => setState(() => _tab = 0),
            ),
          ),
        if (recipes.isNotEmpty)
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 0, 20, 28),
            sliver: SliverList.separated(
              itemCount: recipes.length,
              separatorBuilder: (_, _) => const SizedBox(height: 12),
              itemBuilder: (_, index) => RecipeTile(
                recipe: recipes[index],
                favorite: true,
                onTap: () => _openDetail(recipes[index]),
                onFavorite: () => _toggleFavorite(recipes[index]),
              ),
            ),
          ),
      ],
    );
  }
}

class RecipeTile extends StatelessWidget {
  const RecipeTile({
    super.key,
    required this.recipe,
    required this.favorite,
    required this.onTap,
    required this.onFavorite,
  });
  final Recipe recipe;
  final bool favorite;
  final VoidCallback onTap;
  final VoidCallback onFavorite;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.white,
    borderRadius: BorderRadius.circular(20),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.all(11),
        decoration: BoxDecoration(
          border: Border.all(color: const Color(0xFFDCE4DA)),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            RecipeImage(url: recipe.image, size: 96),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    recipe.name,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    [
                      if (recipe.totalMinutes != null)
                        '${recipe.totalMinutes} min',
                      if (recipe.difficulty != null) recipe.difficulty!,
                    ].join('  •  '),
                    style: const TextStyle(color: muted, fontSize: 12),
                  ),
                  const SizedBox(height: 5),
                  if (recipe.rating != null)
                    Text(
                      '${recipe.rating} / 5',
                      style: const TextStyle(
                        color: green,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                ],
              ),
            ),
            IconButton(
              tooltip: favorite
                  ? 'Remover dos favoritos'
                  : 'Adicionar aos favoritos',
              onPressed: onFavorite,
              icon: Icon(
                favorite ? Icons.favorite : Icons.favorite_border,
                color: favorite ? rust : ink,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

class RecipeImage extends StatelessWidget {
  const RecipeImage({super.key, required this.url, required this.size});
  final String? url;
  final double size;

  @override
  Widget build(BuildContext context) => ClipRRect(
    borderRadius: BorderRadius.circular(16),
    child: SizedBox(
      width: size,
      height: size,
      child: url == null
          ? _fallback()
          : Image.network(
              url!,
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => _fallback(),
              loadingBuilder: (_, child, progress) =>
                  progress == null ? child : _fallback(),
            ),
    ),
  );

  Widget _fallback() => Container(
    color: const Color(0xFFE8EBDD),
    child: const Icon(Icons.restaurant, color: green, size: 36),
  );
}

class _PrimaryAction extends StatelessWidget {
  const _PrimaryAction({required this.label, required this.onPressed});
  final String label;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    height: 52,
    child: FilledButton(
      onPressed: onPressed,
      style: FilledButton.styleFrom(
        backgroundColor: green,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    ),
  );
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();
  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.all(28),
    child: Column(
      children: [
        Center(child: CircularProgressIndicator(color: green)),
        SizedBox(height: 18),
        Text('Carregando receitas…', style: TextStyle(color: muted)),
      ],
    ),
  );
}

class _MessageView extends StatelessWidget {
  const _MessageView({
    required this.icon,
    required this.title,
    required this.message,
    required this.button,
    required this.onPressed,
  });
  final IconData icon;
  final String title;
  final String message;
  final String button;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(24, 8, 24, 28),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        CircleAvatar(
          radius: 48,
          backgroundColor: const Color(0xFFE8F0E8),
          child: Icon(icon, color: green, size: 40),
        ),
        const SizedBox(height: 22),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 25, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: muted, height: 1.45),
        ),
        const SizedBox(height: 26),
        _PrimaryAction(label: button, onPressed: onPressed),
      ],
    ),
  );
}

class RecipeDetail extends StatefulWidget {
  const RecipeDetail({
    super.key,
    required this.recipe,
    required this.isFavorite,
    required this.onFavorite,
  });
  final Recipe recipe;
  final bool Function() isFavorite;
  final VoidCallback onFavorite;

  @override
  State<RecipeDetail> createState() => _RecipeDetailState();
}

class _RecipeDetailState extends State<RecipeDetail> {
  @override
  Widget build(BuildContext context) {
    final recipe = widget.recipe;
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Receita',
          style: TextStyle(fontWeight: FontWeight.w800),
        ),
        actions: [
          IconButton(
            tooltip: widget.isFavorite()
                ? 'Remover dos favoritos'
                : 'Adicionar aos favoritos',
            onPressed: () {
              widget.onFavorite();
              setState(() {});
            },
            icon: Icon(
              widget.isFavorite() ? Icons.favorite : Icons.favorite_border,
              color: widget.isFavorite() ? rust : ink,
            ),
          ),
          const SizedBox(width: 10),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 36),
          children: [
            SizedBox(
              width: double.infinity,
              height: 220,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: recipe.image == null
                    ? const ColoredBox(
                        color: Color(0xFFE8EBDD),
                        child: Icon(Icons.restaurant, color: green, size: 70),
                      )
                    : Image.network(
                        recipe.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const ColoredBox(
                          color: Color(0xFFE8EBDD),
                          child: Icon(Icons.restaurant, color: green, size: 70),
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              recipe.name,
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.w800,
                height: 1.15,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              [
                if (recipe.cuisine != null) recipe.cuisine!,
                if (recipe.difficulty != null) recipe.difficulty!,
                if (recipe.rating != null) '${recipe.rating} / 5',
              ].join('  •  '),
              style: const TextStyle(color: muted),
            ),
            const SizedBox(height: 22),
            Row(
              children: [
                if (recipe.totalMinutes != null)
                  Expanded(
                    child: _Fact(
                      value: '${recipe.totalMinutes} min',
                      label: 'tempo total',
                    ),
                  ),
                if (recipe.totalMinutes != null && recipe.servings != null)
                  const SizedBox(width: 10),
                if (recipe.servings != null)
                  Expanded(
                    child: _Fact(value: '${recipe.servings}', label: 'porções'),
                  ),
              ],
            ),
            if (recipe.mealTypes.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 14),
                child: Text(
                  'Tipo: ${recipe.mealTypes.join(', ')}',
                  style: const TextStyle(color: muted),
                ),
              ),
            const SizedBox(height: 26),
            const Text(
              'Ingredientes',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            if (recipe.ingredients.isEmpty)
              const Text('Ingredientes não informados.'),
            ...recipe.ingredients.map(
              (item) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      '•  ',
                      style: TextStyle(color: green, fontSize: 17),
                    ),
                    Expanded(
                      child: Text(item, style: const TextStyle(height: 1.4)),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Modo de preparo',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 12),
            if (recipe.instructions.isEmpty)
              const Text('Modo de preparo não informado.'),
            ...recipe.instructions.asMap().entries.map(
              (step) => Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    CircleAvatar(
                      radius: 15,
                      backgroundColor: green,
                      child: Text(
                        '${step.key + 1}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        step.value,
                        style: const TextStyle(height: 1.45),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Fact extends StatelessWidget {
  const _Fact({required this.value, required this.label});
  final String value;
  final String label;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFEAF1E9),
      borderRadius: BorderRadius.circular(14),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          value,
          style: const TextStyle(
            color: green,
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        Text(label, style: const TextStyle(color: muted, fontSize: 11)),
      ],
    ),
  );
}
