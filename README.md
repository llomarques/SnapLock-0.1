# SnapLock

SnapLock é uma rede social móvel e desktop para compartilhar fotos, acompanhar amigos e organizar memórias por mês. O projeto combina um aplicativo Flutter com uma API em Dart/Shelf e banco de dados MySQL ou MariaDB.

## Funcionalidades

- Cadastro com verificação por e-mail e confirmação de conta
- Login, recuperação e alteração de senha
- Alteração de e-mail com código de confirmação
- Feed de publicações e envio de fotos
- Curtidas, notificações e denúncias
- Pesquisa de usuários e solicitações de amizade
- Perfil pessoal e perfil de amigos
- Galeria em grade, proporções originais e visualização ampliada
- Dumps mensais, capa personalizada e controle de visibilidade
- Personalização de perfil, temas claro/escuro e suporte multilíngue
- Upload e armazenamento de imagens com Cloudinary

## Tecnologias

- Flutter e Dart
- Dart Shelf e Shelf Router
- MySQL ou MariaDB
- SMTP para envio de e-mails
- Cloudinary para upload de imagens
- bcrypt para armazenamento seguro de senhas

## Estrutura do projeto

```text
lib/
├── config/       # configuração das URLs da API
├── controller/   # controladores de autenticação e conta
├── frontend/     # páginas, componentes e utilitários da interface
├── models/       # modelos usados pelo aplicativo
├── services/     # serviços de API e configuração do app
├── theme/        # temas, fontes e controle de tema
└── main.dart     # inicialização do aplicativo

backend/
├── bin/server.dart  # API HTTP em Dart/Shelf
├── lib/             # configuração, utilitários e serviço de e-mail
├── .env             # variáveis locais (não versionar)
└── pubspec.yaml

assets/images/       # logos, ícones e recursos visuais
snaplock_db.sql      # estrutura e migrações do banco
```

## Pré-requisitos

- Flutter SDK compatível com Dart `^3.0.0`
- Dart SDK
- MySQL ou MariaDB
- Conta SMTP
- Conta Cloudinary

## Configuração do banco

Crie o banco e execute o script SQL na raiz do projeto:

```cmd
mysql -u root -p < snaplock_db.sql
```

O script cria o banco `snaplock_db`, tabelas de usuários, fotos, amizade, curtidas, denúncias, recuperação de senha, dumps e demais recursos utilizados pela aplicação.

Na inicialização, a API também verifica e cria/atualiza algumas tabelas e colunas necessárias.

## Configuração da API

Na pasta `backend`, crie o arquivo `.env` com base nestas variáveis:

```dotenv
DB_HOST=127.0.0.1
DB_PORT=3306
DB_NAME=snaplock_db
DB_USER=root
DB_PASSWORD=sua_senha

PORT=3000

SMTP_HOST=smtp.gmail.com
SMTP_PORT=587
SMTP_USER=seuemail@gmail.com
SMTP_PASSWORD=sua_senha_de_aplicativo
SMTP_SSL=true

CLOUDINARY_URL=cloudinary://api_key:api_secret@cloud_name
```

Não versione credenciais reais. O arquivo `.env` já está incluído no `.gitignore`. Para contas do Gmail, use uma senha de aplicativo no campo `SMTP_PASSWORD`.

Instale as dependências e execute o servidor:

```cmd
cd backend
dart pub get
dart run bin\server.dart

```

A API escuta em `0.0.0.0:3000` por padrão e informa o endereço ao iniciar. A porta pode ser alterada pela variável `PORT`.

## Executando o Flutter

Na raiz do projeto:

```cmd
flutter pub get
flutter run
```

As URLs padrão estão definidas em `lib/config/api_config.dart`:

| Ambiente | API | Arquivos |
| --- | --- | --- |
| Web ou Windows | `http://localhost:3000/api` | `http://localhost:3000` |
| Emulador Android | `http://10.0.2.2:3000/api` | `http://10.0.2.2:3000` |

Para um dispositivo físico ou servidor remoto, substitua os endereços por um IP acessível no local em que o app estiver sendo executado.

## Autenticação da API

Após o login, o servidor retorna um token de sessão. As rotas protegidas recebem o token no cabeçalho:

```http
Authorization: Bearer <token>
```

Os tokens são mantidos em memória pelo processo da API. Reiniciar o servidor invalida as sessões atuais.

## Principais endpoints

| Área | Métodos e rotas |
| --- | --- |
| Autenticação | `POST /api/login`, `POST /api/usuarios`, `POST /api/usuarios/verificar-email` |
| Recuperação | `POST /api/recuperacao/solicitar`, `POST /api/recuperacao/validar-token`, `POST /api/recuperacao/redefinir` |
| Perfil | `PUT /api/profile`, `PUT /api/profile/password`, `POST /api/profile/foto`, `DELETE /api/profile/foto`, `DELETE /api/profile` |
| E-mail do perfil | `POST /api/profile/email/request`, `POST /api/profile/email/confirm` |
| Feed e fotos | `GET /api/feed`, `GET /api/fotos/minhas`, `POST /api/fotos`, `DELETE /api/fotos/<id>`, `PUT /api/posts/<id>` |
| Interações | `POST/DELETE /api/posts/<id>/reactions`, `POST /api/posts/<id>/report` |
| Amizades | `GET /api/friends`, `GET /api/friends/search?q=<termo>`, `POST /api/friends/request`, `POST /api/friends/accept`, `POST /api/friends/decline`, `DELETE /api/friends/<id>` |
| Notificações | `GET /api/friends/pending`, `GET /api/friends/accepted-notifications`, `GET /api/notifications/likes` |
| Dumps | `GET /api/dumps/settings`, `GET /api/dumps/friends`, `PUT /api/dumps/<ano>/<mes>`, `POST /api/dumps/<ano>/<mes>/cover` |
| Galeria de amigo | `GET /api/friends/<id>/fotos` |

Consulte `backend/bin/server.dart` para parâmetros, respostas e regras de validação de cada rota.

## Qualidade e análise

Na raiz do projeto:

```cmd
flutter analyze
```

No backend:

```cmd
cd backend
dart analyze
```

Para executar os testes Flutter existentes:

```cmd
flutter test
```
