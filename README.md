# SnapLock Rascunho



## Requisitos

- Flutter SDK
- Dart SDK compatível com `^3.0.0`

## Como executar

1. Instale as dependências:

	```bash
	flutter pub get
	```

2. Execute o aplicativo:

	```bash
	flutter run
	```

Para executar no navegador, use:

```bash
flutter run -d chrome
```

## Estrutura principal

- `lib/main.dart`: ponto de entrada e tela inicial do aplicativo.
- `lib/controller/controller.cadastrar.dart`: cliente HTTP usado pelo front para cadastrar usuários.
- `backend/bin/server.dart`: API Dart que valida os dados e salva no MariaDB.
- `android/`: configuração da plataforma Android.
- `web/`: configuração da plataforma Web.
- `windows/`: configuração da plataforma Windows.

## Verificação

Para analisar o código, execute:

```bash
flutter analyze
```

## API de cadastro

O backend é separado do front e usa Dart, Shelf e MariaDB. Primeiro execute o script `snaplock_db.sql` no MariaDB. Depois, na pasta `backend`, instale e inicie a API:

```bash
dart pub get
dart run bin/server.dart
```

Por padrão, a API usa `127.0.0.1:3306`, banco `snaplock_db`, usuário `root`, senha vazia e porta HTTP `3000`. Para alterar esses valores, configure `DB_HOST`, `DB_PORT`, `DB_NAME`, `DB_USER`, `DB_PASSWORD` e `PORT` no ambiente antes de iniciar.

O endpoint é `POST /api/usuarios` e recebe:

```json
{
	"nome": "Maria Silva",
	"email": "maria@example.com",
	"senha": "senha-segura",
	"data_nascimento": "2000-01-31"
}
```

Em caso de sucesso, responde `201` com `id_usuario`. O front Flutter deve ser iniciado apontando `API_BASE_URL` para a URL da API:

```bash
flutter run --dart-define=API_BASE_URL=http://localhost:3000
```
