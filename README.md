# SnapLock

Aplicativo Flutter com backend Dart, MariaDB e recuperação de senha por e-mail.

## Requisitos

- Flutter SDK
- Dart SDK compatível com `^3.0.0`
- MariaDB/MySQL
- Conta de e-mail com SMTP configurável
- Thunder Client, para testar a API

## Estrutura

- `lib/frontend/`: telas do aplicativo.
- `lib/controller/controller.cadastrar.dart`: chamadas de cadastro e recuperação.
- `lib/services/api_service.dart`: chamadas gerais do frontend.
- `backend/bin/server.dart`: API Dart com Shelf.
- `backend/pubspec.yaml`: dependências do backend.
- `snaplock_db.sql`: criação e migração do banco.

## Banco de dados

Execute `snaplock_db.sql` no MariaDB. Para uma instalação já existente, confira se a tabela `usuario` tem `username` e índice único:

```sql
USE snaplock_db;

SHOW COLUMNS FROM usuario;
SHOW INDEX FROM usuario;
```

Se a coluna ainda não existir, execute:

```sql
ALTER TABLE usuario
ADD COLUMN username VARCHAR(30) NULL AFTER nome;

UPDATE usuario
SET username = CONCAT('usuario_', id_usuario)
WHERE username IS NULL OR TRIM(username) = '';

ALTER TABLE usuario
MODIFY username VARCHAR(30) NOT NULL;

ALTER TABLE usuario
ADD UNIQUE KEY uq_usuario_username (username);
```

## Iniciar a API no CMD

Abra o CMD e execute os comandos na ordem, na mesma janela:

```cmd
cd /d C:\Users\25162850\Documents\SnapLock-0.1\backend
dart pub get

set "DB_HOST=127.0.0.1"
set "DB_PORT=3306"
set "DB_NAME=snaplock_db"
set "DB_USER=root"
set "DB_PASSWORD=senha-do-mariadb"

set "SMTP_HOST=smtp.gmail.com"
set "SMTP_USER=seuemail@gmail.com"
set "SMTP_PASSWORD=senha-de-aplicativo-do-google"
set "SMTP_PORT=587"

dart run bin\server.dart
```

Para Gmail, `SMTP_USER` é o e-mail que enviará as mensagens. `SMTP_PASSWORD` deve ser uma senha de aplicativo de 16 caracteres, não a senha normal da conta. Crie-a em <https://myaccount.google.com/apppasswords> com a verificação em duas etapas ativada.

Se aparecer `Authentication Failed (535)`, confira essas credenciais e reinicie a API no mesmo CMD. Não compartilhe nem comite a senha de aplicativo.

Quando funcionar, a API exibirá:

```text
SnapLock API em http://0.0.0.0:3000
```

## Iniciar o frontend

Abra um segundo terminal, mantendo a API aberta no primeiro:

```cmd
cd /d C:\Users\25162850\Documents\SnapLock-0.1
flutter pub get
flutter run
```

O frontend usa automaticamente:

- Windows/Web: `http://localhost:3000`
- Emulador Android: `http://10.0.2.2:3000`

O Android precisa ser executado com a API rodando no computador. Se necessário, faça um reinício completo do app após alterar a URL.

## Regras de cadastro

O cadastro exige `nome`, `username`, `email`, `senha`, `confirmacao_senha` e `data_nascimento`.

- Username: de 3 a 30 caracteres, usando letras minúsculas, números ou `_`, e único.
- Senha: no mínimo 8 caracteres, com maiúscula, minúscula, número e caractere especial.
- Idade: mínimo de 16 anos.

## Testar no Thunder Client

Com a API rodando, use `POST http://localhost:3000/api/usuarios`, header `Content-Type: application/json` e este body:

```json
{
	"nome": "Maria Teste",
	"username": "maria_teste",
	"email": "maria.teste@example.com",
	"senha": "Maria@123456",
	"confirmacao_senha": "Maria@123456",
	"data_nascimento": "2000-01-31"
}
```

Sucesso retorna `201`:

```json
{
	"id_usuario": 1
}
```

Repetir o mesmo username retorna `409`:

```json
{
	"erro": "Este username já está em uso."
}
```

## Recuperação de senha

Solicite o token com `POST http://localhost:3000/api/recuperacao/solicitar`:

```json
{
	"email": "maria.teste@example.com"
}
```

O token expira em 15 minutos. Um novo token só pode ser solicitado após 30 segundos.

Redefina a senha com `POST http://localhost:3000/api/recuperacao/redefinir`:

```json
{
	"email": "maria.teste@example.com",
	"token": "123456",
	"nova_senha": "Nova@123456",
	"confirmacao_senha": "Nova@123456"
}
```

## Verificação

```cmd
flutter analyze
cd backend
dart analyze
```
