# SnapLock

SnapLock é um aplicativo Flutter para compartilhar fotos e interagir com amigos. O projeto inclui uma API em Dart (Shelf) e banco de dados MySQL/MariaDB.

## Funcionalidades

- Cadastro com confirmação de e-mail, login e recuperação de senha
- Feed de publicações, envio de fotos, curtidas e denúncias
- Pesquisa, solicitações e gerenciamento de amizades
- Perfil pessoal e perfil de amigos com biografia, contagem de amigos e galeria de memórias
- Galeria do perfil de amigos em duas colunas, preservando a proporção das fotos, com carregamento, atualização, erro/retry e visualização ampliada
- Dumps mensais, configurações de visibilidade e capa
- Alteração de dados da conta, e-mail e senha
- Temas claro/escuro

## Tecnologias e requisitos

- Flutter e Dart compatíveis com `^3.0.0`
- MySQL ou MariaDB
- SMTP para confirmação de cadastro, recuperação de senha e outros e-mails
- Conta Cloudinary para upload de imagens

## Estrutura

```text
lib/
  main.dart
  config/                 # configuração da URL da API
  controller/             # controladores de autenticação e conta
  frontend/
    pages/                # início, feed, perfis, amizades e demais telas
    utils/
    widgets/
  models/
  screens/                # telas de autenticação e funcionalidades
  services/               # API, idioma e segurança de tela
  theme/
  widgets/
backend/
  bin/server.dart         # servidor e rotas HTTP
  lib/                    # configuração, utilitários e e-mails
snaplock_db.sql           # estrutura inicial e migrações do banco
```

O fluxo inicial definido em `lib/main.dart` abre `InicioPage`. A tela de perfil de amigo carrega as publicações pela API usando o identificador do usuário e apresenta mensagens de carregamento, erro com opção de tentar novamente ou estado vazio.

## Banco de dados

Crie o banco e as tabelas executando `snaplock_db.sql` no MySQL/MariaDB. O script utiliza o banco `snaplock_db` e contém migrações para instalações existentes. O backend também cria ou atualiza algumas tabelas e colunas durante a inicialização.

## Configuração e inicialização da API

No CMD, na pasta do backend:

```cmd
cd /d C:\Users\25162850\Documents\SnapLock-0.1\backend
dart pub get

set "DB_HOST=127.0.0.1"
set "DB_PORT=3306"
set "DB_NAME=snaplock_db"
set "DB_USER=root"
set "DB_PASSWORD=sua_senha"

set "PORT=3000"
set "SMTP_HOST=smtp.gmail.com"
set "SMTP_PORT=587"
set "SMTP_USER=seuemail@gmail.com"
set "SMTP_PASSWORD=sua_senha_de_aplicativo"
set "CLOUDINARY_URL=cloudinary://<api_key>:<api_secret>@<cloud_name>"

dart run bin\server.dart
```

O servidor lê configurações do ambiente e do arquivo `.env` carregado pelo backend. Não versione credenciais. Para Gmail, use uma senha de aplicativo em `SMTP_PASSWORD`, não a senha normal da conta. `SMTP_SSL` é opcional e, quando definido como `true`, habilita SSL.

A API escuta na porta `3000` por padrão (ou na porta definida por `PORT`) e exibe o endereço ao iniciar.

## Executando o Flutter

Em outro terminal, na raiz do projeto:

```cmd
cd /d C:\Users\25162850\Documents\SnapLock-0.1
flutter pub get
flutter run
```

O app usa estas URLs padrão para a API:

- Web e Windows: `http://localhost:3000/api`
- Emulador Android: `http://10.0.2.2:3000/api`

Esses endereços estão definidos em `lib/config/api_config.dart`. Para outro dispositivo ou servidor, ajuste a configuração para apontar ao endereço correto da API.

## Endpoints da API

As rotas implementadas incluem:

| Método | Rota |
| --- | --- |
| `POST` | `/api/usuarios` |
| `POST` | `/api/usuarios/verificar-email` |
| `POST` | `/api/recuperacao/solicitar` |
| `POST` | `/api/recuperacao/validar-token` |
| `POST` | `/api/recuperacao/redefinir` |
| `GET` | `/api/feed` |
| `POST` | `/api/fotos` |
| `GET` | `/api/fotos/minhas` |
| `GET` | `/api/friends` |
| `GET` | `/api/friends/<id>/fotos` |
| `POST` / `DELETE` | `/api/posts/<id>/reactions` |
| `POST` | `/api/posts/<id>/report` |
| `GET` / `PUT` | `/api/dumps/...` |

As operações protegidas exigem uma sessão autenticada. Consulte `backend/bin/server.dart` para os parâmetros e respostas de cada rota.

## Verificação

Na raiz do projeto:

```cmd
flutter analyze
```

Para analisar o backend:

```cmd
cd backend
dart analyze
```
