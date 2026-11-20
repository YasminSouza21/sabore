# Saborê

Aplicativo de receitas em Flutter. A página Explorar carrega receitas da [DummyJSON](https://dummyjson.com/docs/recipes), permite buscar pelo nome e abrir os detalhes com ingredientes e modo de preparo. A página Favoritos guarda as receitas escolhidas durante a sessão.

## Funcionalidades

- Lista inicial com nome, foto, tempo, dificuldade e nota quando disponíveis.
- Busca remota com termo normalizado; entradas vazias mostram orientação sem iniciar requisição.
- Limpeza da busca para voltar à lista completa.
- Detalhe rolável com ingredientes, preparo, tempo e porções.
- Favoritos por identificador, compartilhados entre lista e detalhe, sem duplicação.
- Estados distintos para carregamento, erro de rede, pesquisa sem resultados e favoritos vazios.
- Imagem substituta quando a foto não está disponível.

## Integração

O app consulta `GET /recipes?limit=0` ao abrir e `GET /recipes/search?q=...` para pesquisar. Cada resposta já contém os ingredientes e as instruções, então a tela de detalhes reaproveita o objeto selecionado, identificado por `id`. As consultas são iniciadas fora do método de construção da tela. Enquanto uma requisição está em andamento, o campo e o botão de pesquisa ficam desabilitados para evitar consultas concorrentes.

## Histórico das etapas

1. `Primeira Parte - Definindo Layout`: tela inicial e identidade visual.
2. `Atividade 02 - Criando Campos De Pesquisa`: campo, validação e nova consulta com dados provisórios.
3. `Atividade 03 - Construção e Navegação entre Telas`: lista, detalhes, favoritos e navegação com dados provisórios.
4. `Entrega Final - Integração com API DummyJSON`: dados remotos e estados completos.

Todos os commits pertencem a este mesmo projeto Flutter. Depois de publicar o repositório, o link de cada commit pode ser copiado na aba **Commits** do GitHub.

## Requisitos e execução

- Flutter 3.47.5 ou compatível com Dart 3.13.4.
- Android ou iOS com aparelho ou simulador configurado.
- Conexão com a internet para consultar a API.

```sh
flutter pub get
flutter devices
flutter run -d ID_DO_DISPOSITIVO
```

No Android, o identificador aparece em `flutter devices` após iniciar um emulador no Android Studio ou conectar o celular. No iOS, abra um simulador pelo Xcode ou conecte um iPhone antes de executar o comando.

## Dependências

- `http`: requisições à API DummyJSON.
- `flutter_lints`: análise estática durante o desenvolvimento.

## Verificação

```sh
flutter analyze
flutter test
```

Os favoritos ficam em memória e são reiniciados ao fechar o aplicativo.
